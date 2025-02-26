# PHY Control
set_property -dict {PACKAGE_PIN H23 IOSTANDARD LVCMOS33} [get_ports phy_reset_o]
set_property -dict {PACKAGE_PIN J25 IOSTANDARD LVCMOS33} [get_ports phy_sreset_o]

# MDIO
set_property -dict {PACKAGE_PIN W25  IOSTANDARD LVCMOS33} [get_ports mdio_io]
set_property -dict {PACKAGE_PIN AA25 IOSTANDARD LVCMOS33} [get_ports mdc_o]

# PHY GMII TX
set_property -dict {PACKAGE_PIN L22  IOSTANDARD LVCMOS33} [get_ports gmii_tx_clk_o]
set_property -dict {PACKAGE_PIN AC26 IOSTANDARD LVCMOS33} [get_ports gmii_tx_en_o]
set_property -dict {PACKAGE_PIN AE26 IOSTANDARD LVCMOS33} [get_ports gmii_tx_er_o]
set_property -dict {PACKAGE_PIN U25  IOSTANDARD LVCMOS33} [get_ports {gmii_txd_o[0]}]
set_property -dict {PACKAGE_PIN Y25  IOSTANDARD LVCMOS33} [get_ports {gmii_txd_o[1]}]
set_property -dict {PACKAGE_PIN AB25 IOSTANDARD LVCMOS33} [get_ports {gmii_txd_o[2]}]
set_property -dict {PACKAGE_PIN AE25 IOSTANDARD LVCMOS33} [get_ports {gmii_txd_o[3]}]
set_property -dict {PACKAGE_PIN U26  IOSTANDARD LVCMOS33} [get_ports {gmii_txd_o[4]}]
set_property -dict {PACKAGE_PIN W26  IOSTANDARD LVCMOS33} [get_ports {gmii_txd_o[5]}]
set_property -dict {PACKAGE_PIN AB26 IOSTANDARD LVCMOS33} [get_ports {gmii_txd_o[6]}]
set_property -dict {PACKAGE_PIN G21  IOSTANDARD LVCMOS33} [get_ports {gmii_txd_o[7]}]

# PHY GMII RX
set_property -dict {PACKAGE_PIN G22 IOSTANDARD LVCMOS33} [get_ports gmii_rx_clk_i]
set_property -dict {PACKAGE_PIN K23 IOSTANDARD LVCMOS33} [get_ports gmii_rx_er_i]
set_property -dict {PACKAGE_PIN J23 IOSTANDARD LVCMOS33} [get_ports gmii_rx_dv_i]
set_property -dict {PACKAGE_PIN L23 IOSTANDARD LVCMOS33} [get_ports {gmii_rxd_i[0]}]
set_property -dict {PACKAGE_PIN K22 IOSTANDARD LVCMOS33} [get_ports {gmii_rxd_i[1]}]
set_property -dict {PACKAGE_PIN J21 IOSTANDARD LVCMOS33} [get_ports {gmii_rxd_i[2]}]
set_property -dict {PACKAGE_PIN J24 IOSTANDARD LVCMOS33} [get_ports {gmii_rxd_i[3]}]
set_property -dict {PACKAGE_PIN J26 IOSTANDARD LVCMOS33} [get_ports {gmii_rxd_i[4]}]
set_property -dict {PACKAGE_PIN H22 IOSTANDARD LVCMOS33} [get_ports {gmii_rxd_i[5]}]
set_property -dict {PACKAGE_PIN H24 IOSTANDARD LVCMOS33} [get_ports {gmii_rxd_i[6]}]
set_property -dict {PACKAGE_PIN H26 IOSTANDARD LVCMOS33} [get_ports {gmii_rxd_i[7]}]