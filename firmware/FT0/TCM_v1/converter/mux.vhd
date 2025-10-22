library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ipbus.all;
--use work.my_package.all;
--use work.tb_package.all;
use work.ipbus.all;

-- sel 0  -> ipbus 
-- sel 1  -> gbt

entity mux is
    generic (
        USE_CLK  : boolean := false
    );
    port (
        -- ipbus tcm
            i_wbus_kc705      : in ipb_wbus;
            o_rbus_kc705      : out ipb_rbus;
        -- payload 
            o_wbus_mem      : out ipb_wbus;
            i_rbus_mem      : in ipb_rbus;
        -- ipbus <-> gbt 
            i_wbus_converter       : in ipb_wbus;
            o_rbus_converter       : out ipb_rbus;
        -- clk and sel 
            i_reset         : in std_logic;
            i_ipb_clk       : in std_logic;
            i_sel           : in std_logic_vector(0 downto 0)
        );
end entity;


architecture rtl of mux is

constant IPB_WBUS_ZERO : ipb_wbus := (
    ipb_addr   => (others => '0'),
    ipb_wdata  => (others => '0'),
    ipb_strobe => '0',
    ipb_write  => '0'
);

constant IPB_RBUS_ZERO : ipb_rbus := (
    ipb_rdata => (others => '0'),
    ipb_ack   => '0',
    ipb_err   => '0'
);

begin

    gen_sync : if USE_CLK generate
        process(i_ipb_clk)
        begin
            if rising_edge(i_ipb_clk) then
                if i_reset = '1' then
                    o_wbus_mem  <= ipb_wbus_zero;
                    o_rbus_kc705  <= ipb_rbus_zero;
                    o_rbus_converter   <= ipb_rbus_zero;
                elsif i_sel = "0" then
                    o_wbus_mem  <= i_wbus_kc705;
                    o_rbus_kc705  <= i_rbus_mem;
                    o_rbus_converter   <= ipb_rbus_zero;
                else
                    o_wbus_mem  <= i_wbus_converter;
                    o_rbus_converter   <= i_rbus_mem;
                    o_rbus_kc705  <= ipb_rbus_zero;
                end if;
            end if;
        end process;
    end generate;

    gen_async : if not USE_CLK generate
        process(all)
        begin
                if i_sel = "0" then
                    o_wbus_mem  <= i_wbus_kc705;
                    o_rbus_kc705  <= i_rbus_mem;
                    o_rbus_converter   <= ipb_rbus_zero;
                else
                    o_wbus_mem  <= i_wbus_converter;
                    o_rbus_converter   <= i_rbus_mem;
                    o_rbus_kc705  <= ipb_rbus_zero;
                end if;
        end process;
    end generate;


end rtl;


