library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pulse_stretcher is
    generic(
        CLK_FREQ_HZ : integer := 50_000_000;  
        PULSE_MS    : integer := 100           
    );
    port(
        clk     : in  std_logic;
        rst     : in  std_logic;
        i_pulse : in  std_logic;  
        o_pulse : out std_logic   
    );
end entity;

architecture rtl of pulse_stretcher is

    constant MS_TICKS : integer := CLK_FREQ_HZ / 1000;
    constant PULSE_TICKS : integer := PULSE_MS * MS_TICKS;

    signal counter : integer := 0;
    signal active  : std_logic := '0';

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                counter <= 0;
                active  <= '0';

            else
                if i_pulse = '1' then
                    active  <= '1';
                    counter <= PULSE_TICKS;   
                elsif active = '1' then
                    if counter > 0 then
                        counter <= counter - 1;
                    else
                        active <= '0';         
                    end if;
                end if;
            end if;
        end if;
    end process;

    o_pulse <= '1' when active = '1' else '0';

end architecture;
