----------------------------------------------------------------------------------
-- Engineer: Mike Field <hamster@snap.net.nz>
-- 
-- Module Name:    input_counter - Behavioral 
--
-- Description: Count rising edges, and output as a Gray count.
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity input_counter is
    Port ( test_signal : in  STD_LOGIC;
           gray_count : out  STD_LOGIC_VECTOR (4 downto 0));
end input_counter;

architecture Behavioral of input_counter is
   signal counter : unsigned(4 downto 0) := (others => '0');
begin

process(test_signal)
   begin
      if rising_edge(test_signal) then
         -- convert the binary counter into the gray encoded output
         case counter is 
            when "00000" => gray_count <= "00000";
            when "00001" => gray_count <= "00001";
            when "00010" => gray_count <= "00011";
            when "00011" => gray_count <= "00010";
            when "00100" => gray_count <= "00110";
            when "00101" => gray_count <= "00111";
            when "00110" => gray_count <= "00101";
            when "00111" => gray_count <= "00100";
            when "01000" => gray_count <= "01100";
            when "01001" => gray_count <= "01101";
            when "01010" => gray_count <= "01111";
            when "01011" => gray_count <= "01110";
            when "01100" => gray_count <= "01010";
            when "01101" => gray_count <= "01011";
            when "01110" => gray_count <= "01001";
            when "01111" => gray_count <= "01000";
            when "10000" => gray_count <= "11000";
            when "10001" => gray_count <= "11001";
            when "10010" => gray_count <= "11011";
            when "10011" => gray_count <= "11010";
            when "10100" => gray_count <= "11110";
            when "10101" => gray_count <= "11111";
            when "10110" => gray_count <= "11101";
            when "10111" => gray_count <= "11100";
            when "11000" => gray_count <= "10100";
            when "11001" => gray_count <= "10101";
            when "11010" => gray_count <= "10111";
            when "11011" => gray_count <= "10110";
            when "11100" => gray_count <= "10010";
            when "11101" => gray_count <= "10011";
            when "11110" => gray_count <= "10001";
            when others  => gray_count <= "10000";
         end case;
         -- advance the counter
         counter <= counter+1;
      end if;
   end process;
end Behavioral;