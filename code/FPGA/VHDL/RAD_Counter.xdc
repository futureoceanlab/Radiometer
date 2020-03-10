## This file is a general .xdc for the CmodA7 rev. B
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project



## Timing Assertions Section

  # Primary clocks

    # Cmod A7 on-board 12 MHz Clock
set_property -dict {PACKAGE_PIN L17 IOSTANDARD LVCMOS33} [get_ports sysclk]
create_clock -period 83.330 -name sys_clk_pin -waveform {0.000 41.660} -add [get_ports sysclk]

  # Virtual clocks
  # Generated clocks

#create_clock -period 20.000 -name HAM_IN -waveform {0.000 10.000} [get_ports HAM_IN]
#create_generated_clock -name RadClock/I -source [get_ports sysclk] -divide_by 3 [get_pins RadClock/CLK_4_raw_reg__0/Q]

#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets HAM_IN_IBUF];

#create_generated_clock -name RadClock/ping_fall -source [get_ports sysclk] -divide_by 1 [get_pins RadClock/ping_fall_reg/Q]
#create_generated_clock -name RadClock/ping_rise -source [get_ports sysclk] -divide_by 1 [get_pins RadClock/ping_rise_reg/Q]


  # Clock Groups
  # Bus Skew constraints
  # Input and output delay constraints


## Timing Exceptions Section
  # False Paths
  # Max Delay / Min Delay
  # Multicycle Paths
  # Case Analysis
  # Disable Timing


## Physical Constraints Section
  # located anywhere in the file, preferably before or after the timing constraints
  # or stored in a separate constraint file

## LEDs
set_property -dict {PACKAGE_PIN A17 IOSTANDARD LVCMOS33} [get_ports { LEDL[0] }]; #IO_L12N_T1_MRCC_16 Sch=led[1]
set_property -dict {PACKAGE_PIN C16 IOSTANDARD LVCMOS33} [get_ports { LEDL[1] }]; #IO_L13P_T2_MRCC_16 Sch=led[2]
set_property -dict {PACKAGE_PIN B17 IOSTANDARD LVCMOS33} [get_ports { LEDH[0] }]; #IO_L14N_T2_SRCC_16 Sch=led0_b
set_property -dict {PACKAGE_PIN B16 IOSTANDARD LVCMOS33} [get_ports { LEDH[1] }]; #IO_L13N_T2_MRCC_16 Sch=led0_g
set_property -dict {PACKAGE_PIN C17 IOSTANDARD LVCMOS33} [get_ports { LEDH[2] }]; #IO_L14P_T2_SRCC_16 Sch=led0_r

#  INPUTS:  
#          HAM_IN, DTOG_IN, RESET_IN, KILLT_IN
set_property -dict {PACKAGE_PIN W2  IOSTANDARD LVCMOS33} [get_ports HAM_IN]       
set_property -dict {PACKAGE_PIN V8  IOSTANDARD LVCMOS33} [get_ports DTOG_IN]    
set_property -dict {PACKAGE_PIN W3  IOSTANDARD LVCMOS33} [get_ports RESET_IN]   
set_property -dict {PACKAGE_PIN V3  IOSTANDARD LVCMOS33} [get_ports KILLT_IN]   
#          Ns_Sel[0:2]
set_property -dict {PACKAGE_PIN A14 IOSTANDARD LVCMOS33} [get_ports {NS_SEL_IN[0]}]
set_property -dict {PACKAGE_PIN B15 IOSTANDARD LVCMOS33} [get_ports {NS_SEL_IN[1]}]
set_property -dict {PACKAGE_PIN C15 IOSTANDARD LVCMOS33} [get_ports {NS_SEL_IN[2]}]

#  OUTPUTS:
#          TPWR_OUT, PING_OUT
set_property -dict {PACKAGE_PIN J3 IOSTANDARD LVCMOS33} [get_ports TPWR_OUT]    
set_property -dict {PACKAGE_PIN U8 IOSTANDARD LVCMOS33} [get_ports PING_OUT]    
#          DATA_OUT[0:15]
set_property -dict {PACKAGE_PIN W5 IOSTANDARD LVCMOS33} [get_ports {DATA_OUT[0]}]
set_property -dict {PACKAGE_PIN T1 IOSTANDARD LVCMOS33} [get_ports {DATA_OUT[1]}]
set_property -dict {PACKAGE_PIN R2 IOSTANDARD LVCMOS33} [get_ports {DATA_OUT[2]}]
set_property -dict {PACKAGE_PIN L2 IOSTANDARD LVCMOS33} [get_ports {DATA_OUT[3]}]
set_property -dict {PACKAGE_PIN L1 IOSTANDARD LVCMOS33} [get_ports {DATA_OUT[4]}]
set_property -dict {PACKAGE_PIN U4 IOSTANDARD LVCMOS33} [get_ports {DATA_OUT[5]}]
set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS33} [get_ports {DATA_OUT[6]}]
set_property -dict {PACKAGE_PIN J1 IOSTANDARD LVCMOS33} [get_ports {DATA_OUT[7]}]
set_property -dict {PACKAGE_PIN N1 IOSTANDARD LVCMOS33} [get_ports {DATA_OUT[8]}]
set_property -dict {PACKAGE_PIN V4 IOSTANDARD LVCMOS33} [get_ports {DATA_OUT[9]}]
set_property -dict {PACKAGE_PIN N3 IOSTANDARD LVCMOS33} [get_ports {DATA_OUT[10]}]
set_property -dict {PACKAGE_PIN M1 IOSTANDARD LVCMOS33} [get_ports {DATA_OUT[11]}]
set_property -dict {PACKAGE_PIN P3 IOSTANDARD LVCMOS33} [get_ports {DATA_OUT[12]}]
set_property -dict {PACKAGE_PIN U1 IOSTANDARD LVCMOS33} [get_ports {DATA_OUT[13]}]
set_property -dict {PACKAGE_PIN T2 IOSTANDARD LVCMOS33} [get_ports {DATA_OUT[14]}]
set_property -dict {PACKAGE_PIN M2 IOSTANDARD LVCMOS33} [get_ports {DATA_OUT[15]}]


set_property SLEW SLOW [get_ports {DATA_OUT[15]}]
set_property SLEW SLOW [get_ports {DATA_OUT[14]}]
set_property SLEW SLOW [get_ports {DATA_OUT[13]}]
set_property SLEW SLOW [get_ports {DATA_OUT[12]}]
set_property SLEW SLOW [get_ports {DATA_OUT[11]}]
set_property SLEW SLOW [get_ports {DATA_OUT[10]}]
set_property SLEW SLOW [get_ports {DATA_OUT[9]}]
set_property SLEW SLOW [get_ports {DATA_OUT[8]}]
set_property SLEW SLOW [get_ports {DATA_OUT[7]}]
set_property SLEW SLOW [get_ports {DATA_OUT[6]}]
set_property SLEW SLOW [get_ports {DATA_OUT[5]}]
set_property SLEW SLOW [get_ports {DATA_OUT[4]}]
set_property SLEW SLOW [get_ports {DATA_OUT[3]}]
set_property SLEW SLOW [get_ports {DATA_OUT[2]}]
set_property SLEW SLOW [get_ports {DATA_OUT[1]}]
set_property SLEW SLOW [get_ports {DATA_OUT[0]}]
