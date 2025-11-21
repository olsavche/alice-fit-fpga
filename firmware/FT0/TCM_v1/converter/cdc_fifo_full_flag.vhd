
library ieee;
use ieee.std_logic_1164.all;

entity cdc_fifo_full_flag is
    port (
        clk     : in  std_logic;
        reset : in  std_logic;     
        i_pulse : in  std_logic;    
        o_flag  : out std_logic      
    );
end entity;

architecture rtl of cdc_fifo_full_flag is
    signal flag_reg : std_logic := '0';
begin

    process(clk, reset)
    begin
        if reset = '1' then
            flag_reg <= '0';                 
        elsif rising_edge(clk) then
            if i_pulse = '1' then
                flag_reg <= '1'; 
            else 
                flag_reg <= flag_reg;             
            end if;
        end if;
    end process;

    o_flag <= flag_reg;

end architecture;