----------------------------------------------------------------------------------
-- Engineer: Mike Field <hamster@snap.net.nz>
-- 
-- Module Name:    accumulator - Behavioral 
--
-- Description: Accumulate 32,000,000 5-bit values
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity accumulator is
    Port ( clk       : in  STD_LOGIC;
           jump      : in  STD_LOGIC_VECTOR (4 downto 0);
           total     : out STD_LOGIC_VECTOR (29 downto 0);
           new_total : out STD_LOGIC);
end accumulator;

architecture Behavioral of accumulator is
   signal i : unsigned(24 downto 0) := (others => '0');
   signal t : unsigned(29 downto 0) := (others => '0');
begin
   
process(clk)
   begin
      if rising_edge(clk) then
         -- has a second past?
         if i = 31999999 then
            -- yep - output the total
            total <= std_logic_vector(t);
            new_total <= '1';
            t <= (others => '0');
            t(4 downto 0) <= unsigned(jump);
            i <= (others => '0');
         else
            -- nope - keep accumulating
            new_total <= '0';
            t <= t + unsigned(jump);
            i <= i + 1;
         end if;
      end if;
   end process;

end Behavioral;

