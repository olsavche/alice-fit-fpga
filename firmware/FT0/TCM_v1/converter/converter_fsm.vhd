
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity converter_fsm is
    port (
        i_clk        : in  std_logic;
        i_rst        : in  std_logic;
        i_fifo_empty : in  std_logic;
        i_fifo_data  : in  std_logic_vector(79 downto 0);
        o_rd_en_fifo : out std_logic;
        i_read_ipb_data : in  std_logic_vector(31 downto 0);
        i_ack           : in  std_logic;
        i_end      : in  std_logic;
        o_type     : out std_logic_vector(3 downto 0);
        o_addr     : out std_logic_vector(31 downto 0);
        o_data     : out std_logic_vector(31 downto 0);
        o_swt      : out std_logic_vector(79 downto 0);
        o_decoded_swt_data : out std_logic;
        o_wr_en_fifo       : out std_logic;
        o_ipb_strobe       : out std_logic;
        o_ipb_write          : out std_logic
    );
end converter_fsm;

architecture rtl of converter_fsm is

    subtype state_t is std_logic_vector(3 downto 0);
    constant S_IDLE               : state_t := "0000"; 
    constant S_SEND_RD_EN         : state_t := "0001"; 
    constant S_WAIT               : state_t := "0010";
    constant S_WAIT_2             : state_t := "0011"; 
    constant S_CAPTURE            : state_t := "0100"; 
    constant S_DECODE             : state_t := "0101"; 
    constant S_READ               : state_t := "0110"; 
    constant S_WRITE              : state_t := "0111"; 
    constant S_RMW_SUM            : state_t := "1000"; 
    constant S_RMW_SUM_2          : state_t := "1001"; 
    constant S_RMW_AND            : state_t := "1010"; 
    constant S_RMW_OR             : state_t := "1011"; 
    constant S_RMW_AND_OR         : state_t := "1100"; 
    constant S_INC                : state_t := "1101"; 
    constant S_NON_INC            : state_t := "1110"; 

    signal state      : state_t := S_IDLE;
    signal next_state : state_t := S_IDLE;
    signal rd_en      : std_logic := '0';
    signal reg_type   : std_logic_vector(3 downto 0)  := (others => '0');
    signal reg_addr   : std_logic_vector(31 downto 0) := (others => '0');
    signal reg_data   : std_logic_vector(31 downto 0) := (others => '0');
    signal reg_o_swt  : std_logic_vector(79 downto 0) := (others => '0');
    signal sum_reg   : std_logic_vector(31 downto 0) := (others => '0');
    signal read_data   : std_logic_vector(31 downto 0) := (others => '0');
    signal and_mask   : std_logic_vector(31 downto 0) := (others => '0');
    signal or_mask   : std_logic_vector(31 downto 0) := (others => '0');
    signal cnt_left   : unsigned(31 downto 0) := (others => '0'); 

