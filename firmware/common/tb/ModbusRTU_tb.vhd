-------------------------------------------------------------------------------
-- This file is part of 'LSST Firmware'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'LSST Firmware', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

-- library ieee;
-- use ieee.std_logic_1164.all;
-- use ieee.std_logic_arith.all;
-- use ieee.std_logic_unsigned.all;


-- library surf;
-- use surf.StdRtlPkg.all;

-- entity ModbusRTU_tb is
-- end ModbusRTU_tb;

-- architecture behavior of ModbusRTU_tb is
  -- --entity instantiation--

  -- --signals
  -- signal clk : sl := '0';
  -- signal rst : sl := '1';

  -- -- Transmit parallel interface
  -- signal wrData  : slv(47 downto 0);    --: in  slv(47 downto 0);
  -- signal wrValid : sl;                  --: in  sl;
  -- signal wrReady : sl;                  --: out sl;
  -- -- Receive parallel interface
  -- signal rdData  : slv(63 downto 0);    --: out slv(63 downto 0);
  -- signal rdValid : sl;                  --: out sl;
  -- signal rdReady : sl;                  --: in  sl;

-- -- SN65HVD1780QDRQ1 interface (RS485 transceiver) --
  -- signal rx    : sl;                    --: in sl; 
  -- signal rx_En : sl;  --: out sl; --needs to be same as tx_En
  -- signal tx    : sl;                    --: out sl; 
  -- signal tx_En : sl;  --: out sl  --needs to be same as rx_EN

  -- ----signal wrNotValid : sl := '0';
  -- signal randomstuff : sl := '0';

-- begin

  -- U_ModbusRTU : entity work.ModbusRTU
    -- generic map (
      -- TPD_G => 1 ns
      -- )
    -- port map (
      -- clk        => clk,                -- [in]
      -- rst        => rst,                -- [in]
      -- -- SN65HVD1780QDRQ1 interface (RS485 transceiver) --
      -- rx         => rx,                 --[in]
      -- rx_En      => rx_En,              --[out]
      -- tx         => tx,                 --[out]
      -- tx_En      => tx_En,              --[out]        
      -- -- Mobus Data --    
      -- wrData     => wrData,             --[in]
      -- wrValid    => wrValid,  --[in]    --- still need to work on this
      -- -----wrNotValid => wrNotValid,         --[out]
      -- rdReady    => '1',  --[in]    --- still need to work on this
      -- rdData     => rdData,             --[out]
      -- rdValid    => rdValid             --[out]
      -- );


  
  -- Clk_process : process
  -- begin
    -- clk <= not(clk);
    -- wait for 4 ns;
  -- end process;

  -- Rst_process : process
  -- begin
    -- rst <= '1';
    -- wait for 100 us;
	-- rst <= '0';
	-- wait;
  -- end process;

  -- TxData_process : process
  -- begin
    -- wrValid <= '0';
    -- wait for 400 us;
    -- wrValid <= '1';
    -- wrData  <= x"0103_0001_0001";
	-- wait for 8 ns;
    -- wrValid <= '0';
    -- wait;
  -- end process;


-- end;


------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library surf;
use surf.TextUtilPkg.all;
use surf.AxiLitePkg.all;
use surf.StdRtlPkg.all;

entity ModbusRTU_tb is
end ModbusRTU_tb;

architecture behavior of ModbusRTU_tb is
  --entity instantiation--

  --signals
  signal clk : sl := '0';
  signal rst : sl := '1';

  signal mbDataTx      : slv(47 downto 0);
  signal responseData  : slv(255 downto 0);
  signal responseValid : sl;
  signal transmitValid : sl;
  signal transmitReady : sl;

  
  
   signal axilReadMasters    : AxiLiteReadMasterType  := AXI_LITE_READ_MASTER_INIT_C;
   signal axilReadSlaves     : AxiLiteReadSlaveType   := AXI_LITE_READ_SLAVE_INIT_C;
   signal axilWriteMasters   : AxiLiteWriteMasterType := AXI_LITE_WRITE_MASTER_INIT_C;
   signal axilWriteSlaves : AxiLiteWriteSlaveType := AXI_LITE_WRITE_SLAVE_INIT_C;
   
   signal driverData : sl;
   signal recEn : sl;
	 signal driverEn : sl;
	 signal rx : sl;

