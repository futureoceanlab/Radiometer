----------------------------------------------------------------------------------
-- Engineer: Mike Field <hamster@snap.net.nz>
--
-- Module Name:    output_uart - Behavioral 
--
-- Description: Send 9 decimal digits out an RS232 port
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity output_uart is
    Port ( clk         : in  STD_LOGIC;
           d8          : in  STD_LOGIC_VECTOR (3 downto 0);
           d7          : in  STD_LOGIC_VECTOR (3 downto 0);
           d6          : in  STD_LOGIC_VECTOR (3 downto 0);
           d5          : in  STD_LOGIC_VECTOR (3 downto 0);
           d4          : in  STD_LOGIC_VECTOR (3 downto 0);
           d3          : in  STD_LOGIC_VECTOR (3 downto 0);
           d2          : in  STD_LOGIC_VECTOR (3 downto 0);
           d1          : in  STD_LOGIC_VECTOR (3 downto 0);
           d0          : in  STD_LOGIC_VECTOR (3 downto 0);
           new_decimal : in  STD_LOGIC;
           tx          : out STD_LOGIC);
end output_uart;

architecture Behavioral of output_uart is
   signal sr : std_logic_vector(128 downto 0) := (others => '1');
   signal count : unsigned(12 downto 0);
begin

process(clk)
   begin
      if rising_edge(clk) then
         if count = 32000000/19200-1 then
            tx <= sr(0);
            sr <= '1' & sr(sr'high downto 1);
            count <= (others => '0');
         else
            count <= count + 1;
         end if;
         
         if new_decimal = '1' then
            sr <=  "000011010" &   -- Carriage return
                  "1000010100" &   -- Line Feed
                  "10011" & d0 & "0" &
                  "10011" & d1 & "0" &
                  "10011" & d2 & "0" &
                  "1001011000" &   -- comma
                  "10011" & d3 & "0" &
                  "10011" & d4 & "0" &
                  "10011" & d5 & "0" &
                  "1001011000" &   -- comma
                  "10011" & d6 & "0" &
                  "10011" & d7 & "0" &
                  "10011" & d8 & "0";
         end if;
      end if;
   end process;
end Behavioral;