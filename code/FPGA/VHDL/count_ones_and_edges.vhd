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

entity count_ones_and_edges is
    Port ( clk     : in  STD_LOGIC;
           sample  : in  STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
           ones    : out STD_LOGIC_VECTOR (2 downto 0) := (others => '0');
           edges   : out STD_LOGIC                     := '0');
end count_ones_and_edges;

architecture Behavioral of count_ones_and_edges is
    signal last_sample  : std_logic_vector (3 downto 0) := (others => '0');
    signal was_high     : std_logic := '0';
begin

process(clk)
    begin
        if rising_edge(clk) then
            case sample is
                when "0000" => ones <= "000"; --
--
                when "0001" => ones <= "001";
                when "0010" => ones <= "001";
                when "0100" => ones <= "001";
                when "1000" => ones <= "001";
--
                when "0011" => ones <= "010"; --
                when "0101" => ones <= "010";
                when "1001" => ones <= "010";
                when "0110" => ones <= "010";
                when "1010" => ones <= "010";
                when "1100" => ones <= "010"; --
--
                when "0111" => ones <= "011";
                when "1011" => ones <= "011";
                when "1101" => ones <= "011";
                when "1110" => ones <= "011";
--
                when others => ones <= "100"; --
            end case;
            
            case sample & last_sample is
              when "00111111" =>
                edges     <= not was_high;
                was_high  <= '1';
              when "01111111" =>
                  edges     <= not was_high;
                  was_high  <= '1';
              when "11111111" =>
                    edges     <= not was_high;
                    was_high  <= '1';
              when others => 
                edges     <= '0';
                was_high  <= '0';
            end case;
            
            last_sample <= sample;
            
        end if;
    end process;

end Behavioral;