begin


  
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
    wait for 400 us;
    axiLiteBusSimWrite(clk, axilWriteMasters, axilWriteSlaves, x"00000000", x"01030001", true);
	wait for 100 us;
	axiLiteBusSimWrite(clk, axilWriteMasters, axilWriteSlaves, x"00000004", x"00010000", true);
	
	wait for 3500 us;
    axiLiteBusSimWrite(clk, axilWriteMasters, axilWriteSlaves, x"00000000", x"11030001", true);
	wait for 100 us;
	axiLiteBusSimWrite(clk, axilWriteMasters, axilWriteSlaves, x"00000004", x"00010000", true);
	wait;
  end process;

  RxData_process : process
  begin
    rx  <= '1';
    --wait for 504201 ns;
	wait for 2000000 ns;

	--1
    rx  <= '0';
	wait for 8712 ns;
	rx  <= '1';
	wait for 8704 ns;
	rx  <= '0';
	wait for 60928 ns;
	rx  <= '1';
	--2
	wait for 17944 ns;
	rx  <= '0';
	wait for 8712 ns;
	rx  <= '1';
	wait for 17408 ns;
	rx  <= '0';
	wait for 52224 ns;
	rx  <= '1';
	--3
	wait for 17944 ns;
	rx  <= '0';
	wait for 78344 ns;
	rx  <= '1';
	wait for 17944 ns;
	rx  <= '0';
	wait for 8712 ns;
	rx  <= '1';
	--4
	wait for 8704 ns;
	rx  <= '0';
	wait for 60928 ns;
	rx  <= '1';
	wait for 17944 ns;
	rx  <= '0';
	wait for 78344 ns;
	rx  <= '1';
	--5---------
    wait for 17944 ns;
    rx  <= '0';
	wait for 8712 ns;
	rx  <= '1';
	wait for 8704 ns;
	rx  <= '0';
	wait for 60928 ns;
	rx  <= '1';
	--6
	wait for 17944 ns;
	rx  <= '0';
	wait for 8712 ns;
	rx  <= '1';
	wait for 8712 ns;
	rx  <= '0';
	wait for 8712 ns;
	rx  <= '1';
	--7
	wait for 8712 ns;
	rx  <= '0';
	wait for 8712 ns;
	rx  <= '1';
	wait for 8712 ns;
	rx  <= '0';
	wait for 8712 ns;
	rx  <= '1';
	--8

	wait for 35352 ns;
	rx  <= '0';
	wait for 17416 ns;
    rx  <= '1';
	wait for 8704 ns;
    rx  <= '0';
	wait for 8704 ns;
    rx  <= '1';
	
	wait for 8704 ns; 
    rx  <= '0';
	wait for 17408 ns;
    rx  <= '1';
   -- wait;

	
------------------------------------	
	
	
	wait for 3000 us;
	--1
    rx  <= '0';
	wait for 8712 ns;
	rx  <= '1';
	wait for 8704 ns;
	rx  <= '0';
	wait for 60928 ns;
	rx  <= '1';
	--2
	wait for 17944 ns;
	rx  <= '0';
	wait for 8712 ns;
	rx  <= '1';
	wait for 17408 ns;
	rx  <= '0';
	wait for 52224 ns;
	rx  <= '1';
	--3
	wait for 17944 ns;
	rx  <= '0';
	wait for 78344 ns;
	rx  <= '1';
	wait for 17944 ns;
	rx  <= '0';
	wait for 8712 ns;
	rx  <= '1';
	--4
	wait for 8704 ns;
	rx  <= '0';
	wait for 60928 ns;
	rx  <= '1';
	wait for 17944 ns;
	rx  <= '0';
	wait for 78344 ns;
	rx  <= '1';
	--5---------
    wait for 17944 ns;
    rx  <= '0';
	wait for 8712 ns;
	rx  <= '1';
	wait for 8704 ns;
	rx  <= '0';
	wait for 60928 ns;
	rx  <= '1';
	--6
	wait for 17944 ns;
	rx  <= '0';
	wait for 8712 ns;
	rx  <= '1';
	wait for 8712 ns;
	rx  <= '0';
	wait for 8712 ns;
	rx  <= '1';
	--7
	wait for 8712 ns;
	rx  <= '0';
	wait for 8712 ns;
	rx  <= '1';
	wait for 8712 ns;
	rx  <= '0';
	wait for 8712 ns;
	rx  <= '1';
	--8

	wait for 35352 ns;
	rx  <= '0';
	wait for 17416 ns;
    rx  <= '1';
	wait for 8704 ns;
    rx  <= '0';
	wait for 8704 ns;
    rx  <= '1';
	
	wait for 8704 ns; 
    rx  <= '0';
	wait for 17408 ns;
    rx  <= '1';
    wait;
  end process;
  
  
  ---------------------------
  -- CurrentSense register
  ---------------------------  
  U_CurrentSenseReg : entity work.CurrentSenseReg
    generic map(
      TPD_G => 1 ns)
    port map (
      mycounter       => (others=>'0'),
      errorCode       => (others=>'0'),
      -- Slave AXI-Lite Interface
      axilClk         => clk,              --[in]
      axilRst         => rst,              --[in]
      axilReadMaster  => axilReadMasters,   --[in]
      axilReadSlave   => axilReadSlaves,    --[out]
      axilWriteMaster => axilWriteMasters,  --[in]
      axilWriteSlave  => axilWriteSlaves,   --[out]
      -- RX Interface
      rxValid         => responseValid,        --[in]
      rxData          => responseData,         --[in]
      -- TX Interface
      txValid         => transmitValid,        --[out]
      ------wrNotValid      => wrNotValid,           --[out]
      txData          => mbDataTx,             --[out]
      txReady         => transmitReady);       --[in]

  -----------------------------------------------------------
  -- NON-AXI entity
  ----------------------------------------------------------- 
  U_ModbusRTU : entity work.ModbusRTU
    generic map (
      TPD_G => 1 ns)
    port map (
      clk   => clk,                 -- [in]
      rst   => rst,                 -- [in]
      -- SN65HVD1780QDRQ1 interface (RS485 transceiver) --
      rx    => rx,                 --[in]
      rx_En => recEn,                   --[out]
      tx    => driverData,              --[out]
      tx_En => driverEn,                --[out]

      -- Mobus Data --    
      wrData     => mbDataTx,           --[in]
      wrValid    => transmitValid,      --[in]
      -----wrNotValid => wrNotValid,
      wrReady    => transmitReady,      --[out]


      rdReady => '1',  --[in]    --- still need to work on this

      rdData  => responseData,          --[out]
      rdValid => responseValid);        --[out]
end;