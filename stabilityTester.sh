#!/bin/bash

MINFREQUENCY=400000 #Only test frequencies from this point.
MAXFREQUENCY=2810000 #Only test frequencies upto this point.
COOLDOWNTEMP=55000 #Cool down after a test to mC degrees
COOLDOWNFREQ=720000 # Set to this speed when cooling down

CPUFREQ_HANDLER="/sys/devices/system/cpu/cpu0/cpufreq";
SCALINGAVAILABLEFREQUENCIES="scaling_available_frequencies";
SCALINGMINFREQUENCY="scaling_min_freq";
SCALINGMAXFREQUENCY="scaling_max_freq";

SOCTEMPCMD="/sys/class/thermal/thermal_zone0/temp"

REGULATOR_HANDLER="/sys/class/regulator/regulator.2"
REGULATOR_MICROVOLT="microvolts"

ROOT=$(pwd)

policy_bak="$(cpufreq-info -p)"

# select xhpl binary file
XHPLBINARY_USR=/usr/local/bin/xhpl
XHPL=xhpl
if [[ -x $XHPLBINARY_USR ]]; then
    if [[ -f $XHPL ]];then
        if [[ -L $XHPL ]];then
            [[ $(realpath xhpl) == $XHPLBINARY_USR ]] || (/bin/rm $XHPL; ln -s $XHPLBINARY_USR $XHPL;)
        elif [[ ! -x $XHPL ]]; then
            /bin/rm $XHPL; ln -s $XHPLBINARY_USR $XHPL;
        fi

        XHPLBINARY=$ROOT/$XHPL
    fi
else
    if [[ $(uname -m) == "aarch64" ]]; then
        XHPLBINARY=xhpl64
    else
        echo "machine is not aarch64, you need build xhpl first"
        exit 1
    fi
fi

declare -A VOLTAGES=()

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

[[ $(pgrep -c -f "$XHPLBINARY") -gt 0 ]] && pkill -f "$XHPLBINARY"

if [ ! -d "${ROOT}/results" ];
then
	echo "Create";
	mkdir ${ROOT}/results;
fi

# install dependent packages
[[ $(dpkg -l|grep -c libmpich12) -eq 1 ]] || require_pkg="libmpich12"
[[ $(dpkg -l|grep -c libopenblas-base) -eq 1 ]] || require_pkg="$require_pkg libopenblas-base"
[[ $(dpkg -l|grep -c libatlas3-base) -eq 1 ]] || require_pkg="$require_pkg libatlas3-base"
[[ -n "$require_pkg" ]] && apt-get install $require_pkg -y

AVAILABLEFREQUENCIES=$(cat ${CPUFREQ_HANDLER}/${SCALINGAVAILABLEFREQUENCIES})

for FREQUENCY in $AVAILABLEFREQUENCIES
do
    if [ $FREQUENCY -ge $MINFREQUENCY ] && [ $FREQUENCY -le $MAXFREQUENCY ];
    then
        echo "Testing frequency ${FREQUENCY}";

        cpufreq-set -f $FREQUENCY

        "$XHPLBINARY" > ${ROOT}/results/xhpl_${FREQUENCY}.log &
        sleep 1
        echo -n "Soc temp:"
        while [[ $(pgrep -c -f "$XHPLBINARY") -gt 0 ]]
        do
            SOCTEMP=$(cat ${SOCTEMPCMD})
            #CURFREQ=$(cpufreq-info -f)
            CURFREQ=$(cat ${CPUFREQ_HANDLER}/scaling_cur_freq)
            CURVOLT=$(cat ${REGULATOR_HANDLER}/${REGULATOR_MICROVOLT})
            echo -ne "\rSoc temp: ${SOCTEMP} \tCPU Freq: ${CURFREQ} \tCPU Core: ${CURVOLT} \t"
            if [ $CURFREQ -eq $FREQUENCY ];
            then
                VOLTAGES[$FREQUENCY]=$CURVOLT
            fi
            sleep 1;
        done
        echo -ne "\r"
        echo -n "Cooling down"
        cpufreq-set -f $COOLDOWNFREQ
        while [ $SOCTEMP -gt $COOLDOWNTEMP ];
        do
            SOCTEMP=$(cat ${SOCTEMPCMD})
            echo -ne "\rCooling down: ${SOCTEMP}"

            sleep 1;
        done
	echo -ne "\n"
    fi
done

echo -e "\nDone testing stability:"
for FREQUENCY in $AVAILABLEFREQUENCIES
do
    if [ $FREQUENCY -ge $MINFREQUENCY ] && [ $FREQUENCY -le $MAXFREQUENCY ];
    then
        FINISHEDTEST=$(grep -Ec "PASSED|FAILED" ${ROOT}/results/xhpl_${FREQUENCY}.log )
        SUCCESSTEST=$(grep -Ec "PASSED" ${ROOT}/results/xhpl_${FREQUENCY}.log )
        DIFF=$(grep -E 'PASSED|FAILED' ${ROOT}/results/xhpl_${FREQUENCY}.log)
        #echo $DIFF
        DIFF="${DIFF#*=}"
        DIFF="${DIFF#* }"
        #echo $DIFF
        RESULTTEST="${DIFF% .*}"
        GFLOPSTEST=$(awk '/Gflops$/ {ml=NR+2} NR==ml{print $NF}' ${ROOT}/results/xhpl_${FREQUENCY}.log)
        VOLTAGE=${VOLTAGES[$FREQUENCY]}
        if [ $FINISHEDTEST -eq 1 ];
        then
            echo -ne "Frequency: $((FREQUENCY/1000)) MHz\t"
            echo -ne "Voltage:  $((VOLTAGE/1000)) mV\t"
            echo -ne "Success: ${SUCCESSTEST}\t"
            #echo -ne "Result: ${RESULTTEST}\n"
            echo -ne "Gflops: ${GFLOPSTEST}\n"
        fi
    fi
done

[[ $(pgrep -c -f "$XHPLBINARY") -gt 0 ]] && pkill -f "$XHPLBINARY"
cpufreq-set --max $(echo $policy_bak|awk '{print $2}')
cpufreq-set --min $(echo $policy_bak|awk '{print $1}')
cpufreq-set --governor $(echo $policy_bak|awk '{print $3}')
