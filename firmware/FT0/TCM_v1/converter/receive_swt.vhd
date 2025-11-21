library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity receive_swt is
    port (
        i_clock : in std_logic;
        i_Rx_ErrorDet : in std_logic;
        i_reset : in std_logic;
        i_data_r : in std_logic_vector(79 downto 0);
        o_data : out std_logic_vector(79 downto 0); 
        o_w_en_r : out std_logic
    );
end entity;

architecture rtl of receive_swt is

    signal w_en_r : std_logic := '0';
    constant c_SWT : std_logic_vector(3 downto 0) := x"3";

    begin
        o_w_en_r <= w_en_r;

        swt_capt_proc: process (i_clock, i_reset)
            begin
                if i_reset = '1' then
                    o_data   <= (others => '0');
                    w_en_r  <= '0';
                elsif rising_edge(i_clock) then
                    if i_data_r(79 downto 76) = c_SWT and (i_Rx_ErrorDet = '0') then
                        o_data   <= i_data_r(79 downto 0);
                        w_en_r  <= '1';
                    else 
                        o_data  <= (others => '0');
                        w_en_r  <= '0';
                    end if;
                end if;
            end 
        process;
    end 
architecture;



