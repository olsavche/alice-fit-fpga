library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cdc_xpm_fifo_async is
    port (
        i_rst           : in  std_logic;
        i_wr_clk        : in  std_logic;
        i_rd_clk        : in  std_logic;
        i_wr_en         : in  std_logic;
        i_rd_en         : in  std_logic;
        i_din           : in  std_logic_vector(79 downto 0);  
        o_dout          : out std_logic_vector(79 downto 0);
        o_full          : out std_logic;
        o_empty         : out std_logic;
        o_wr_data_count : out std_logic_vector(9 downto 0); -- log2 FIFO_WRITE_DEPTH -- WR_DATA_COUNT_WIDTH
        o_rd_data_count : out std_logic_vector(9 downto 0) -- log2 FIFO_WRITE_DEPTH -- WR_DATA_COUNT_WIDTH
    );
end cdc_xpm_fifo_async;

architecture rtl of cdc_xpm_fifo_async is


    component xpm_fifo_async
        generic (
            CDC_SYNC_STAGES        : integer := 2;
            DOUT_RESET_VALUE       : string  := "0";
            ECC_MODE               : string  := "no_ecc";
            FIFO_MEMORY_TYPE       : string  := "block";
            FIFO_READ_LATENCY      : integer := 1;
            FIFO_WRITE_DEPTH       : integer := 512; -- min 16
            FULL_RESET_VALUE       : integer := 0;
            PROG_EMPTY_THRESH      : integer := 5;
            PROG_FULL_THRESH       : integer := 10;
            RD_DATA_COUNT_WIDTH    : integer := 10; 
            READ_DATA_WIDTH        : integer := 80;
            READ_MODE              : string  := "std";
            RELATED_CLOCKS         : integer := 0;
            SIM_ASSERT_CHK         : integer := 0;
            USE_ADV_FEATURES       : string  := "0707";
            WAKEUP_TIME            : integer := 0;
            WRITE_DATA_WIDTH       : integer := 80;
            WR_DATA_COUNT_WIDTH    : integer := 10
        );
        port (
            rst             : in  std_logic;
            wr_clk          : in  std_logic;
            rd_clk          : in  std_logic;
            wr_en           : in  std_logic;
            rd_en           : in  std_logic;
            din             : in  std_logic_vector(79 downto 0);
            dout            : out std_logic_vector(79 downto 0);
            full            : out std_logic;
            empty           : out std_logic;
            wr_data_count   : out std_logic_vector(9 downto 0);
            rd_data_count   : out std_logic_vector(9 downto 0);
            wr_ack          : out std_logic;
            overflow        : out std_logic;
            prog_full       : out std_logic;
            wr_rst_busy     : out std_logic;
            rd_rst_busy     : out std_logic;
            almost_full     : out std_logic;
            sbiterr         : out std_logic;
            dbiterr         : out std_logic;
            data_valid      : out std_logic;
            underflow       : out std_logic;
            prog_empty      : out std_logic;
            almost_empty    : out std_logic;
            injectsbiterr   : in  std_logic := '0';
            injectdbiterr   : in  std_logic := '0';
            sleep           : in  std_logic := '0'
        );
    end component;

begin

    fifo_inst : xpm_fifo_async
        port map (
            rst             => i_rst,
            wr_clk          => i_wr_clk,
            rd_clk          => i_rd_clk,
            wr_en           => i_wr_en,
            rd_en           => i_rd_en,
            din             => i_din,
            dout            => o_dout,
            full            => o_full,
            empty           => o_empty,
            wr_data_count   => o_wr_data_count,
            rd_data_count   => o_rd_data_count,
            wr_ack          => open,
            overflow        => open,
            prog_full       => open,
            wr_rst_busy     => open,
            rd_rst_busy     => open,
            almost_full     => open,
            sbiterr         => open,
            dbiterr         => open,
            data_valid      => open,
            underflow       => open,
            prog_empty      => open,
            almost_empty    => open,
            injectsbiterr   => '0',
            injectdbiterr   => '0',
            sleep           => '0'
        );

end rtl;