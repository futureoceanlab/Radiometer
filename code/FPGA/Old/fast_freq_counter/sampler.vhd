----------------------------------------------------------------------------------
-- Engineer: Mike Field <hamster@snap.net.nz>
-- 
-- Module Name:    sampler - Behavioral 
--
-- Description: Sample the graycode count and convert back to binary
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity sampler is
    Port ( clk        : in  STD_LOGIC;
           gray_count : in  STD_LOGIC_VECTOR (4 downto 0);
           jump       : out STD_LOGIC_VECTOR (4 downto 0));
end sampler;

architecture Behavioral of sampler is
	COMPONENT gray_to_bin
	PORT(
		gray : IN std_logic_vector(4 downto 0);          
		binary : OUT std_logic_vector(4 downto 0)
		);
	END COMPONENT;

   signal samples : std_logic_vector(19 downto 0) := (others => '0');
   signal last    : std_logic_vector(4 downto 0);          
   signal recent  : std_logic_vector(4 downto 0);          
begin

gray_to_bin_last: gray_to_bin PORT MAP(
		gray   => samples(19 downto 15),
		binary => last
	);
   
gray_to_bin_recent: gray_to_bin PORT MAP(
		gray   => samples(14 downto 10),
		binary => recent
	);
   

process(clk)
   begin
      if rising_edge(clk) then
         jump <= std_logic_vector(unsigned(recent) - unsigned(last));
         samples <= samples(14 downto 0) & gray_count;
      end if;
   end process;

end Behavioral;

