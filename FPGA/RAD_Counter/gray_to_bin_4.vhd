----------------------------------------------------------------------------------
--
-- Description: Convert 4-bit gray code to binary
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity gray_to_bin_4 is
    Port ( gray : in  STD_LOGIC_VECTOR (3 downto 0);
           binary : out  STD_LOGIC_VECTOR (3 downto 0));
end gray_to_bin_4;

architecture Behavioral of gray_to_bin_4 is

begin

process(gray)
   begin
      case gray is 
         when "0000" => binary <= "0000";
         when "0001" => binary <= "0001";
         when "0011" => binary <= "0010";
         when "0010" => binary <= "0011";
         when "0110" => binary <= "0100";
         when "0111" => binary <= "0101";
         when "0101" => binary <= "0110";
         when "0100" => binary <= "0111";
         when "1100" => binary <= "1000";
         when "1101" => binary <= "1001";
         when "1111" => binary <= "1010";
         when "1110" => binary <= "1011";
         when "1010" => binary <= "1100";
         when "1011" => binary <= "1101";
         when "1001" => binary <= "1110";
         when "1000" => binary <= "1111";
         when others => report "unreachable" severity failure;
      end case;
   end process;

end Behavioral;
