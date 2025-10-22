

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity converter_top is
    Port ( 
        i_rst   : in  std_logic;
        i_ipb_clock : in std_logic;
        i_gbt_rx_clock : in std_logic;
        i_gbt_tx_clock : in std_logic;
        i_gbt_data : in std_logic_vector(79 downto 0);
        o_gbt_data : out std_logic_vector(79 downto 0);
        i_ipb_ack: in std_logic;
        i_ipb_rdata : in std_logic_vector(31 downto 0);
        o_ipb_strobe: out std_logic;
        o_ipb_write: out std_logic;
        o_ipb_wdata : out std_logic_vector(31 downto 0);
        o_ipb_addr : out std_logic_vector(31 downto 0);
        o_my_cdc_xpm_fifo_async_o_full: out std_logic 
    );
end converter_top;

architecture Behavioral of converter_top is

-- mark_debug
attribute mark_debug : string;
attribute mark_debug of o_gbt_data   : signal is "true";
attribute mark_debug of o_ipb_strobe : signal is "true";
attribute mark_debug of o_ipb_write  : signal is "true";
attribute mark_debug of o_ipb_wdata  : signal is "true";
attribute mark_debug of o_ipb_addr   : signal is "true";
attribute mark_debug of i_gbt_data : signal is "true";
attribute mark_debug of i_ipb_ack  : signal is "true";
attribute mark_debug of i_ipb_rdata: signal is "true";
-- my_receive_swt
signal my_receive_swt_o_w_en_r : std_logic;
signal my_receive_swt_o_data : std_logic_vector(79 downto 0);
-- my_cdc_xpm_fifo_async
signal my_cdc_xpm_fifo_async_o_full : std_logic;
signal my_cdc_xpm_fifo_async_o_empty : std_logic;
signal my_cdc_xpm_fifo_async_o_wr_data_count : std_logic_vector(9 downto 0);
signal my_cdc_xpm_fifo_async_o_rd_data_count : std_logic_vector(9 downto 0);
signal my_cdc_xpm_fifo_async_o_dout : std_logic_vector(79 downto 0);
-- my_converter_fsm
signal my_converter_fsm_o_rd_en_fifo : std_logic; 
signal my_converter_fsm_o_decoded_swt_data : std_logic; 
signal my_converter_fsm_o_wr_en_fifo : std_logic; 
signal my_converter_fsm_o_type : std_logic_vector(3 downto 0);
signal my_converter_fsm_o_addr : std_logic_vector(31 downto 0);
signal my_converter_fsm_o_data : std_logic_vector(31 downto 0);
signal my_converter_fsm_o_swt : std_logic_vector(79 downto 0);
signal my_converter_fsm_o_ipb_strobe : std_logic; 
signal my_converter_fsm_o_ipb_write : std_logic; 
-- my_cdc_xpm_fifo_async_2
signal my_cdc_xpm_fifo_async_2_o_full : std_logic;
signal my_cdc_xpm_fifo_async_2_o_empty : std_logic;
signal my_cdc_xpm_fifo_async_2_o_wr_data_count : std_logic_vector(9 downto 0);
signal my_cdc_xpm_fifo_async_2_o_rd_data_count : std_logic_vector(9 downto 0);
signal my_cdc_xpm_fifo_async_2_o_dout : std_logic_vector(79 downto 0);
-- my_send_swt
signal my_send_swt_o_data : std_logic_vector(79 downto 0);
-- my_strobe_ack_watchdog
signal my_strobe_ack_watchdog_reset : std_logic;
-- other
signal fsm_reset : std_logic;
signal probe0_sig : std_logic_vector(0 downto 0);
signal probe1_sig : std_logic_vector(0 downto 0);
signal probe2_sig : std_logic_vector(0 downto 0);
signal probe3_sig : std_logic_vector(0 downto 0);

begin


my_receive_swt : entity work.receive_swt
    port map (
        i_clock  => i_gbt_rx_clock,    
        i_reset  => i_rst,    
        i_data_r => i_gbt_data,   
        o_data   => my_receive_swt_o_data,     
        o_w_en_r => my_receive_swt_o_w_en_r    
    );
    
