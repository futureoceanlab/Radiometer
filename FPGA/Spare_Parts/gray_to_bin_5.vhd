----------------------------------------------------------------------------------
--
-- Description: Convert 5-bit gray code to binary
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity gray_to_bin_5 is
    Port ( gray : in  STD_LOGIC_VECTOR (4 downto 0);
           binary : out  STD_LOGIC_VECTOR (4 downto 0));
end gray_to_bin_5;

architecture Behavioral of gray_to_bin_5 is

begin

process(gray)
   begin
      case gray is 
         when "00000" => binary <= "00000";
         when "00001" => binary <= "00001";
         when "00011" => binary <= "00010";
         when "00010" => binary <= "00011";
         when "00110" => binary <= "00100";
         when "00111" => binary <= "00101";
         when "00101" => binary <= "00110";
         when "00100" => binary <= "00111";
         when "01100" => binary <= "01000";
         when "01101" => binary <= "01001";
         when "01111" => binary <= "01010";
         when "01110" => binary <= "01011";
         when "01010" => binary <= "01100";
         when "01011" => binary <= "01101";
         when "01001" => binary <= "01110";
         when "01000" => binary <= "01111";
         when "11000" => binary <= "10000";
         when "11001" => binary <= "10001";
         when "11011" => binary <= "10010";
         when "11010" => binary <= "10011";
         when "11110" => binary <= "10100";
         when "11111" => binary <= "10101";
         when "11101" => binary <= "10110";
         when "11100" => binary <= "10111";
         when "10100" => binary <= "11000";
         when "10101" => binary <= "11001";
         when "10111" => binary <= "11010";
         when "10110" => binary <= "11011";
         when "10010" => binary <= "11100";
         when "10011" => binary <= "11101";
         when "10001" => binary <= "11110";
         when others  => binary <= "11111";
      end case;
   end process;

end Behavioral;
