library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity strobe_ack_watchdog is
  generic (
    TIMEOUT_CYCLES : positive := 30; 
    RESET_LEN      : positive := 4   
  );
  port (
    clk    : in  std_logic;
    strobe : in  std_logic;  
    ack    : in  std_logic;  
    reset  : out std_logic  
  );
end entity;

architecture rtl of strobe_ack_watchdog is
  type state_t is (IDLE, RUN, GEN_RESET, WAIT_STROBE_LOW);
  signal state        : state_t := IDLE;
  signal timeout_cnt  : integer range 0 to TIMEOUT_CYCLES := 0;
  signal reset_cnt    : integer range 0 to RESET_LEN      := 0;
  signal reset_reg    : std_logic := '0';
begin
  reset <= reset_reg;

  process(clk)
  begin
    if rising_edge(clk) then
      case state is
        when IDLE =>
          reset_reg   <= '0';
          timeout_cnt <= 0;
          reset_cnt   <= 0;
          if strobe = '1' then
            state <= RUN;
          end if;

        when RUN =>
          if strobe = '0' then
            timeout_cnt <= 0;
            state       <= IDLE;
          else
            if ack = '1' then
              timeout_cnt <= 0;
              state       <= WAIT_STROBE_LOW;
            else
  
              if timeout_cnt = TIMEOUT_CYCLES - 1 then
                reset_reg <= '1';
                reset_cnt <= 1;  
                state     <= GEN_RESET;
              else
                timeout_cnt <= timeout_cnt + 1;
              end if;
            end if;
          end if;
          
        when GEN_RESET =>
          if reset_cnt = RESET_LEN then
            reset_reg <= '0';
            state     <= WAIT_STROBE_LOW;
          else
            reset_cnt <= reset_cnt + 1;
          end if;

        when WAIT_STROBE_LOW =>
          if strobe = '0' then
            state <= IDLE;
          end if;
      end case;
    end if;
  end process;
end architecture;