begin

    ----------------------------------------------------------------------------

    fsm_1: process(i_clk, i_rst)
    begin
        if i_rst = '1' then
            state <= S_IDLE;
        elsif rising_edge(i_clk) then
            state <= next_state;
        end if;
    end process;

    fsm_2: process(all)
    begin
        next_state <= state; 
        case state is
            when S_IDLE =>
                if i_fifo_empty = '0' then
                    next_state <= S_SEND_RD_EN;
                end if;

            when S_SEND_RD_EN =>
                next_state <= S_WAIT;

            when S_WAIT =>
                next_state <= S_WAIT_2;

            when S_WAIT_2 =>
                next_state <= S_CAPTURE;

            when S_CAPTURE =>
                next_state <= S_DECODE; 

            when S_DECODE =>
                if reg_type = "0000" then
                    next_state <= S_READ;
                elsif reg_type = "0001" then
                    next_state <= S_WRITE;
                elsif reg_type = "0010" then
                    next_state <= S_RMW_AND;
                elsif reg_type = "0011" then
                    next_state <= S_RMW_OR;
                elsif reg_type = "0100" then
                    next_state <= S_RMW_SUM;
                elsif reg_type = "1000" then
                    next_state <= S_INC;
                elsif reg_type = "1001" then
                    next_state <= S_NON_INC;
                else
                    next_state <= S_IDLE;
                end if;

            when S_READ =>
                if i_ack = '1' then
                    next_state <= S_IDLE;
                end if;

            when S_WRITE =>
                if i_ack = '1' then
                    next_state <= S_IDLE;
                end if;
            when S_RMW_SUM =>
                if i_ack = '1' then
                    next_state <= S_RMW_SUM_2;
                end if;
            when S_RMW_SUM_2 =>
                if i_ack = '1' then
                    next_state <= S_IDLE;
                end if;
            when S_RMW_AND =>
                if i_ack = '1' then
                    next_state <= S_IDLE;
                end if;
            when S_RMW_OR =>
                    next_state <= S_RMW_AND_OR;
            when S_RMW_AND_OR =>
                if i_ack = '1' then
                    next_state <= S_IDLE;
                end if;
            when S_INC =>
                if (i_ack = '1') and (cnt_left = 1) then
                    next_state <= S_IDLE;
                else
                    next_state <= S_INC;
                end if;
            when S_NON_INC =>
                if (i_ack = '1') and (cnt_left = 1) then
                    next_state <= S_IDLE;
                else
                    next_state <= S_NON_INC;
                end if;

            when others =>
                next_state <= S_IDLE;
        end case;
    end process;

    fsm_3: process(i_clk, i_rst)
    begin
        if i_rst = '1' then
            reg_type     <= (others => '0');
            reg_addr     <= (others => '0');
            reg_data     <= (others => '0');
            reg_o_swt    <= (others => '0');
            o_wr_en_fifo <= '0';
            o_ipb_strobe <= '0';
            o_ipb_write  <= '0';
            rd_en        <= '0';
            sum_reg      <= (others => '0');
            read_data    <= (others => '0');
            cnt_left    <= (others => '0');
        elsif rising_edge(i_clk) then
            rd_en        <= '0';
            sum_reg      <= (others => '0');
            reg_o_swt    <= (others => '0');
            o_wr_en_fifo <= '0';
            o_ipb_strobe <= '0';
            o_ipb_write  <= '0';
            
            case state is
                when S_IDLE =>
                    null;

                when S_SEND_RD_EN =>
                    rd_en <= '1';

                when S_WAIT =>
                    null;

                when S_WAIT_2 =>
                    null;

                when S_CAPTURE =>
                    reg_type  <= i_fifo_data(67 downto 64);
                    reg_addr  <= i_fifo_data(63 downto 32);
                    reg_data  <= i_fifo_data(31 downto 0);

                when S_DECODE =>
                    null;

                when S_READ =>
                    if i_ack = '1' then
                        reg_o_swt    <= x"300" & reg_type & reg_addr & i_read_ipb_data;
                        o_wr_en_fifo <= '1';
                        o_ipb_strobe    <= '0';
                    else
                        o_ipb_strobe    <= '1';   
                    end if;

                when S_WRITE =>
                    if i_ack = '1' then
                        o_ipb_strobe    <= '0';
                        o_ipb_write    <= '0';
                    else
                        o_ipb_write    <= '1';   
                        o_ipb_strobe    <= '1';
                    end if;
                when S_RMW_SUM =>
                    if i_ack = '1' then
                        reg_o_swt    <= x"300" & reg_type & reg_addr & i_read_ipb_data;
                        sum_reg    <=  i_read_ipb_data;
                        o_wr_en_fifo <= '1';
                        o_ipb_strobe    <= '0';
                    else
                        o_ipb_strobe    <= '1';   
                    end if;
                when S_RMW_SUM_2 =>
                    reg_data <= std_logic_vector(unsigned(reg_data) + unsigned(sum_reg));
                    if i_ack = '1' then
                        o_ipb_strobe    <= '0';
                        o_ipb_write    <= '0';
                    else
                        o_ipb_write    <= '1';   
                        o_ipb_strobe    <= '1';
                    end if;
                 when S_RMW_AND =>
                    and_mask <= reg_data;
                    if i_ack = '1' then
                        read_data <= i_read_ipb_data;
                        reg_o_swt    <= x"300" & reg_type & reg_addr & i_read_ipb_data;
                        o_wr_en_fifo <= '1';
                        o_ipb_strobe    <= '0';
                    else
                        o_ipb_strobe    <= '1';   
                    end if;
                 when S_RMW_OR => 
                    or_mask <= reg_data;
    
                 when S_RMW_AND_OR => 
                    reg_data <= (read_data AND and_mask) OR or_mask;
                    if i_ack = '1' then
                        o_ipb_strobe    <= '0';
                        o_ipb_write    <= '0';
                    else
                        o_ipb_write    <= '1';   
                        o_ipb_strobe    <= '1';
                    end if;

                when S_INC =>
                    if cnt_left = 0 then
                        cnt_left      <= unsigned(reg_data);
                        o_ipb_strobe  <= '1';        
                        o_ipb_write   <= '0'; 
                    else
                        if i_ack = '1' then
                            reg_o_swt    <= x"300" & reg_type & reg_addr & i_read_ipb_data;
                            o_wr_en_fifo <= '1';
                            o_ipb_strobe <= '0';     

                            if cnt_left = 1 then
                               cnt_left <= (others => '0');
                            else
                                cnt_left <= cnt_left - 1;
                                reg_addr <= std_logic_vector(unsigned(reg_addr) + 1);
                            end if;
                        else
                            o_ipb_strobe <= '1';
                            o_ipb_write  <= '0';
                        end if;
                    end if;
                when S_NON_INC =>
                    if cnt_left = 0 then
                        cnt_left      <= unsigned(reg_data); 
                        o_ipb_strobe  <= '1';                
                        o_ipb_write   <= '0';       
                    else
                        if i_ack = '1' then
                            reg_o_swt    <= x"300" & reg_type & reg_addr & i_read_ipb_data;
                            o_wr_en_fifo <= '1';
                            o_ipb_strobe <= '0';          
                
                            if cnt_left = 1 then
                                cnt_left <= (others => '0');
                            else
                                cnt_left <= cnt_left - 1;    
                            end if;
                        else
                            o_ipb_strobe <= '1';
                            o_ipb_write  <= '0';
                        end if;
                    end if;

                when others =>
                    null;
            end case;
        end if;
    end process;

    o_rd_en_fifo        <= rd_en;
    o_type              <= reg_type;
    o_addr              <= reg_addr;
    o_data              <= reg_data;
    o_swt               <= reg_o_swt;

end rtl;
