----------------------------------------------------------------------------------
--     MIT Future Ocean Lab
----------------------------------------------------------------------------------
-- Project:       FOL Radiometer
-- Version:       Beebe
-- Design:        RAD_Counter_SERDES
-- Substrate:     CMod A7 
----------------------------------------------------------------------------------
-- Module:        RAD_Counter (Behavioral)
-- Filename:      RAD_Counter.vhd
-- Created:       18/8/2019
-- Author:        Allan Adams <awa@mit.edu>
-- Guru:          Mike Field <hamster@snap.net.nz>  <=  Many props and thanks!!!
----------------------------------------------------------------------------------
-- Description:   This project counts pulses from a fast source and estimates
--                the area under the curve.  The input signal is a random train
--                of 20+ns pulses (<50MHz).  We need to count these pulses and
--                also estimate what fraction of the time the signal is high.
--                We sample the signal via 4:1 ISERDES running at 250MHz, giving
--                a 1GHz bitstream-sample of the incoming signal.  We then count
--                ones in the stream to estimate time-high, and detect 16+ns long
--                pulses with a simple edge detector.  A running tally is kept of 
--                both counts.  Count-changes are output over a 16-bit bus 
--                (DATA_OUT) along with a pulse (PING_OUT) at a user-selectable 
--                rate (NS_SEL_IN), with a binary input (DTOG_IN) gating a mux
--                controlling which count appears on the bus.  The time-high 
--                count is prescaled by 4 bits to avoid overflowing the bus.
--
-- Dependencies: 
-- 
-- Issues:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity total_counters is
    Port ( clk         : in  STD_LOGIC;
           edges       : in  STD_LOGIC;
           ones        : in  STD_LOGIC_VECTOR (2 downto 0);
           reset       : in  STD_LOGIC;
           total_edges : out STD_LOGIC_VECTOR (23 downto 0) := (others => '0');
           total_ones  : out STD_LOGIC_VECTOR (23 downto 0) := (others => '0'));
end total_counters;

architecture Behavioral of total_counters is

  signal t_edges : unsigned(23 downto 0) := (others => '0');
  signal t_ones  : unsigned(23 downto 0) := (others => '0');
  
  begin

  total_edges <= std_logic_vector(t_edges);
  total_ones  <= std_logic_vector(t_ones);

  process (clk)
  begin
    if rising_edge(clk) then
      if reset = '0' then
        t_ones   <= t_ones  + unsigned(ones);
        if edges = '1' then 
          t_edges <= t_edges + 1; 
        end if; -- edge = '1'
      else
        t_edges <=  (others => '0');
        t_ones  <=  (others => '0');
      end if;
    end if; -- rising_edge(clk)
  end process; -- clk
end Behavioral;
