----------------------------------------------------------------------------------
--     MIT Future Ocean Lab
----------------------------------------------------------------------------------
-- Project:       FOL Radiometer
-- Version:       Beebe
-- Design:        RAD_Counter_SERDES
-- Substrate:     CMod A7 
----------------------------------------------------------------------------------
-- Module:        RAD_Counter (Behavioral)
-- Filename:      RAD_Counter.vhd
-- Created:       18/8/2019
-- Author:        Allan Adams <awa@mit.edu>
-- Guru:          Mike Field <hamster@snap.net.nz>  <=  Many props and thanks!!!
----------------------------------------------------------------------------------
-- Description:   This project counts pulses from a fast source and estimates
--                the area under the curve.  The input signal is a random train
--                of 20+ns pulses (<50MHz).  We need to count these pulses and
--                also estimate what fraction of the time the signal is high.
--                We sample the signal via 4:1 ISERDES running at 250MHz, giving
--                a 1GHz bitstream-sample of the incoming signal.  We then count
--                ones in the stream to estimate time-high, and detect 16+ns long
--                pulses with a simple edge detector.  A running tally is kept of 
--                both counts.  Count-changes are output over a 16-bit bus 
--                (DATA_OUT) along with a pulse (PING_OUT) at a user-selectable 
--                rate (NS_SEL_IN), with a binary input (DTOG_IN) gating a mux
--                controlling which count appears on the bus.  The time-high 
--                count is prescaled by 4 bits to avoid overflowing the bus.
--
-- Dependencies: 
-- 
-- Issues:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity snapshot_deltas is
    generic (
        N_fast : integer -- frequency  in Hz of fast clock 
    );
    Port ( clk : in STD_LOGIC;
           new_limit   : in  STD_LOGIC_VECTOR (19 downto 0);
           total_edges : in  STD_LOGIC_VECTOR (23 downto 0);
           total_ones  : in  STD_LOGIC_VECTOR (23 downto 0);
           reset       : in  STD_LOGIC;
           delta_edges : out STD_LOGIC_VECTOR (23 downto 0) := (others => '0');
           delta_ones  : out STD_LOGIC_VECTOR (23 downto 0) := (others => '0');
           new_deltas  : out STD_LOGIC := '0');
end snapshot_deltas;

architecture Behavioral of snapshot_deltas is
    signal u_edges     : unsigned(23 downto 0) := (others => '0');
    signal u_ones      : unsigned(23 downto 0) := (others => '0');
    signal last_edges  : unsigned(23 downto 0) := (others => '0');
    signal last_ones   : unsigned(23 downto 0) := (others => '0');
    --  number of clock cycles til: 
    --  PING HIGH (default 1ms ~ 1kHz,  but update at Ping to new sampling frequency)
    signal countdown   : unsigned(19 downto 0) := to_unsigned((N_fast/1000)-1,20);  -- 1ms
    --  PING PULSE LENGTH (1us always)
    signal ping_length : unsigned(19 downto 0) := to_unsigned((N_fast/1000000),20); -- 1us
    --  PING LOW AGAIN (default 1ms - ping_length; generally,  new_limit - ping_length)
    signal ping_off    : unsigned(19 downto 0) := to_unsigned((N_fast/1000)-1-(N_fast/1000000),20); 
begin

    u_edges <= unsigned(total_edges);
    u_ones  <= unsigned(total_ones);
    
process(clk) 
    begin
        if rising_edge(clk) then
            if countdown = 0 then
                if reset = '0' then
                  delta_edges <= std_logic_vector(u_edges - last_edges);
                  delta_ones  <= std_logic_vector(u_ones  - last_ones);
                else 
                  delta_edges <= (others => '0');
                  delta_ones  <= (others => '0');
                end if;
                last_edges  <= u_edges;
                last_ones   <= u_ones;
                new_deltas  <= '1';
                countdown   <= unsigned(new_limit) - 1;
                ping_off    <= unsigned(new_limit) - ping_length - 1;  
            else
                if countdown = ping_off then
                  new_deltas  <= '0';
                end if;
                if reset = '1' then
                  last_edges  <=  (others => '0');
                  last_ones   <=  (others => '0');
                  delta_edges <= (others => '0');
                  delta_ones  <= (others => '0');
                end if;
                countdown <= countdown - 1;
            end if;
        end if;
    end process;

end Behavioral;
