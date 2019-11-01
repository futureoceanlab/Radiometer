library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity count_ones_and_edges is
    Port ( clk     : in  STD_LOGIC;
           sample  : in  STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
           ones    : out unsigned (2 downto 0) := (others => '0');
           edges   : out STD_LOGIC                     := '0');
end count_ones_and_edges;

architecture Behavioral of count_ones_and_edges is
    signal last_sample  : std_logic_vector (3 downto 0) := (others => '0');
    signal was_high     : std_logic := '0';
begin




process(clk)
    variable sample_cat : std_logic_vector (3 downto 0) :="0000";
    begin
        if rising_edge(clk) then
            case sample is
                -- Please double check!
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
                when "1111" => ones <= "100";
--
                when others => ones <= "100"; --
            end case;
            
            sample_cat :=  sample(3) & sample(1) & last_sample(3) & last_sample(1);

            case sample_cat is 
                when "1111" =>
                  edges     <= not was_high;
                  was_high  <= '1';
                when others =>
                  edges     <= '0';
                  was_high  <= '0';
            end case;
            last_sample <= sample;
        end if;
    end process;




--process(clk)
--    variable sample_cat : std_logic_vector (3 downto 0);
--    variable count_ones : unsigned(2 downto 0);
--
--    begin
--      
--        if rising_edge(clk) then
--            count_ones := ("00" & sample(0)) + 
--                          ("00" & sample(1)) +
--                          ("00" & sample(2)) +
--                          ("00" & sample(3));
--            ones <= std_logic_vector(count_ones); 
--            
--            sample_cat :=  sample(0) & sample(2) & last_sample(0) & last_sample(2) ;
----            sample_cat :=  (sample(0) or sample(1)) & sample(2) & last_sample(0) & (last_sample(2) or last_sample(3));
--
--            if sample_cat = "1111" then
--              edges     <= not was_high;
--              was_high  <= '1';
--            else
--              edges     <= '0';
--              was_high  <= '0';
--            end if;
--
--            last_sample <= sample;
--
--        end if;
--    end process;
end Behavioral;
