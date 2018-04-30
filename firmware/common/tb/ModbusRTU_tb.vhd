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
  signal clk : sl := '0';
  signal rst : sl := '1';

  -- Transmit parallel interface
  signal wrData  : slv(47 downto 0);    --: in  slv(47 downto 0);
  signal wrValid : sl;                  --: in  sl;
  signal wrReady : sl;                  --: out sl;
  -- Receive parallel interface
  signal rdData  : slv(63 downto 0);    --: out slv(63 downto 0);
  signal rdValid : sl;                  --: out sl;
  signal rdReady : sl;                  --: in  sl;

-- SN65HVD1780QDRQ1 interface (RS485 transceiver) --
  signal rx    : sl;                    --: in sl; 
  signal rx_En : sl;  --: out sl; --needs to be same as tx_En
  signal tx    : sl;                    --: out sl; 
  signal tx_En : sl;  --: out sl  --needs to be same as rx_EN

  signal wrNotValid : sl := '0';
  signal randomstuff : sl := '0';

begin

  U_ModbusRTU : entity work.ModbusRTU
    generic map (
      TPD_G => 1 ns
      )
    port map (
      clk        => clk,                -- [in]
      rst        => rst,                -- [in]
      -- SN65HVD1780QDRQ1 interface (RS485 transceiver) --
      rx         => rx,                 --[in]
      rx_En      => rx_En,              --[out]
      tx         => tx,                 --[out]
      tx_En      => tx_En,              --[out]        
      -- Mobus Data --    
      wrData     => wrData,             --[in]
      wrValid    => wrValid,  --[in]    --- still need to work on this
      wrNotValid => wrNotValid,         --[out]
      rdReady    => '1',  --[in]    --- still need to work on this
      rdData     => rdData,             --[out]
      rdValid    => rdValid             --[out]
      );


  
  Clk_process : process
  begin
    clk <= not(clk);
    wait for 4 ns;
  end process;

  Rst_process : process
  begin
    rst <= '1';
    wait for 100 us;
	rst <= '0';
	wait;
  end process;

  TxData_process : process
  begin
    wait for 200 us;
    wrValid <= '1';
    wrData  <= x"ffff_ffff_ffff";
	wait for 2 ms;
    wrValid <= '0';
    wait;
  end process;
  
  RxData_process : process
  begin
    wait for 1300 us;
	--1
    rx  <= '1';
	wait for 9240 ns;
	rx  <= '1';
	wait for 9240 ns;
	rx  <= '1';
	wait for 9240 ns;
	rx  <= '0';
	--2
	wait for 9240 ns;
	rx  <= '1';
	wait for 9240 ns;
	rx  <= '0';
	wait for 9240 ns;
	rx  <= '1';
	wait for 9240 ns;
	rx  <= '0';
	--3
	wait for 9240 ns;
	rx  <= '1';
	wait for 9240 ns;
	rx  <= '0';
	wait for 9240 ns;
	rx  <= '1';
	wait for 9240 ns;
	rx  <= '0';
	--4
	wait for 9240 ns;
	rx  <= '1';
	wait for 9240 ns;
	rx  <= '0';
	wait for 9240 ns;
	rx  <= '1';
	wait for 9240 ns;
	rx  <= '0';
	--5
    wait for 1300 us;
    rx  <= '1';
	wait for 9240 ns;
	rx  <= '1';
	wait for 9240 ns;
	rx  <= '1';
	wait for 9240 ns;
	rx  <= '0';
	--6
	wait for 9240 ns;
	rx  <= '1';
	wait for 9240 ns;
	rx  <= '0';
	wait for 9240 ns;
	rx  <= '1';
	wait for 9240 ns;
	rx  <= '0';
	--7
	wait for 9240 ns;
	rx  <= '1';
	wait for 9240 ns;
	rx  <= '0';
	wait for 9240 ns;
	rx  <= '1';
	wait for 9240 ns;
	rx  <= '0';
	--8

	wait for 9240 ns;
	rx  <= '1';
	wait for 9240 ns;
    rx  <= '1';
	wait for 9240 ns;
    rx  <= '1';
	wait for 9240 ns;
    rx  <= '1';
	
	wait for 9240 ns;
    rx  <= '0';
    wait;
  end process;

end;
