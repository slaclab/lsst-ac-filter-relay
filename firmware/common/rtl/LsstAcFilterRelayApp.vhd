-----------------------------------------------------------------
--                                                             --
-----------------------------------------------------------------
--
--      LsstAcFilterRelayApp.vhd -
--
--      Copyright(c) SLAC National Accelerator Laboratory 2000
--
--      Author: 
--      Created on: 
--      Last change: 
--
-------------------------------------------------------------------------------
-- File       : LsstAcFilterRelay.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-02-04
-- Last update: 2017-08-02
-------------------------------------------------------------------------------
-- Description: Firmware Target's Top Level
-- 
-- Note: Common-to-Application interface defined in HPS ESD: LCLSII-2.7-ES-0536
-- 
-------------------------------------------------------------------------------
-- This file is part of 'firmware-template'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'firmware-template', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;
use work.AxiLitePkg.all;



entity LsstAcFilterRelayApp is
  generic (
    TPD_G            : time            := 1ns;
    AXI_BASE_ADDR_G    : slv(31 downto 0)        := x"00000000";
    AXI_CLK_FREQ_C   : real            := 156.0E+6;
    AXI_ERROR_RESP_G : slv(1 downto 0) := AXI_RESP_DECERR_C

    );
  port (

-- Slave AXI-Lite Interface
    axilClk         : in  sl;
    axilRst         : in  sl;
    axilReadMaster  : in  AxiLiteReadMasterType;
    axilReadSlave   : out AxiLiteReadSlaveType;
    axilWriteMaster : in  AxiLiteWriteMasterType;
    axilWriteSlave  : out AxiLiteWriteSlaveType;

-- Relay Okay signals
    relOK : out slv (11 downto 0);      --relay Okay signal to 

    
-- SN65HVD1780QDRQ1 interface (RS485 transceiver)
    rec_Data    : in    sl; --
    rec_En      : in    sl; --
    driver_En   : in    sl; --
    driver_Data : in    sl -- 
    
    );
end entity LsstAcFilterRelayApp;

architecture Behavioral of LsstAcFilterRelayApp is

 
  -------------------------------------------------------------------------------------------------
  -- AXI Lite Config and Signals
  -------------------------------------------------------------------------------------------------

  constant BOARD_INDEX_C : natural := 0;

  constant NUM_AXI_MASTERS_C : natural := 6;

  constant AXI_CROSSBAR_MASTERS_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXI_MASTERS_C-1 downto 0) := (
    BOARD_INDEX_C   => (
      baseAddr      => AXI_BASE_ADDR_G + x"0000_0000",
      addrBits      => 12,
      connectivity  => X"0001"),
    BOARD_INDEX_C+1 => (
      baseAddr      => AXI_BASE_ADDR_G + x"0000_1000",
      addrBits      => 12,
      connectivity  => X"0001"),
    BOARD_INDEX_C+2 => (
      baseAddr      => AXI_BASE_ADDR_G + x"0000_2000",
      addrBits      => 12,
      connectivity  => X"0001"),
    BOARD_INDEX_C+3 => (
      baseAddr      => AXI_BASE_ADDR_G + x"0000_3000",
      addrBits      => 12,
      connectivity  => X"0001"),
    BOARD_INDEX_C+4 => (
      baseAddr      => AXI_BASE_ADDR_G + x"0000_4000",
      addrBits      => 12,
      connectivity  => X"0001"),
    BOARD_INDEX_C+5 => (
      baseAddr      => AXI_BASE_ADDR_G + x"0000_5000",
      addrBits      => 12,
      connectivity  => X"0001")
    );

  signal locAxilWriteMasters : AxiLiteWriteMasterArray(NUM_AXI_MASTERS_C-1 downto 0);
  signal locAxilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXI_MASTERS_C-1 downto 0);
  signal locAxilReadMasters  : AxiLiteReadMasterArray(NUM_AXI_MASTERS_C-1 downto 0);
  signal locAxilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXI_MASTERS_C-1 downto 0);

begin


  ---------------------------
  -- AXI-Lite Crossbar Module
  ---------------------------        
  U_Xbar : entity work.AxiLiteCrossbar
    generic map (
      TPD_G              => TPD_G,
      DEC_ERROR_RESP_G   => AXI_ERROR_RESP_G,
      NUM_SLAVE_SLOTS_G  => 1,
      NUM_MASTER_SLOTS_G => NUM_AXI_MASTERS_C,
      MASTERS_CONFIG_G   => AXI_CROSSBAR_MASTERS_CONFIG_C)
    port map (
      axiClk              => axilClk,
      axiClkRst           => axilRst,
      sAxiWriteMasters(0) => axilWriteMaster,
      sAxiWriteSlaves(0)  => axilWriteSlave,
      sAxiReadMasters(0)  => axilReadMaster,
      sAxiReadSlaves(0)   => axilReadSlave,
      mAxiWriteMasters    => LocAxilWriteMasters,
      mAxiWriteSlaves     => LocAxilWriteSlaves,
      mAxiReadMasters     => LocAxilReadMasters,
      mAxiReadSlaves      => LocAxilReadSlaves);

  ---------------------------
  -- Relay register
  ---------------------------  
 U_RelayReg : entity work.RelayReg
    generic map(
     TPD_G            => TPD_G
    -- AXI_ERROR_RESP_G => AXI_RESP_DECERR_C
     )
   port map ( 
     -- Slave AXI-Lite Interface
      axilClk             => axilClk,
      axilRst             => axilRst,
      axilReadMaster      => axilReadMaster,
      axilReadSlave       => axilReadSlave,
      axilWriteMaster     => axilWriteMaster,
      axilWriteSlave      => axilWriteSlave,
     
     -- Relay Control    
      relOK               => relOK
     );
  
  
  
end Behavioral;


