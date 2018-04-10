-----------------------------------------------------------------
--                                                             --
-----------------------------------------------------------------
--
--      LsstAcFilterRelay.vhd -
--
--      Copyright(c) SLAC National Accelerator Laboratory 2000
--
--      Author: 
--      Created on: 
--      Last change: 
--
-------------------------------------------------------------------------------
-- File       : LSStACFilterRelay.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2018-02-28
-- Last update: 2018-03-08
-------------------------------------------------------------------------------
-- Description: Firmware Target's Top Level
-------------------------------------------------------------------------------
-- This file is part of 'LSST Firmware'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'LSST Firmware', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;

library unisim;
use unisim.vcomponents.all;

entity LsstAcFilterRelay is
   generic (
      TPD_G        : time               := 1 ns;
      OVERRIDE_ETH_CONFIG_G : boolean   := true;
      BUILD_INFO_G : BuildInfoType);
   port (
      -- Relay Okay signal --
      relOK : out slv(11 downto 0) := x"000";  --
      
      -- Modbus signals --
      mbDataTx : out slv(47 downto 0);

      -- SN65HVD1780QDRQ1 interface (RS485 transceiver) --
      rec_Data    : in sl;              --
      rec_En      : out sl;             --
      driver_Data : out sl;              --
      driver_En   : out sl;             --

      -- Boot Memory Ports
      bootCsL  : out sl;
      bootMosi : out sl;
      bootMiso : in  sl;

      -- 1GbE Ports
      ethClkP : in  sl;
      ethClkN : in  sl;
      ethRxP  : in  sl;
      ethRxN  : in  sl;
      ethTxP  : out sl;
      ethTxN  : out sl;
      
      -- XADC Ports
      vPIn    : in  sl;
      vNIn    : in  sl);
end LsstAcFilterRelay;

architecture top_level of LsstAcFilterRelay is

   constant SYS_CLK_FREQ_C : real                                         := 125.0E+6;
   constant AXI_CONFIG_C   : AxiLiteCrossbarMasterConfigArray(6 downto 0) := genAxiLiteConfig(7, x"0000_0000", 22, 18);
   constant RELAY_INDEX_C  : natural                                      := 0;

   signal axilClk          : sl;
   signal axilRst          : sl;
   signal axilWriteMasters : AxiLiteWriteMasterArray(6 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(6 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C);
   signal axilReadMasters  : AxiLiteReadMasterArray(6 downto 0) ;
   signal axilReadSlaves   : AxiLiteReadSlaveArray(6 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_DECERR_C);
   
   
   signal mbData         : slv(47 downto 0);
   
   signal temp1 : sl; --remove
   signal temp2 : sl;--remove
   signal temp3 : sl;--remove
   signal temp4 : slv(7 downto 0);

begin

   ---------------------
   -- Common Core Module
   ---------------------
   U_Core : entity work.LsstPwrCtrlCore
      generic map (
         TPD_G                 => TPD_G,
         OVERRIDE_ETH_CONFIG_G => OVERRIDE_ETH_CONFIG_G,
         OVERRIDE_MAC_ADDR_G   => x"3f_48_00_56_00_08",  --08:00:56:00:48:3f     --x"00_00_16_56_00_08",  -- 08:00:56:16:00:00     
         OVERRIDE_IP_ADDR_G    => x"3f_01_A8_C0", --192.168.1.63      --x"0A_01_A8_C0",        -- 192.168.1.10 
         BUILD_INFO_G          => BUILD_INFO_G)
      port map (
         -- Register Interface
         axilClk          => axilClk,           --[out]
         axilRst          => axilRst,           --[out]
         axilReadMasters  => axilReadMasters,   --[out]
         axilReadSlaves   => axilReadSlaves,    --[int]
         axilWriteMasters => axilWriteMasters,  --[out]
         axilWriteSlaves  => axilWriteSlaves,   --[int]
         -- Misc.
         extRstL          => '1',               --[int]
         -- XADC Ports
         vPIn             => vPIn,              --[int]
         vNIn             => vNIn,              --[int]
         -- 1GbE Interface
         ethClkP          => ethClkP,           --[in]
         ethClkN          => ethClkN,           --[in]
         ethRxP(0)        => ethRxP,            --[in]
         ethRxN(0)        => ethRxN,            --[in]
         ethTxP(0)        => ethTxP,            --[out]
         ethTxN(0)        => ethTxN);           --[out]
         
      
   ---------------------------
   -- Relay register
   ---------------------------  
U_RelayReg : entity work.RelayReg
   generic map(
      TPD_G => TPD_G
      )
   port map (
-- Slave AXI-Lite Interface
     axilClk         => axilClk,              --[in]
     axilRst         => axilRst,              --[in]
     axilReadMaster  => axilReadMasters(0),   --[in]
     axilReadSlave   => axilReadSlaves(0),    --[out]
     axilWriteMaster => axilWriteMasters(0),  --[in]
     axilWriteSlave  => axilWriteSlaves(0),   --[out]

-- Relay Control    
      relOK => relOK                          --[out]
      );
      
      
  ---------------------------
  -- CurrentSense register
  ---------------------------  
U_CurrentSenseReg : entity work.CurrentSenseReg
  generic map(
     TPD_G => TPD_G
     )
  port map (
     -- Slave AXI-Lite Interface
    axilClk         => axilClk,             --[in]
    axilRst         => axilRst,             --[in]
    axilReadMaster  => axilReadMasters(1),  --[in]
    axilReadSlave   => axilReadSlaves(1),   --[out]
    axilWriteMaster => axilWriteMasters(1), --[in]
    axilWriteSlave  => axilWriteSlaves(1),  --[out]

     -- Relay Control    
     mbDataTx => mbData                     --[out]
     );     
      

-----------------------------------------------------------
-- NON-AXI entity
-----------------------------------------------------------	
	
  
U_ModbusRTU : entity work.ModbusRTU
        generic map (
           TPD_G             => TPD_G
           )
        port map (
           clk     => axilClk,            -- [in]
           rst     => axilRst,            -- [in]
-- SN65HVD1780QDRQ1 interface (RS485 transceiver) --
           rx      => rec_Data,            --[in]
           rx_En   => rec_En,             --[out]
           tx      => driver_Data,        --[out]
           tx_En   => driver_En,          --[out]
           
-- Mobus Data --    
           wrData     => mbData,          --[in]
           wrValid    => '1',             --[in]    --- still need to work on this
          
           rdReady    => '1'              --[in]    --- still need to work on this
           );

         

end top_level;
