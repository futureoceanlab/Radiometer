library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity total_counters is
    Port ( clk         : in  STD_LOGIC;
           edges       : in  STD_LOGIC;
           ones        : in  unsigned (2 downto 0);
           total_edges : out STD_LOGIC_VECTOR (21 downto 0) := (others => '0');
           total_ones  : out STD_LOGIC_VECTOR (21 downto 0) := (others => '0'));
end total_counters;

architecture Behavioral of total_counters is

  signal t_edges : unsigned(21 downto 0) := (others => '0');
  signal t_ones  : unsigned(21 downto 0) := (others => '0');
  
  begin

  total_edges <= std_logic_vector(t_edges);
  total_ones  <= std_logic_vector(t_ones);

  process (clk)
  begin
    if rising_edge(clk) then
      t_ones  <= t_ones  + ones;
      if edges = '1' then 
        t_edges <= t_edges + 1; 
      end if; -- edge = '1'
    end if; -- rising_edge(clk)
  end process; -- clk
end Behavioral;
