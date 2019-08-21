----------------------------------------------------------------------------------
-- Engineer: Mike Field <hamster@snap.net.nz>
-- 
-- Module Name:    binary_bcd - Behavioral 
--
-- Description: Convert binary value into into decimal digits
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity binary_bcd is
    Port ( clk         : in  STD_LOGIC;
           new_binary  : in  STD_LOGIC;
           binary      : in  STD_LOGIC_VECTOR (29 downto 0);
           d8          : out std_logic_vector(3 downto 0);
           d7          : out std_logic_vector(3 downto 0);
           d6          : out std_logic_vector(3 downto 0);
           d5          : out std_logic_vector(3 downto 0);
           d4          : out std_logic_vector(3 downto 0);
           d3          : out std_logic_vector(3 downto 0);
           d2          : out std_logic_vector(3 downto 0);
           d1          : out std_logic_vector(3 downto 0);
           d0          : out std_logic_vector(3 downto 0);
           new_decimal : out STD_LOGIC);
end binary_bcd;

architecture Behavioral of binary_bcd is
   signal busy : std_logic_vector(binary'high+1 downto 0);
   signal t8   : unsigned(3 downto 0);
   signal t7   : unsigned(3 downto 0);
   signal t6   : unsigned(3 downto 0);
   signal t5   : unsigned(3 downto 0);
   signal t4   : unsigned(3 downto 0);
   signal t3   : unsigned(3 downto 0);
   signal t2   : unsigned(3 downto 0);
   signal t1   : unsigned(3 downto 0);
   signal t0   : unsigned(3 downto 0);
   signal work : STD_LOGIC_VECTOR (binary'high downto 0);
   
begin

process(clk)
   begin
      if rising_edge(clk) then
         case t8 is
            when "0000" => t8 <= "0000";
            when "0001" => t8 <= "0010";
            when "0010" => t8 <= "0100";
            when "0011" => t8 <= "0110";
            when "0100" => t8 <= "1000";
            when "0101" => t8 <= "0000";
            when "0110" => t8 <= "0010";
            when "0111" => t8 <= "0100";
            when "1000" => t8 <= "0110";
            when "1001" => t8 <= "1000";
            when others => t8 <= "0000";
         end case;         
         if t7 > 4 then
            t8(0) <= '1';
         else
            t8(0) <= '0';
         end if;

         case t7 is
            when "0000" => t7 <= "0000";
            when "0001" => t7 <= "0010";
            when "0010" => t7 <= "0100";
            when "0011" => t7 <= "0110";
            when "0100" => t7 <= "1000";
            when "0101" => t7 <= "0000";
            when "0110" => t7 <= "0010";
            when "0111" => t7 <= "0100";
            when "1000" => t7 <= "0110";
            when "1001" => t7 <= "1000";
            when others => t7 <= "0000";
         end case;         
         if t6 > 4 then
            t7(0) <= '1';
         else
            t7(0) <= '0';
         end if;

         case t6 is
            when "0000" => t6 <= "0000";
            when "0001" => t6 <= "0010";
            when "0010" => t6 <= "0100";
            when "0011" => t6 <= "0110";
            when "0100" => t6 <= "1000";
            when "0101" => t6 <= "0000";
            when "0110" => t6 <= "0010";
            when "0111" => t6 <= "0100";
            when "1000" => t6 <= "0110";
            when "1001" => t6 <= "1000";
            when others => t6 <= "0000";
         end case;         
         if t5 > 4 then
            t6(0) <= '1';
         else
            t6(0) <= '0';
         end if;

         case t5 is
            when "0000" => t5 <= "0000";
            when "0001" => t5 <= "0010";
            when "0010" => t5 <= "0100";
            when "0011" => t5 <= "0110";
            when "0100" => t5 <= "1000";
            when "0101" => t5 <= "0000";
            when "0110" => t5 <= "0010";
            when "0111" => t5 <= "0100";
            when "1000" => t5 <= "0110";
            when "1001" => t5 <= "1000";
            when others => t5 <= "0000";
         end case;         
         if t4 > 4 then
            t5(0) <= '1';
         else
            t5(0) <= '0';
         end if;

         case t4 is
            when "0000" => t4 <= "0000";
            when "0001" => t4 <= "0010";
            when "0010" => t4 <= "0100";
            when "0011" => t4 <= "0110";
            when "0100" => t4 <= "1000";
            when "0101" => t4 <= "0000";
            when "0110" => t4 <= "0010";
            when "0111" => t4 <= "0100";
            when "1000" => t4 <= "0110";
            when "1001" => t4 <= "1000";
            when others => t4 <= "0000";
         end case;         
         if t3 > 4 then
            t4(0) <= '1';
         else
            t4(0) <= '0';
         end if;

         case t3 is
            when "0000" => t3 <= "0000";
            when "0001" => t3 <= "0010";
            when "0010" => t3 <= "0100";
            when "0011" => t3 <= "0110";
            when "0100" => t3 <= "1000";
            when "0101" => t3 <= "0000";
            when "0110" => t3 <= "0010";
            when "0111" => t3 <= "0100";
            when "1000" => t3 <= "0110";
            when "1001" => t3 <= "1000";
            when others => t3 <= "0000";
         end case;         
         if t2 > 4 then
            t3(0) <= '1';
         else
            t3(0) <= '0';
         end if;

         case t2 is
            when "0000" => t2 <= "0000";
            when "0001" => t2 <= "0010";
            when "0010" => t2 <= "0100";
            when "0011" => t2 <= "0110";
            when "0100" => t2 <= "1000";
            when "0101" => t2 <= "0000";
            when "0110" => t2 <= "0010";
            when "0111" => t2 <= "0100";
            when "1000" => t2 <= "0110";
            when "1001" => t2 <= "1000";
            when others => t2 <= "0000";
         end case;         
         if t1 > 4 then
            t2(0) <= '1';
         else
            t2(0) <= '0';
         end if;

         case t1 is
            when "0000" => t1 <= "0000";
            when "0001" => t1 <= "0010";
            when "0010" => t1 <= "0100";
            when "0011" => t1 <= "0110";
            when "0100" => t1 <= "1000";
            when "0101" => t1 <= "0000";
            when "0110" => t1 <= "0010";
            when "0111" => t1 <= "0100";
            when "1000" => t1 <= "0110";
            when "1001" => t1 <= "1000";
            when others => t1 <= "0000";
         end case;         
         if t0 > 4 then
            t1(0) <= '1';
         else
            t1(0) <= '0';
         end if;
         

         case t0 is
            when "0000" => t0 <= "0000";
            when "0001" => t0 <= "0010";
            when "0010" => t0 <= "0100";
            when "0011" => t0 <= "0110";
            when "0100" => t0 <= "1000";
            when "0101" => t0 <= "0000";
            when "0110" => t0 <= "0010";
            when "0111" => t0 <= "0100";
            when "1000" => t0 <= "0110";
            when "1001" => t0 <= "1000";
            when others => t0 <= "0000";
         end case;         
         t0(0) <= work(work'high);

         work <= work(work'high-1 downto 0) & '0';
         busy <= '0' & busy(busy'high downto 1);

         new_decimal <= '0';
         if busy(0) = '0' then
            -- start a new conversion
            if new_binary = '1' then
               t8   <= (others => '0');
               t7   <= (others => '0');
               t6   <= (others => '0');
               t5   <= (others => '0');
               t4   <= (others => '0');
               t3   <= (others => '0');
               t2   <= (others => '0');
               t1   <= (others => '0');
               t0   <= (others => '0');
               busy <= (others => '1');
               work <= binary;
            end if;
         else
            if busy(1) = '0' then
               -- conversion complete
               d8 <= std_logic_vector(t8);
               d7 <= std_logic_vector(t7);
               d6 <= std_logic_vector(t6);
               d5 <= std_logic_vector(t5);
               d4 <= std_logic_vector(t4);
               d3 <= std_logic_vector(t3);
               d2 <= std_logic_vector(t2);
               d1 <= std_logic_vector(t1);
               d0 <= std_logic_vector(t0);  
               new_decimal <= '1';
            end if;
         end if;

        
      end if;
   end process;

end Behavioral;

