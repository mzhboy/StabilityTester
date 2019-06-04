#!/bin/bash
pushd .
HPL=hpl-2.3
sudo apt install libopenblas-dev libatlas-base-dev libmpich-dev gfortran
wget http://www.netlib.org/benchmark/hpl/${HPL}.tar.gz
tar -zxvf ${HPL}.tar.gz
cd $HPL
./configure && \
make && make install-strip
popd
