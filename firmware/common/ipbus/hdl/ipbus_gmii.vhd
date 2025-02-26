library unisim;
  use unisim.vcomponents.all;
library ieee;
  use ieee.std_logic_1164.ALL;

use work.ipbus.all;

entity ipbus_gmii is
  generic (
    USE_BUFG : integer := 0
  );
  port (
    eth_clk_p : in std_logic; -- 125MHz
    eth_clk_n : in std_logic;

    clk_20_o : out std_logic;

    phy_ready_i : in std_logic;

    -- GMII TX
    gmii_tx_clk_o : out std_logic;
    gmii_tx_en_o  : out std_logic;
    gmii_tx_er_o  : out std_logic;
    gmii_txd_o    : out std_logic_vector(7 downto 0);

    -- GMII RX
    gmii_rx_clk_i : in std_logic;
    gmii_rx_er_i  : in std_logic;
    gmii_rx_dv_i  : in std_logic;
    gmii_rxd_i    : in std_logic_vector(7 downto 0);

    clk_ipb_o : out std_logic; -- IPbus clock
    rst_ipb_o : out std_logic;

    RESET    : in  std_logic; -- The signal of doom
    leds     : out std_logic_vector(1 downto 0); -- status LEDs
    mac_addr : in std_logic_vector(47 downto 0); -- MAC address
    ip_addr  : in std_logic_vector(31 downto 0); -- IP address

    ipb_in  : in  ipb_rbus; -- ipbus
    ipb_out : out ipb_wbus;

    clk_200_o : out std_logic;
    locked    : out std_logic
  );
end entity;

architecture rtl of ipbus_gmii is

  signal clk125, clk_ipb, clk_ipb_i, clk_locked, eth_locked, rst125, rst_ipb, rst_ipb_ctrl, rst_eth, onehz, pkt, clk_drp, gt_clkin, clk_gt125, clk_cmt125: std_logic;
  signal mac_tx_data, mac_rx_data_async, mac_rx_data : std_logic_vector(7 downto 0);
  signal mac_tx_valid, mac_tx_last, mac_tx_error, mac_tx_ready : std_logic;
  signal mac_rx_valid_async, mac_rx_last_async, mac_rx_error_async : std_logic;
  signal mac_rx_valid,       mac_rx_last,       mac_rx_error       : std_logic;
  signal led_p : std_logic_vector(0 downto 0);
  signal clk_200 : std_logic;
  signal mac_rx_clk : std_logic;

begin

  ibuf0: IBUFDS_GTE2 port map(
    i   => eth_clk_p,
    ib  => eth_clk_n,
    o   => gt_clkin,
    ceb => '0'
  );


gtgen0: if USE_BUFG = 0 generate

  bufh_gt0: BUFH port map(
    i => gt_clkin,
    o => clk_gt125
  );

  bufh_gt1: BUFH port map(
    i => gt_clkin,
    o => clk_cmt125
  );

end generate;


gtgen1: if USE_BUFG = 1 generate
  bufg_gt: BUFG port map(
    i => gt_clkin,
    o => clk_gt125
  );

  clk_cmt125 <= clk_gt125;
