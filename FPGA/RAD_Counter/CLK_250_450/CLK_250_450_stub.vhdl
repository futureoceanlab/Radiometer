-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
-- Date        : Sat Oct 19 22:03:28 2019
-- Host        : SOLIDWORKS-VM running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub z:/FPGA/RAD_Counter/CLK_250_450/CLK_250_450_stub.vhdl
-- Design      : CLK_250_450
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a15tcpg236-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CLK_250_450 is
  Port ( 
    clk_450 : out STD_LOGIC;
    clk_250 : in STD_LOGIC
  );

end CLK_250_450;

architecture stub of CLK_250_450 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk_450,clk_250";
begin
end;
