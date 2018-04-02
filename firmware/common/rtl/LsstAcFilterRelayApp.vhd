-----------------------------------------------------------------
--                                                             --
-----------------------------------------------------------------
--
--      LsstAcFilterRelayApp.vhd -
--
--      Copyright(c) SLAC National Accelerator Laboratory 2000
--
--      Author: Van Xiong
--      Created on: 2018-02-04
--      Last change: 2018-03-13
--
-------------------------------------------------------------------------------
-- File       : LsstAcFilterRelay.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2018-02-04
-- Last update: 2018-03-08
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
      TPD_G          : time := 1ns;
	  AXI_BASE_ADDR_G : slv(31 downto 0) := x"00000000";
	  AXI_ERROR_RESP_G : slv(1 downto 0) := AXI_RESP_DECERR_C;
      AXI_CLK_FREQ_C : real := 125.0E+6);
   port (

-- Slave AXI-Lite Interface
      axilClk         : in    sl;
      axilRst         : in    sl;
      axilReadMaster  : in    AxiLiteReadMasterArray(1 downto 0);
      axilReadSlave   : out   AxiLiteReadSlaveArray(1 downto 0);
      axilWriteMaster : in    AxiLiteWriteMasterArray(1 downto 0);
	  axilWriteSlave  : out   AxiLiteWriteSlaveArray(1 downto 0);


-- Relay Okay signals
      relOK : out slv (11 downto 0);    --relay Okay signal to 


-- SN65HVD1780QDRQ1 interface (RS485 transceiver)
      rec_Data    : in sl;              --
      rec_En      : out sl;             --
      driver_Data : in sl               -- 
	  driver_En   : out sl;             --
      );
end entity LsstAcFilterRelayApp;

architecture Behavioral of LsstAcFilterRelayApp is


  
  
begin

   -----------------------------------------------------------
   -- AXI entity
   -----------------------------------------------------------

   ---------------------------
   -- Relay register
   ---------------------------  
   U_RelayReg : entity work.RelayReg
      generic map(
         TPD_G => TPD_G
         )
      port map (
         -- Slave AXI-Lite Interface
         axilClk         => axilClk,
         axilRst         => axilRst,
        axilReadMaster  => axilReadMaster(0),
        axilReadSlave   => axilReadSlave(0),
        axilWriteMaster => axilWriteMaster(0),
        axilWriteSlave  => axilWriteSlave(0),


         -- Relay Control    
         relOK => relOK
         );

		 
		 
   -- Use AXI index 1 for MODBUS bridge
   
   ---------------------------
   -- Current Sense register
   --------------------------- 
	U_CurrentSense : entity work.CurrentSenseReg
     generic map(
        TPD_G => TPD_G
      -- AXI_ERROR_RESP_G => AXI_RESP_DECERR_C
        )
     port map (
        -- Slave AXI-Lite Interface
        axilClk         => axilClk,
        axilRst         => axilRst,
        axilReadMaster  => axilReadMaster(1),
        axilReadSlave   => axilReadSlave(1),
        axilWriteMaster => axilWriteMaster(1),
        axilWriteSlave  => axilWriteSlave(1)

        -- MODBUS Control    
        mbDataTx => mbDataTx
        );
		
	
   -----------------------------------------------------------
   -- NON-AXI entity
   -----------------------------------------------------------	
    U_Modbus : entity work.Modbus
      generic map (
	    TPD_G		: time		:= 1 ns
	  )
	
	  port map (
	    rec_Data	=> rec_Data,
		rec_En		=> rec_En,
		driver_En	=> driver_En,
		driver_Data	=> driver_Data,
		
		mbDataTx 	=> mbDataTx
	  );
	
   
   
   
		 
end Behavioral;


