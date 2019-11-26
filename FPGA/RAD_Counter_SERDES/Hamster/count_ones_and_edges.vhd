library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity count_ones_and_edges is
    Port ( clk     : in  STD_LOGIC;
           samples : in  STD_LOGIC_VECTOR (3 downto 0);
           edges   : out STD_LOGIC_VECTOR (2 downto 0) := (others => '0');
           ones    : out STD_LOGIC_VECTOR (2 downto 0) := (others => '0'));
end count_ones_and_edges;

architecture Behavioral of count_ones_and_edges is
    signal last_oldest : std_logic;
begin

process(clk)
    begin
        if rising_edge(clk) then
            case samples is
                -- Please double check!
                when "0000" => ones <= "000";
                when "0001" => ones <= "001";
                when "0010" => ones <= "001";
                when "0011" => ones <= "010";
                when "0100" => ones <= "001";
                when "0101" => ones <= "010";
                when "0110" => ones <= "010";
                when "0111" => ones <= "011";
                when "1000" => ones <= "001";
                when "1001" => ones <= "010";
                when "1010" => ones <= "010";
                when "1011" => ones <= "011";
                when "1100" => ones <= "010";
                when "1101" => ones <= "011";
                when "1110" => ones <= "011";
                when others => ones <= "100";
            end case;
            case samples & last_oldest is
                -- Please double check!
                   -- newest --- oldest samples
                    when "00000" => edges <= "000";
                    when "00001" => edges <= "000";
                    when "00010" => edges <= "001";
                    when "00011" => edges <= "000";
                    when "00100" => edges <= "001";
                    when "00101" => edges <= "001";
                    when "00110" => edges <= "001";
                    when "00111" => edges <= "000";
                    when "01000" => edges <= "001";
                    when "01001" => edges <= "001";
                    when "01010" => edges <= "010";
                    when "01011" => edges <= "001";
                    when "01100" => edges <= "001";
                    when "01101" => edges <= "001";
                    when "01110" => edges <= "001";
                    when "01111" => edges <= "000";
                    when "10000" => edges <= "001";
                    when "10001" => edges <= "001";
                    when "10010" => edges <= "010";
                    when "10011" => edges <= "001";
                    when "10100" => edges <= "010";
                    when "10101" => edges <= "010";
                    when "10110" => edges <= "010";
                    when "10111" => edges <= "001";
                    when "11000" => edges <= "001";
                    when "11001" => edges <= "001";
                    when "11010" => edges <= "010";
                    when "11011" => edges <= "001";
                    when "11100" => edges <= "001";
                    when "11101" => edges <= "001";
                    when "11110" => edges <= "001";
                    when others  => edges <= "000";
            end case;
            last_oldest <= samples(3);
        end if;
    end process;
end Behavioral;
