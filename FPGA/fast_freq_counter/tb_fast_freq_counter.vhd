--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:49:17 06/18/2014
-- Design Name:   
-- Module Name:   C:/Users/hamster/Projects/FPGA/fast_freq_counter/tb_fast_freq_counter.vhd
-- Project Name:  fast_freq_counter
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: fast_freq_counter
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_fast_freq_counter IS
END tb_fast_freq_counter;
 
ARCHITECTURE behavior OF tb_fast_freq_counter IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT fast_freq_counter
    PORT(
         clk32 : IN  std_logic;
         test_signal : IN  std_logic;
         count : OUT  std_logic_vector(29 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk32 : std_logic := '0';
   signal test_signal : std_logic := '0';

 	--Outputs
   signal count : std_logic_vector(29 downto 0);

   -- Clock period definitions
   constant clk32_period       : time := 31.15 ns;
   constant test_signal_period : time := 2.55 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: fast_freq_counter PORT MAP (
          clk32 => clk32,
          test_signal => test_signal,
          count => count
        );

   -- Clock process definitions
   clk32_process :process
   begin
		clk32 <= '0';
		wait for clk32_period/2;
		clk32 <= '1';
		wait for clk32_period/2;
   end process;
 
   test_signal_process :process
   begin
		test_signal <= '0';
		wait for test_signal_period/2;
		test_signal <= '1';
		wait for test_signal_period/2;
   end process;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk32_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
