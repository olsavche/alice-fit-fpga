library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity send_swt is
    port (
            i_clock : in std_logic;
            i_fifo_empty : in std_logic;
            i_reset : in std_logic;
            i_fifo_data : in std_logic_vector(79 downto 0);
            o_data : out std_logic_vector(79 downto 0)
    );
end entity;

architecture rtl of send_swt is

type state_type is (IDLE, SWT);
signal state, next_state :  state_type;
signal s_swt_frame     :    std_logic_vector(79 downto 0);

    begin
    
         o_data <= s_swt_frame; 

        state_process: process(i_clock)
            begin
                if rising_edge(i_clock) then
                    if (i_reset = '1') then     
                        state <= IDLE;
                    else
                        state <= next_state;
                    end if;
                end if;
            end process;


        next_state_process: process (state,i_fifo_empty)
            begin
                case state is
                    when IDLE   =>
                    if i_fifo_empty = '1' then
                        next_state <= IDLE;
                    else
                        next_state <= SWT;
                    end if;
                when SWT    =>
                    if i_fifo_empty = '1' then
                        next_state <= IDLE;
                    else
                        next_state <= SWT;
                    end if;
                    when others => next_state <= IDLE;
                    
                end case;
            end process;

         assign_process: process (i_clock)
             begin
                if rising_edge(i_clock) then
                    case state is
                        when IDLE       => s_swt_frame <= (others => '0');
                        when SWT        => s_swt_frame <= i_fifo_data; 
                           when others =>
                    end case;
                end if;
             end process;
    end 
architecture;
