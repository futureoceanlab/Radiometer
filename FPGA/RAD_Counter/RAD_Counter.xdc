## This file is a general .xdc for the CmodA7 rev. B
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

# Cmod A7 on-board 12 MHz Clock
set_property -dict { PACKAGE_PIN L17   IOSTANDARD LVCMOS33 } [get_ports { sysclk }]; #IO_L12P_T1_MRCC_14 Sch=gclk
create_clock -add -name sys_clk_pin -period 83.33 -waveform {0 41.66} [get_ports {sysclk}];

#   HIN, DTog, T_ON, PING
set_property -dict { PACKAGE_PIN W2    IOSTANDARD LVCMOS33 } [get_ports { HIN }];		#IO_L5N_T0_34 Sch=pio[32]
set_property -dict { PACKAGE_PIN V8    IOSTANDARD LVCMOS33 } [get_ports { DTOG }];	#IO_L14N_T2_SRCC_34 Sch=pio[48]
set_property -dict { PACKAGE_PIN J3    IOSTANDARD LVCMOS33 } [get_ports { T_ON }];	#IO_L7P_T1_AD6P_35 Sch=pio[10]
set_property -dict { PACKAGE_PIN U8    IOSTANDARD LVCMOS33 } [get_ports { PING }];	#IO_L14P_T2_SRCC_34 Sch=pio[47]

#  Ns_Sel[0:2]
set_property -dict { PACKAGE_PIN A14   IOSTANDARD LVCMOS33 } [get_ports { Ns_SEL[0] }];	#IO_L6P_T0_16 Sch=pio[09]
set_property -dict { PACKAGE_PIN B15   IOSTANDARD LVCMOS33 } [get_ports { Ns_SEL[1] }]; 	#IO_L11N_T1_SRCC_16 Sch=pio[08]
set_property -dict { PACKAGE_PIN C15   IOSTANDARD LVCMOS33 } [get_ports { Ns_SEL[2] }]; 	#IO_L11P_T1_SRCC_16 Sch=pio[05]

# Data[0:15]
set_property -dict { PACKAGE_PIN W5    IOSTANDARD LVCMOS33 } [get_ports { DATA[0] }];	#IO_L12P_T1_MRCC_34 Sch=pio[36]
set_property -dict { PACKAGE_PIN T1    IOSTANDARD LVCMOS33 } [get_ports { DATA[1] }]; 	#IO_L3P_T0_DQS_34 Sch=pio[29]
set_property -dict { PACKAGE_PIN R2    IOSTANDARD LVCMOS33 } [get_ports { DATA[2] }]; 	#IO_L1P_T0_34 Sch=pio[28]
set_property -dict { PACKAGE_PIN L2    IOSTANDARD LVCMOS33 } [get_ports { DATA[3] }]; 	#IO_L5N_T0_AD13N_35 Sch=pio[14]
set_property -dict { PACKAGE_PIN L1    IOSTANDARD LVCMOS33 } [get_ports { DATA[4] }]; 	#IO_L6N_T0_VREF_35 Sch=pio[13]
set_property -dict { PACKAGE_PIN U4    IOSTANDARD LVCMOS33 } [get_ports { DATA[5] }]; 	#IO_L11P_T1_SRCC_34 Sch=pio[38]
set_property -dict { PACKAGE_PIN K2    IOSTANDARD LVCMOS33 } [get_ports { DATA[6] }]; 	#IO_L5P_T0_AD13P_35 Sch=pio[12]
set_property -dict { PACKAGE_PIN J1    IOSTANDARD LVCMOS33 } [get_ports { DATA[7] }]; 	#IO_L3N_T0_DQS_AD5N_35 Sch=pio[11]
set_property -dict { PACKAGE_PIN N1    IOSTANDARD LVCMOS33 } [get_ports { DATA[8] }]; 	#IO_L10N_T1_AD15N_35 Sch=pio[21]
set_property -dict { PACKAGE_PIN V4    IOSTANDARD LVCMOS33 } [get_ports { DATA[9] }]; #IO_L11N_T1_SRCC_34 Sch=pio[37]
set_property -dict { PACKAGE_PIN N3    IOSTANDARD LVCMOS33 } [get_ports { DATA[10] }]; #IO_L12P_T1_MRCC_35 Sch=pio[18]
set_property -dict { PACKAGE_PIN M1    IOSTANDARD LVCMOS33 } [get_ports { DATA[11] }]; #IO_L9N_T1_DQS_AD7N_35 Sch=pio[17]
set_property -dict { PACKAGE_PIN P3    IOSTANDARD LVCMOS33 } [get_ports { DATA[12] }]; #IO_L12N_T1_MRCC_35 Sch=pio[19]
set_property -dict { PACKAGE_PIN U1    IOSTANDARD LVCMOS33 } [get_ports { DATA[13] }]; #IO_L3N_T0_DQS_34 Sch=pio[31]
set_property -dict { PACKAGE_PIN T2    IOSTANDARD LVCMOS33 } [get_ports { DATA[14] }]; #IO_L1N_T0_34 Sch=pio[30]
set_property -dict { PACKAGE_PIN M2    IOSTANDARD LVCMOS33 } [get_ports { DATA[15] }]; #IO_L9P_T1_DQS_AD7P_35 Sch=pio[20]
