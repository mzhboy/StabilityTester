#!/bin/bash
sudo apt install libopenblas-dev libatlas-base-dev libmpich-dev gfortran
wget http://www.netlib.org/benchmark/hpl/hpl-2.3.tar.gz
tar -zxvf hpl-2.3.tar.gz
cd hpl-2.3
./configure && \
make && make install-strip
