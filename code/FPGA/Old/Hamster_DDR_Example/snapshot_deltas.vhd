library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity snapshot_deltas is
    Port ( clk : in STD_LOGIC;
           new_limit   : in  STD_LOGIC_VECTOR (19 downto 0);
           total_edges : in  STD_LOGIC_VECTOR (23 downto 0);
           total_ones  : in  STD_LOGIC_VECTOR (23 downto 0);
           delta_edges : out STD_LOGIC_VECTOR (23 downto 0) := (others => '0');
           delta_ones  : out STD_LOGIC_VECTOR (23 downto 0) := (others => '0');
           new_deltas  : out STD_LOGIC := '0');
end snapshot_deltas;

architecture Behavioral of snapshot_deltas is
    signal u_edges     : unsigned(23 downto 0) := (others => '0');
    signal u_ones      : unsigned(23 downto 0) := (others => '0');
    signal last_edges  : unsigned(23 downto 0) := (others => '0');
    signal last_ones   : unsigned(23 downto 0) := (others => '0');
    signal countdown   : unsigned(19 downto 0) := to_unsigned(24000-1,20);
    signal limit       : unsigned(19 downto 0) := to_unsigned(24000-1,20); -- 1ms @ 240MHz
    signal clear_point : unsigned(19 downto 0) := to_unsigned(12000-1,20); -- 1ms @ 240MHz
begin

    u_edges <= unsigned(total_edges);
    u_ones  <= unsigned(total_ones);
    
process(clk) 
    begin
        if rising_edge(clk) then 
            if countdown = 0 then
                delta_edges <= std_logic_vector(u_edges - last_edges);
                delta_ones  <= std_logic_vector(u_ones  - last_ones);
                last_edges  <= u_edges;
                last_ones   <= u_ones;
                new_deltas  <= '1';                
                countdown   <= limit;
                limit       <= unsigned(new_limit);
                clear_point <= unsigned("0" & limit(limit'high downto 1));              
            else
                if countdown = clear_point then
                    new_deltas  <= '0';
                end if;
                countdown <= countdown - 1;
            end if;
        end if;
    end process;

end Behavioral;