my_cdc_xpm_fifo_async : entity work.cdc_xpm_fifo_async
    port map (
        i_rst           => i_rst,           
        i_wr_clk        => i_gbt_rx_clock,        
        i_rd_clk        => i_ipb_clock,        
        i_wr_en         => my_receive_swt_o_w_en_r,         
        i_rd_en         => my_converter_fsm_o_rd_en_fifo,         
        i_din           => my_receive_swt_o_data,           
        o_dout          => my_cdc_xpm_fifo_async_o_dout,          
        o_full          => my_cdc_xpm_fifo_async_o_full,          
        o_empty         => my_cdc_xpm_fifo_async_o_empty,         
        o_wr_data_count => my_cdc_xpm_fifo_async_o_wr_data_count, 
        o_rd_data_count => my_cdc_xpm_fifo_async_o_rd_data_count  
    );
    
my_strobe_ack_watchdog: entity work.strobe_ack_watchdog
    generic map (
      TIMEOUT_CYCLES => 500,
      RESET_LEN      => 4
    )
    port map (
      clk    => i_ipb_clock,
      strobe => my_converter_fsm_o_ipb_strobe,
      ack    => i_ipb_ack,
      reset  => my_strobe_ack_watchdog_reset
    );

my_converter_fsm : entity work.converter_fsm
    port map (
        i_clk              => i_ipb_clock,              
        i_rst              => fsm_reset,              
        i_fifo_empty       => my_cdc_xpm_fifo_async_o_empty,       
        i_fifo_data        => my_cdc_xpm_fifo_async_o_dout,        
        o_rd_en_fifo       => my_converter_fsm_o_rd_en_fifo,       
        i_read_ipb_data    => i_ipb_rdata,    
        i_ack              => i_ipb_ack,             
        i_end              => '0',              
        o_type             => my_converter_fsm_o_type,             
        o_addr             => my_converter_fsm_o_addr,             
        o_data             => my_converter_fsm_o_data,             
        o_swt              => my_converter_fsm_o_swt,              
        o_decoded_swt_data => my_converter_fsm_o_decoded_swt_data, 
        o_wr_en_fifo       => my_converter_fsm_o_wr_en_fifo,        
        o_ipb_strobe       => my_converter_fsm_o_ipb_strobe,
        o_ipb_write        => my_converter_fsm_o_ipb_write
    );

my_cdc_xpm_fifo_async_2 : entity work.cdc_xpm_fifo_async
    port map (
        i_rst           => i_rst,                              
        i_wr_clk        => i_ipb_clock,                          
        i_rd_clk        => i_gbt_tx_clock,                          
        i_wr_en         => my_converter_fsm_o_wr_en_fifo,           
        i_rd_en         => '1',                                     
        i_din           => my_converter_fsm_o_swt,                  
        o_dout          => my_cdc_xpm_fifo_async_2_o_dout,          
        o_full          => my_cdc_xpm_fifo_async_2_o_full,          
        o_empty         => my_cdc_xpm_fifo_async_2_o_empty,         
        o_wr_data_count => my_cdc_xpm_fifo_async_2_o_wr_data_count, 
        o_rd_data_count => my_cdc_xpm_fifo_async_2_o_rd_data_count  
    );

my_send_swt : entity work.send_swt
    port map (
        i_clock      => i_gbt_tx_clock,     
        i_fifo_empty => my_cdc_xpm_fifo_async_2_o_empty, 
        i_reset      => i_rst,
        i_fifo_data  => my_cdc_xpm_fifo_async_2_o_dout,
        o_data       => my_send_swt_o_data
    );
    
    
process(i_ipb_clock)
begin
  if rising_edge(i_ipb_clock) then
    if i_rst = '1' then
      o_my_cdc_xpm_fifo_async_o_full <= '0';  
    else
      if my_cdc_xpm_fifo_async_o_full = '1' then
        o_my_cdc_xpm_fifo_async_o_full <= '1';  
      end if;
    end if;
  end if;
end process;

fsm_reset <= my_strobe_ack_watchdog_reset or i_rst;
o_ipb_strobe <= my_converter_fsm_o_ipb_strobe;
o_ipb_write <= my_converter_fsm_o_ipb_write;
o_ipb_wdata <= my_converter_fsm_o_data;
o_ipb_addr <= my_converter_fsm_o_addr;
o_gbt_data <= my_send_swt_o_data;

end Behavioral;
