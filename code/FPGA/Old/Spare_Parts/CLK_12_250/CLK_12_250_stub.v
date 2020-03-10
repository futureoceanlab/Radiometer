// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Sat Oct 19 15:29:54 2019
// Host        : SOLIDWORKS-VM running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub z:/FPGA/RAD_Counter/CLK_12_250/CLK_12_250_stub.v
// Design      : CLK_12_250
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a15tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module CLK_12_250(clk_250, clk_12)
/* synthesis syn_black_box black_box_pad_pin="clk_250,clk_12" */;
  output clk_250;
  input clk_12;
endmodule
