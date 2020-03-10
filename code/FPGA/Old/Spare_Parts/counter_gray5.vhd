----------------------------------------------------------------------------------
--
-- Description: Count rising edges, and output as a Gray count.
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity counter_gray5 is
  generic (
    N : natural := 5;
       -- Total Counter bits. 5 bits get output as gray codes, with N-5
       -- rolling over as prescaling bits.
    );
  Port (
    VIN : in  STD_LOGIC; -- Data in
--    EN  : in  STD_LOGIC; -- For cascading
--    RST : in  STD_LOGIC; -- Synchronous reset: Clear on next CLK.
--    TC  : out STD_LOGIC; -- Announce overflow
    GRAY : out  STD_LOGIC_VECTOR (4 downto 0); -- Gray code out
    );
end counter_gray5;


architecture Behavioral of counter_gray5 is
  signal count : STD_LOGIC_VECTOR (N-1 downto 0) := (others => '0');
begin
  process(VIN)
   begin
      if rising_edge(VIN) then
         -- convert the binary counter into the gray encoded output
         case count(N-1 downto N-5) is 
            when "00000" => GRAY <= "00000";
            when "00001" => GRAY <= "00001";
            when "00010" => GRAY <= "00011";
            when "00011" => GRAY <= "00010";
            when "00100" => GRAY <= "00110";
            when "00101" => GRAY <= "00111";
            when "00110" => GRAY <= "00101";
            when "00111" => GRAY <= "00100";
            when "01000" => GRAY <= "01100";
            when "01001" => GRAY <= "01101";
            when "01010" => GRAY <= "01111";
            when "01011" => GRAY <= "01110";
            when "01100" => GRAY <= "01010";
            when "01101" => GRAY <= "01011";
            when "01110" => GRAY <= "01001";
            when "01111" => GRAY <= "01000";
            when "10000" => GRAY <= "11000";
            when "10001" => GRAY <= "11001";
            when "10010" => GRAY <= "11011";
            when "10011" => GRAY <= "11010";
            when "10100" => GRAY <= "11110";
            when "10101" => GRAY <= "11111";
            when "10110" => GRAY <= "11101";
            when "10111" => GRAY <= "11100";
            when "11000" => GRAY <= "10100";
            when "11001" => GRAY <= "10101";
            when "11010" => GRAY <= "10111";
            when "11011" => GRAY <= "10110";
            when "11100" => GRAY <= "10010";
            when "11101" => GRAY <= "10011";
            when "11110" => GRAY <= "10001";
            when others  => GRAY <= "10000";
         end case;
         -- advance the counter
         count <= count + 1;
      end if;
   end process;
end Behavioral;