end generate;


 -- DCM clock generation for internal bus, ethernet

  clocks: entity work.clocks_7s_serdes
  port map(
    clki_gt125 => clk_cmt125,
    clki_125   => clk125,
    clko_ipb   => clk_ipb_i,
    clko_drp   => clk_drp,
    eth_locked => phy_ready_i,
    locked     => clk_locked,
    nuke       => RESET,
    rsto_125   => rst125,
    rsto_ipb   => rst_ipb,
    rsto_eth   => rst_eth,
    rsto_ipb_ctrl => rst_ipb_ctrl,
    onehz  => onehz,
    clk200 => clk_200
);


  clk_200_o <= clk_200;


  eth_pll : entity work.eth_pll
  port map ( 
   clk_125_i => clk_gt125,
   clk_125_o => clk125,
   clk_20_o  => clk_20_o
 );


  clk_ipb   <= clk_ipb_i; -- Best to align delta delays on all clocks for simulation
  clk_ipb_o <= clk_ipb_i;
  rst_ipb_o <= rst_ipb;

  locked <= clk_locked;-- and eth_locked;


  stretch: entity work.led_stretcher
  generic map(
    WIDTH => 1
  ) port map (
    clk  => clk125,
    d(0) => pkt,
    q    => led_p
  );


  leds(1 downto 0) <= (led_p(0), '0');


  giga_eth_mac : entity work.giga_eth_mac
  port map (
    gtx_clk     => clk125,
    glbl_rstn   => phy_ready_i,
    rx_axi_rstn => '1',
    tx_axi_rstn => '1',
    rx_statistics_vector => open,
    rx_statistics_valid  => open,
    rx_mac_aclk => mac_rx_clk,
    rx_reset    => open,
    rx_axis_mac_tdata  => mac_rx_data_async,
    rx_axis_mac_tvalid => mac_rx_valid_async,
    rx_axis_mac_tlast  => mac_rx_last_async,
    rx_axis_mac_tuser  => mac_rx_error_async,
    tx_ifg_delay => x"00",
    tx_statistics_vector => open,
    tx_statistics_valid  => open,
    tx_mac_aclk => open,
    tx_reset    => open,
    tx_axis_mac_tdata  => mac_tx_data,
    tx_axis_mac_tvalid => mac_tx_valid,
    tx_axis_mac_tlast  => mac_tx_last,
    tx_axis_mac_tuser(0) => mac_tx_error,
    tx_axis_mac_tready => mac_tx_ready,
    pause_req => '0',
    pause_val => x"0000",
    refclk    => clk_200,
    speedis100   => open,
    speedis10100 => open,
    gmii_txd     => gmii_txd_o,
    gmii_tx_en   => gmii_tx_en_o,
    gmii_tx_er   => gmii_tx_er_o,
    gmii_tx_clk  => gmii_tx_clk_o,
    gmii_rxd     => gmii_rxd_i,
    gmii_rx_dv   => gmii_rx_dv_i,
    gmii_rx_er   => gmii_rx_er_i,
    gmii_rx_clk  => gmii_rx_clk_i,
    rx_configuration_vector => X"0000_0000_0000_0000_0812",
    tx_configuration_vector => X"0000_0000_0000_0000_0012"
  );


  mac_rx_async_fifo : entity work.mac_rx_async_fifo
  port map (
    wr_rst_busy => open,
    rd_rst_busy => open,
    m_aclk => clk125,
    s_aclk => mac_rx_clk,
    s_aresetn => phy_ready_i,
    s_axis_tvalid   => mac_rx_valid_async,
    s_axis_tready   => open,
    s_axis_tdata    => mac_rx_data_async,
    s_axis_tlast    => mac_rx_last_async,
    s_axis_tuser(0) => mac_rx_error_async,
    m_axis_tvalid   => mac_rx_valid,
    m_axis_tready   => '1',
    m_axis_tdata    => mac_rx_data,
    m_axis_tlast    => mac_rx_last,
    m_axis_tuser(0) => mac_rx_error
  );


-- ipbus control logic
  ipbus: entity work.ipbus_ctrl
  port map(
    mac_clk      => clk125,
    rst_macclk   => rst125,
    ipb_clk      => clk_ipb,
    rst_ipb      => rst_ipb_ctrl,
    mac_rx_data  => mac_rx_data,
    mac_rx_valid => mac_rx_valid,
    mac_rx_last  => mac_rx_last,
    mac_rx_error => mac_rx_error,
    mac_tx_data  => mac_tx_data,
    mac_tx_valid => mac_tx_valid,
    mac_tx_last  => mac_tx_last,
    mac_tx_error => mac_tx_error,
    mac_tx_ready => mac_tx_ready,
    ipb_out      => ipb_out,
    ipb_in       => ipb_in,
    mac_addr     => mac_addr,
    ip_addr      => ip_addr,
    pkt          => pkt
  );

end rtl;