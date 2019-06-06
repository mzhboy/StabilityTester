#!/bin/bash
[[ -x "$0" ]] || { chmod a+x "$0" || sudo chmod a+x "$0"; }
sync

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

cpufreq_policy_bak="$(cpufreq-info -p)"
function cpufreq_restore()
{
    cpufreq-set --max $(echo $cpufreq_policy_bak|awk '{print $2}') \
                --min $(echo $cpufreq_policy_bak|awk '{print $1}') \
                --governor $(echo $cpufreq_policy_bak|awk '{print $3}')
}

function select_xhpl()
{
    # select xhpl binary file
    XHPLBINARY_USR=/usr/local/bin/xhpl
    XHPL=xhpl
    if [[ -x "$XHPLBINARY_USR" ]]; then
        if [[ -f "$XHPL" ]];then
            if [[ -L "$XHPL" ]];then
                [[ "$(realpath xhpl)" == "$XHPLBINARY_USR" ]] || { /bin/rm "$XHPL"; ln -s "$XHPLBINARY_USR" "$XHPL"; }
            else
             [[ -x "$XHPL" ]] || /bin/rm "$XHPL"; ln -s "$XHPLBINARY_USR" "$XHPL";
            fi
        else
            ln -s "$XHPLBINARY_USR" "$XHPL"
        fi
        XHPLBINARY="$ROOT/$XHPL"
    else
        if [[ "$(uname -m)" == "aarch64" ]]; then
            XHPLBINARY=xhpl64
        else
            echo "machine is not aarch64, you need build xhpl first"
            exit 1
        fi
    fi

    [[ -x "$XHPLBINARY" ]] || { echo "error xhpl binary no exists";exit 1; }
}

function kill_xhpl()
{
    [[ -n "$XHPLBINARY" ]] && [[ $(pgrep -c -f "$XHPLBINARY") -gt 0 ]] && pkill -f "$XHPLBINARY"
}

function prepare()
{
    declare -A VOLTAGES=()

    # Make sure only root can run our script
    if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 1>&2
    exit 1
    fi

    select_xhpl
    kill_xhpl

    if [ ! -d "${ROOT}/results" ];
    then
        echo "Create";
        mkdir ${ROOT}/results;
    fi

    # install dependent packages
    [[ $(dpkg -l|grep -c cpufrequtils) -ge 1 ]] || require_pkg="cpufrequtils"
    [[ $(dpkg -l|grep -c libmpich12) -eq 1 ]] || require_pkg="$require_pkg libmpich12"
    [[ $(dpkg -l|grep -c libopenblas-base) -eq 1 ]] || require_pkg="$require_pkg libopenblas-base"
    [[ $(dpkg -l|grep -c libatlas3-base) -eq 1 ]] || require_pkg="$require_pkg libatlas3-base"
    [[ -n "$require_pkg" ]] && apt-get install $require_pkg -y
}

function bench_loop()
{
    AVAILABLEFREQUENCIES=$(cat ${CPUFREQ_HANDLER}/${SCALINGAVAILABLEFREQUENCIES})

    export LC_ALL=zh_CN.UTF-8
    for FREQUENCY in $AVAILABLEFREQUENCIES
    do
        if [ $FREQUENCY -ge $MINFREQUENCY ] && [ $FREQUENCY -le $MAXFREQUENCY ];
        then
            cpufreq-set -f $FREQUENCY

            "$XHPLBINARY" > ${ROOT}/results/xhpl_${FREQUENCY}.log &
            sleep 0.5
            [[ $(pgrep -c -f "$XHPLBINARY") -eq 0 ]] && { echo "fail no xhpl process";exit 1; }

            while [[ $(pgrep -c -f "$XHPLBINARY") -gt 0 ]]
            do
                SOCTEMP=$(cat ${SOCTEMPCMD})
                #CURFREQ=$(cpufreq-info -f)
                CURFREQ=$(cat ${CPUFREQ_HANDLER}/scaling_cur_freq)
                CURVOLT=$(cat ${REGULATOR_HANDLER}/${REGULATOR_MICROVOLT})
                printf "\r"
                printf "TEST Freq: %4d MHz\t" "$((FREQUENCY/1000))"
                printf "Soc temp: %+6s ℃\t"      $(awk -v x=${SOCTEMP} 'BEGIN{printf "%.2f\n",x/1000}') # ℃=\u2103
                printf "CPU Freq: %4d MHz\t"  "$((CURFREQ/1000))"
                printf "CPU Core: %4d mV"     "$((CURVOLT/1000))"
                if [ $CURFREQ -eq $FREQUENCY ];
                then
                    VOLTAGES[$FREQUENCY]=$CURVOLT
                fi
                sleep 0.4;
            done

            echo
            cpufreq-set -f $COOLDOWNFREQ
            while [ $SOCTEMP -gt $COOLDOWNTEMP ];
            do
                local SOCTEMP=$(cat ${SOCTEMPCMD})
                printf "\rCooling down: ${SOCTEMP}"
                sleep 0.4;
            done
            printf "\r"
        fi
    done

    cpufreq_restore
}

function print_result()
{
    kill_xhpl
    echo -e "\nDone testing stability:\tdate: $(date +%Y%m%d-%H%M%S)"
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
                printf "Frequency: %4d MHz\t" "$((FREQUENCY/1000))"
                printf "Voltage:  %4d mV\t"   "$((VOLTAGE/1000))"
                printf "Success: ${SUCCESSTEST}\t"
                #printf "Result: ${RESULTTEST}\n"
                printf "Gflops: ${GFLOPSTEST}\n"
            fi
        fi
    done
}

PS4='Line ${LINENO}: '
# trap prepare debug
trap "{ kill_xhpl; cpufreq_restore; echo && exit 0; }" SIGINT SIGTERM SIGKILL
prepare
bench_loop
print_result | tee -a $ROOT/result.log
sync $ROOT/result.log
