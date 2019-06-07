# StabilityTester

This tool runs through every frequency available using xhpl.

The binary xhpl64 is for arm v8 isa. To run xhpl on different platform, you need build xhpl first.

To build xhpl, just run `sudo bash build_hpl.sh`.

Run once `stabilityTester.sh`

To run multiple times(10), use this command

```bash
./runbench.sh
```

100 times

```
./runbench.sh 100
```

**find out failed**
run `./runbench.sh 100` in byobu or tmux session, after finished run `grep 'Success: 0' result.log`.

```
Frequency: 1640 MHz	Voltage:  930 mV	Success: 0	Gflops: 1.6599e+00
Frequency: 1640 MHz	Voltage:  930 mV	Success: 0	Gflops: 1.6616e+00
Frequency: 1800 MHz	Voltage:  990 mV	Success: 0	Gflops: 1.6921e+00
Frequency: 1800 MHz	Voltage:  990 mV	Success: 0	Gflops: 1.6775e+00
Frequency: 1640 MHz	Voltage:   940 mV	Success: 0	Gflops: 1.6845e+00
Frequency: 1640 MHz	Voltage:   940 mV	Success: 0	Gflops: 1.6882e+00
```

**turn off others cpu hungary program like rpimonitor(perl script) to get accurate result**

*****

run `sudo bash build_hpl.sh` results on `orangepi lite2`

```
TEST Freq:  480 MHz	Soc temp:  35.21 ℃	CPU Freq:  480 MHz	CPU Core:  880 mV
TEST Freq:  720 MHz	Soc temp:  36.69 ℃	CPU Freq:  720 MHz	CPU Core:  880 mV
TEST Freq:  816 MHz	Soc temp:  38.10 ℃	CPU Freq:  816 MHz	CPU Core:  880 mV
TEST Freq:  888 MHz	Soc temp:  38.03 ℃	CPU Freq:  888 MHz	CPU Core:  880 mV
TEST Freq: 1080 MHz	Soc temp:  38.10 ℃	CPU Freq: 1080 MHz	CPU Core:  880 mV
TEST Freq: 1320 MHz	Soc temp:  39.58 ℃	CPU Freq: 1320 MHz	CPU Core:  880 mV
TEST Freq: 1488 MHz	Soc temp:  40.52 ℃	CPU Freq: 1488 MHz	CPU Core:  910 mV
TEST Freq: 1640 MHz	Soc temp:  44.35 ℃	CPU Freq: 1640 MHz	CPU Core:  950 mV
TEST Freq: 1800 MHz	Soc temp:  48.52 ℃	CPU Freq: 1800 MHz	CPU Core: 1000 mV

Done testing stability:	date: 20190607-065040
Frequency:  480 MHz	Voltage:   880 mV	Success: 1	Gflops: 1.1715e+00
Frequency:  720 MHz	Voltage:   880 mV	Success: 1	Gflops: 1.4029e+00
Frequency:  816 MHz	Voltage:   880 mV	Success: 1	Gflops: 1.4722e+00
Frequency:  888 MHz	Voltage:   880 mV	Success: 1	Gflops: 1.4991e+00
Frequency: 1080 MHz	Voltage:   880 mV	Success: 1	Gflops: 1.5201e+00
Frequency: 1320 MHz	Voltage:   880 mV	Success: 1	Gflops: 1.6035e+00
Frequency: 1488 MHz	Voltage:   910 mV	Success: 1	Gflops: 1.6242e+00
Frequency: 1640 MHz	Voltage:   950 mV	Success: 1	Gflops: 1.6043e+00
Frequency: 1800 MHz	Voltage:  1000 mV	Success: 1	Gflops: 1.6536e+00
```

-----

run `./runbench.sh 100` looks like

```
====   22
TEST Freq:  480 MHz     Soc temp:  39.85 ℃      CPU Freq:  480 MHz      CPU Core:  880 mV
TEST Freq:  720 MHz     Soc temp:  39.24 ℃      CPU Freq:  720 MHz      CPU Core:  880 mV
TEST Freq:  816 MHz     Soc temp:  40.59 ℃      CPU Freq:  816 MHz      CPU Core:  880 mV
TEST Freq:  888 MHz     Soc temp:  40.05 ℃      CPU Freq:  888 MHz      CPU Core:  880 mV
TEST Freq: 1080 MHz     Soc temp:  40.52 ℃      CPU Freq: 1080 MHz      CPU Core:  880 mV
TEST Freq: 1320 MHz     Soc temp:  41.39 ℃      CPU Freq: 1320 MHz      CPU Core:  880 mV
TEST Freq: 1488 MHz     Soc temp:  43.54 ℃      CPU Freq: 1488 MHz      CPU Core:  910 mV
TEST Freq: 1640 MHz     Soc temp:  44.42 ℃      CPU Freq: 1640 MHz      CPU Core:  950 mV
TEST Freq: 1800 MHz     Soc temp:  52.01 ℃      CPU Freq: 1800 MHz      CPU Core: 1010 mV

Done testing stability: date: 20190607-090823
Frequency:  480 MHz     Voltage:   880 mV       Success: 1      Gflops: 1.1843e+00
Frequency:  720 MHz     Voltage:   880 mV       Success: 1      Gflops: 1.4221e+00
Frequency:  816 MHz     Voltage:   880 mV       Success: 1      Gflops: 1.4613e+00
Frequency:  888 MHz     Voltage:   880 mV       Success: 1      Gflops: 1.4822e+00
Frequency: 1080 MHz     Voltage:   880 mV       Success: 1      Gflops: 1.5621e+00
Frequency: 1320 MHz     Voltage:   880 mV       Success: 1      Gflops: 1.6025e+00
Frequency: 1488 MHz     Voltage:   910 mV       Success: 1      Gflops: 1.6159e+00
Frequency: 1640 MHz     Voltage:   950 mV       Success: 1      Gflops: 1.6418e+00
Frequency: 1800 MHz     Voltage:  1010 mV       Success: 1      Gflops: 1.6501e+00
```