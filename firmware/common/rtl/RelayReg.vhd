-----------------------------------------------------------------
--                                                             --
-----------------------------------------------------------------
--
--      RelayReg.vhd -
--
--      Copyright(c) SLAC National Accelerator Laboratory 2000
--
--      Author: Van Xiong
--      Created on: 2018-02-04
--      Last change: 2018-02-28
--
-------------------------------------------------------------------------------
-- File       : RelayReg.vhd
-- Company    : SLAC National Accelerator Laboratory
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

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;

entity RelayReg is
   generic (
      TPD_G : time := 1 ns);

   port (

-- Slave AXI-Lite Interface
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;

-- Relay Control  
      relOK : out slv(11 downto 0)

      );
end RelayReg;

architecture Behavioral of RelayReg is

   type RegType is record
      relayOK        : slv(11 downto 0);
      axilReadSlave  : AxiLiteReadSlaveType;
      axilWriteSlave : AxiLiteWriteSlaveType;
   end record;
   
   constant REG_INIT_C : RegType := (
      relayOK        => x"000",
      axilReadSlave  => AXI_LITE_READ_SLAVE_INIT_C,
      axilWriteSlave => AXI_LITE_WRITE_SLAVE_INIT_C
      ); 

   --Output of register
   signal r   : RegType := REG_INIT_C;
   --input of register
   signal rin : RegType;
   
begin


   --start of sequential block----------------------------
   seq : process (axilClk) is
   begin
      if (rising_edge(axilClk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;
--end of sequential block--------------------------------


--start of combinational block---------------------------   
   comb : process (r, axilRst, axilReadMaster, axilWriteMaster) is
      variable v      : RegType;
      variable axilEp : AxiLiteEndpointType;
   begin
      v := r;                           --initialize v

      axiSlaveWaitTxn(axilEp, axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave);

      --axiSlaveRegister(axilEp, X"00", 0, v.relayOK);  -- Register 0 -- 12 on/off bit in 11-0  
      axiSlaveRegister(axilEp, X"00", 0, v.relayOK(0));
      axiSlaveRegister(axilEp, X"04", 0, v.relayOK(1));
      axiSlaveRegister(axilEp, X"08", 0, v.relayOK(2));
      axiSlaveRegister(axilEp, X"0C", 0, v.relayOK(3));
      axiSlaveRegister(axilEp, X"10", 0, v.relayOK(4));
      axiSlaveRegister(axilEp, X"14", 0, v.relayOK(5));
      axiSlaveRegister(axilEp, X"18", 0, v.relayOK(6));
      axiSlaveRegister(axilEp, X"1C", 0, v.relayOK(7));
      axiSlaveRegister(axilEp, X"20", 0, v.relayOK(8));
      axiSlaveRegister(axilEp, X"24", 0, v.relayOK(9));
      axiSlaveRegister(axilEp, X"28", 0, v.relayOK(10));
      axiSlaveRegister(axilEp, X"2C", 0, v.relayOK(11));

      axiSlaveDefault(axilEp, v.axilWriteSlave, v.axilReadSlave);

      if (axilRst = '1') then
         v := REG_INIT_C;
      end if;

      rin <= v;

      relOK          <= r.relayOK;
      axilWriteSlave <= r.axilWriteSlave;
      axilReadSlave  <= r.axilReadSlave;
      
   end process comb;
--end of combinational block-----------------------------    
end architecture Behavioral;
