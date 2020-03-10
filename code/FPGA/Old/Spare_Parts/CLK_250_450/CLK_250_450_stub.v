// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Sun Oct 20 20:46:22 2019
// Host        : SOLIDWORKS-VM running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top CLK_250_450 -prefix
//               CLK_250_450_ CLK_250_450_stub.v
// Design      : CLK_250_450
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a15tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module CLK_250_450(clk_450, clk_250)
/* synthesis syn_black_box black_box_pad_pin="clk_450,clk_250" */;
  output clk_450;
  input clk_250;
endmodule
