library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity snapshot_deltas is
    Port ( clk : in STD_LOGIC;
           new_limit   : in  STD_LOGIC_VECTOR (17 downto 0);
           total_edges : in  STD_LOGIC_VECTOR (21 downto 0);
           total_ones  : in  STD_LOGIC_VECTOR (21 downto 0);
           delta_edges : out STD_LOGIC_VECTOR (21 downto 0) := (others => '0');
           delta_ones  : out STD_LOGIC_VECTOR (21 downto 0) := (others => '0');
           new_deltas  : out STD_LOGIC := '0');
end snapshot_deltas;

architecture Behavioral of snapshot_deltas is
    signal u_edges     : unsigned(21 downto 0) := (others => '0');
    signal u_ones      : unsigned(21 downto 0) := (others => '0');
    signal last_edges  : unsigned(21 downto 0) := (others => '0');
    signal last_ones   : unsigned(21 downto 0) := (others => '0');
    signal countdown   : unsigned(17 downto 0) := to_unsigned(240000-1,18);
    signal limit       : unsigned(17 downto 0) := to_unsigned(240000-1,18); -- 1ms @ 240MHz
    signal ping_length : unsigned(17 downto 0) := to_unsigned(240,18);      -- 1us @ 240MHz
    signal ping_off    : unsigned(17 downto 0) := to_unsigned(240000-241,18); 
begin

    u_edges <= unsigned(total_edges);
    u_ones  <= unsigned(total_ones);
    
process(clk) 
    begin
        if rising_edge(clk) then 
            if countdown = 0 then
                delta_edges <= std_logic_vector(u_edges -last_edges);
                delta_ones  <= std_logic_vector(u_ones  - last_ones);
                last_edges  <= u_edges;
                last_ones   <= u_ones;
                new_deltas  <= '1';
                countdown   <= limit;
                ping_off    <= limit - ping_length;  
            else
                if countdown = ping_off then
                  new_deltas  <= '0';
                  limit <= unsigned(new_limit);
                end if;
                countdown <= countdown - 1;
            end if;
        end if;
    end process;

end Behavioral;
