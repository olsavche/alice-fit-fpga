library ieee;
  use ieee.std_logic_1164.all;

library work;
  use work.mdio;
  use work.mdio.all;


entity vsc8211_initializer is
  port (
    clk_i : in std_logic; -- Input clock, must not be faster than 25 MHz

    -- Control signals
    reset_o  : out std_logic; -- Hardware chip reset
    sreset_o : out std_logic; -- Software reset

    -- MDIO
    mdc_o   : out   std_logic;
    mdio_io : inout std_logic;

    ready_o : out std_logic -- PHY ready to be used
  );
end entity;


architecture rtl of vsc8211_initializer is

  type state_t is (RESET, SRESET, AFTER_RESET_WAIT, INIT_LEDS, INIT_AUTONEG, READY);
  signal state : state_t := RESET;

  signal mdio_manager : mdio.manager_t := mdio.init;

  signal mdio_start : std_logic;
  constant MDIO_OP_CODE  : std_logic_vector(1 downto 0) := mdio.WRITE;
  constant MDIO_PHY_ADDR : std_logic_vector(4 downto 0) := "00000";
  signal mdio_reg_addr   : std_logic_vector(4 downto 0);
  signal mdio_wdata : std_logic_vector(15 downto 0);

begin

  mdio_io_dirver : process (mdio_manager) is
  begin
    if mdio_manager.serial_dir = '1' then
      mdio_io <= 'Z';
    else
      mdio_io <= mdio_manager.mdo;
    end if;
  end process;


  mdio : process (clk_i) is
  begin
    if rising_edge(clk_i) then
      mdio_manager <= clock(
        mdio_manager,
        mdio_io,
        mdio_start,
        MDIO_OP_CODE,
        MDIO_PHY_ADDR,
        mdio_reg_addr,
        mdio_wdata
      );
    end if;
  end process;
  mdc_o <= mdio_manager.mdc;


  fsm : process (clk_i) is
    constant CNT_MAX : natural := 1048575;
    variable cnt : natural range 0 to CNT_MAX := CNT_MAX; -- General purpose counter
  begin
    if rising_edge(clk_i) then
      mdio_start <= '0';

      case state is

      when RESET =>
        reset_o  <= '0';
        sreset_o <= '0';
        ready_o  <= '0';

        if cnt = 0 then
          reset_o <= '1';

          cnt := CNT_MAX;
          state <= SRESET;
        else
          cnt := cnt - 1;
        end if;

      when SRESET =>
        if cnt = 0 then
          sreset_o <= '1';

          cnt := CNT_MAX;
          state <= AFTER_RESET_WAIT;
        else
          cnt := cnt - 1;
        end if;

      when AFTER_RESET_WAIT =>
        if cnt = 0 then
          mdio_start <= '1';
          mdio_reg_addr <= b"11011";
          -- Led 4 - Tx, Led 3 - Fiber Media Selected, Led 2 - Link/Activity, Led 1 - Link100/1000/Activity, Led 0 - Rx
          mdio_wdata <= b"11_10_10_11_11_000110";

          cnt := 200;
          state <= INIT_LEDS;
        else
          cnt := cnt - 1;
        end if;

      when INIT_LEDS =>
        if cnt = 0 then
          mdio_start <= '1';
          mdio_reg_addr <= b"11110";
          mdio_wdata <= b"0100000000000000";

          cnt := CNT_MAX;
          state <= INIT_AUTONEG;
        else
          cnt := cnt - 1;
        end if;

      when INIT_AUTONEG =>
        if cnt = 0 then
          state <= READY;
        else
          cnt := cnt - 1;
        end if;

      when READY =>
        ready_o <= '1';

      end case;
    end if;
  end process;

end architecture;