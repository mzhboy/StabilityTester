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
Cooling down599 	CPU Freq: 480000 	CPU Core: 880000 	
Testing frequency 720000
Cooling down875 	CPU Freq: 720000 	CPU Core: 880000 	
Testing frequency 816000
Cooling down211 	CPU Freq: 816000 	CPU Core: 880000 	
Testing frequency 888000
Cooling down690 	CPU Freq: 888000 	CPU Core: 880000 	
Testing frequency 1080000
Cooling down488 	CPU Freq: 1080000 	CPU Core: 880000 	
Testing frequency 1320000
Cooling down705 	CPU Freq: 1320000 	CPU Core: 880000 	
Testing frequency 1488000
Cooling down176 	CPU Freq: 1488000 	CPU Core: 900000 	
Testing frequency 1640000
Cooling down184 	CPU Freq: 1640000 	CPU Core: 940000 	
Testing frequency 1800000
Cooling down559 	CPU Freq: 1800000 	CPU Core: 990000 	

Done testing stability:
Frequency: 480000	Voltage: 880000	Success: 1	Result:   6.02877859e-03
Frequency: 720000	Voltage: 880000	Success: 1	Result:   6.02877859e-03
Frequency: 816000	Voltage: 880000	Success: 1	Result:   6.02877859e-03
Frequency: 888000	Voltage: 880000	Success: 1	Result:   6.02877859e-03
Frequency: 1080000	Voltage: 880000	Success: 1	Result:   6.02877859e-03
Frequency: 1320000	Voltage: 880000	Success: 1	Result:   6.02877859e-03
Frequency: 1488000	Voltage: 900000	Success: 1	Result:   6.02877859e-03
Frequency: 1640000	Voltage: 940000	Success: 1	Result:   6.02877859e-03
Frequency: 1800000	Voltage: 990000	Success: 1	Result:   6.02877859e-03
```