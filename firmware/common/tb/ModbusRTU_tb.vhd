library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.StdRtlPkg.all;

entity ModbusRTU_tb is
end ModbusRTU_tb;

architecture behavior of ModbusRTU_tb is
  --entity instantiation--
  
  --signals
  signal clk : sl   := '0';
  signal rst : sl   := '0';

  -- Transmit parallel interface
  signal wrData     : slv(47 downto 0) := x"0000_0000_0000"; --: in  slv(47 downto 0);
  signal wrValid    : sl := '0';            --: in  sl;
  signal wrReady    : sl := '0';            --: out sl;
  -- Receive parallel interface
  signal rdData     : slv(63 downto 0) := x"0000_0000_0000_0000";          --: out slv(63 downto 0);
  signal rdValid    : sl := '0';            --: out sl;
  signal rdReady    : sl := '0';            --: in  sl;
  
-- SN65HVD1780QDRQ1 interface (RS485 transceiver) --
  signal rx         : sl := '0';            --: in sl; 
  signal rx_En      : sl := '0';            --: out sl; --needs to be same as tx_En
  signal tx         : sl := '0';            --: out sl; 
  signal tx_En      : sl := '0';            --: out sl  --needs to be same as rx_EN
  

begin

U_ModbusRTU : entity work.ModbusRTU
        generic map (
           TPD_G             => 1 ns
           )
        port map (
           clk     => clk,           -- [in]
           rst     => rst,           -- [in]
-- SN65HVD1780QDRQ1 interface (RS485 transceiver) --
           rx      => rx,            --[in]
           rx_En   => rx_En,         --[out]
           tx      => tx,            --[out]
           tx_En   => tx_En,         --[out]
           
-- Mobus Data --    
           wrData     => wrData,     --[in]
           
           wrValid    => wrValid,    --[in]    --- still need to work on this
           rdReady    => '1',        --[in]    --- still need to work on this
           
           rdData  =>  rdData,      --[out]
           rdValid =>  rdValid      --[out]
           );



  Clk_process : process
  begin
    clk <= '0';
    wait for 4 ns;
    clk <= '1';
    wait for 4 ns;
  end process;
  
--  Rst_process : process
--  begin
--    rst <= '0';
--    wait for 100000 ns;
--    rst <= '1';
--    wait for 4 ns;
--  end process;
  
  Data_process : process
  begin
    wait for 3 ns;
    wrData <= x"01f1_1010_0100";
    wrValid <= '1';
--    wait for 400 ns;
--    wrValid <= '0';
    wait;
  end process;

end;