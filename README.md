# StabilityTester

This tool runs through every frequency available using xhpl.

The binary xhpl64 is for arm v8 isa. To run xhpl on different platform, you need build xhpl first.

To build xhpl, just run `sudo bash build_hpl.sh`.

For optimal result you need to alter the cooling table to allow you to select all the frequencies up to 90C.

To run multiple times(10), use this command

```bash
for i in $(seq 1 10);do sudo bash stabilityTester.sh;done
```

result on `orangepi lite2`

```
Testing frequency 480000
Cooling down361         CPU Freq: 480000        CPU Core: 880000
Testing frequency 720000
Cooling down966         CPU Freq: 720000        CPU Core: 880000
Testing frequency 816000
Cooling down504         CPU Freq: 816000        CPU Core: 880000
Testing frequency 888000
Cooling down907         CPU Freq: 888000        CPU Core: 880000
Testing frequency 1080000
Cooling down176         CPU Freq: 1080000       CPU Core: 900000
Testing frequency 1320000
Cooling down856         CPU Freq: 1320000       CPU Core: 920000
Testing frequency 1488000
Cooling down200         CPU Freq: 1488000       CPU Core: 930000
Testing frequency 1640000
Cooling down358         CPU Freq: 1640000       CPU Core: 950000
Testing frequency 1800000
Cooling down777         CPU Freq: 1800000       CPU Core: 1000000

Done testing stability:
Frequency: 480 MHz      Voltage:  880 mV        Success: 1      Gflops: 1.3138e+00
Frequency: 720 MHz      Voltage:  880 mV        Success: 1      Gflops: 1.5288e+00
Frequency: 816 MHz      Voltage:  880 mV        Success: 1      Gflops: 1.5738e+00
Frequency: 888 MHz      Voltage:  880 mV        Success: 1      Gflops: 1.5415e+00
Frequency: 1080 MHz     Voltage:  900 mV        Success: 1      Gflops: 1.6388e+00
Frequency: 1320 MHz     Voltage:  920 mV        Success: 1      Gflops: 1.6771e+00
Frequency: 1488 MHz     Voltage:  930 mV        Success: 1      Gflops: 1.6665e+00
Frequency: 1640 MHz     Voltage:  950 mV        Success: 1      Gflops: 1.7131e+00
Frequency: 1800 MHz     Voltage:  1000 mV       Success: 1      Gflops: 1.7101e+00
```