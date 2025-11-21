library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ipbus_status is
    generic (
        CLK_FREQ_HZ : positive := 50_000_000;
        HOLD_TIME_S : positive := 2
    );
    port (
        clk     : in  std_logic;   
        rst   : in  std_logic;   
        i_pulse : in  std_logic;   
        o_q     : out std_logic    
    );
end entity ipbus_status;

architecture rtl of ipbus_status is

    constant HOLD_TICKS : natural := CLK_FREQ_HZ * HOLD_TIME_S;
    signal cnt  : integer range 0 to HOLD_TICKS := 0;
    signal q_reg : std_logic := '0';

begin

    process (clk)
    begin
        if rst = '1' then
            cnt   <= 0;
            q_reg <= '0';

        elsif rising_edge(clk) then
            if i_pulse = '1' then
                q_reg <= '1';
                cnt   <= HOLD_TICKS;

            elsif q_reg = '1' then
                if cnt = 0 then
                    q_reg <= '0';
                else
                    cnt <= cnt - 1;
                end if;
            end if;
        end if;
    end process;

    o_q <= q_reg;

end architecture rtl;

-----------------------------------------------------
--u_monoflop : entity work.ipbus_status
--    generic map (
--        CLK_FREQ_HZ => 100_000_000,
--        HOLD_TIME_S => 2
--    )
--    port map (
--        clk     => clk,
--        rst   => rst,
--        i_pulse => pulse_in,
--        o_q     => out_signal
--    );
-----------------------------------------------------