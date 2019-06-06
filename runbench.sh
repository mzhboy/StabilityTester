#!/bin/bash
count=10
if [[ $# -gt 0 ]];then
	if [[ $1 -gt 1 ]] ;then
		count=$1
	fi
fi

pushd .
cd $(dirname $0)
for i in `seq 1 $count`;
do 
	printf "==== %4d" $i 
	bash stabilityTester.sh
done
popd
