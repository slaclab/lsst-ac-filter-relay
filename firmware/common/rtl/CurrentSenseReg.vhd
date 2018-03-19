-----------------------------------------------------------------
--                                                             --
-----------------------------------------------------------------
--
--      CurrentSenseReg.vhd -
--
--      Copyright(c) SLAC National Accelerator Laboratory 2000
--
--      Author: Van Xiong
--      Created on: 2018-02-04
--      Last change: 2018-02-28
--
-------------------------------------------------------------------------------
-- File       : CurrentSenseReg.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2018-03-14
-- Last update: 2018-03-14
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


entity CurrentSenseReg is
generic (
	TPD_G              : time             := 1 ns);
 
Port ( 

-- Slave AXI-Lite Interface
    axilClk         : in  sl;
    axilRst         : in  sl;
    axilReadMaster  : in  AxiLiteReadMasterType;
    axilReadSlave   : out AxiLiteReadSlaveType;
    axilWriteMaster : in  AxiLiteWriteMasterType;
    axilWriteSlave  : out AxiLiteWriteSlaveType;

-- ModbusCtrl
	mbDataTx		  : out slv(63 downto 0)
			--mbid          : out slv(7 downto 0);
			--functionCode  : out slv(7 downto 0);
			--sensorAddress : out slv(15 downto 0);
			--wrdata		: out slv(15 downto 0);
			--CRC		    : out slv(15 downto 0);
    );
end CurrentSenseReg;

architecture Behavioral of CurrentSenseReg is

    type RegType is record
      mobusDataTx             :  slv(63 downto 0);
      axilReadSlave     :  AxiLiteReadSlaveType;
      axilWriteSlave    :  AxiLiteWriteSlaveType;
    end record;   
      
    constant REG_INIT_C : RegType := (
      mobusDataTx      => x"00_00_0000_0000_0000",
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
          r <= rin;
      end if;
    end process seq;
--end of sequential block--------------------------------
   
   
--start of combinational block---------------------------   
    comb : process (r, axilRst, axilReadMaster, axilWriteMaster) is
      variable v : RegType;
      variable axilEp : AxiLiteEndpointType;
    begin
      v := r; --initialize v
      
      axiSlaveWaitTxn(axilEp, axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave);
      
      axiSlaveRegister(axilEp, X"00", 0, v.mobusDataTx);  -- Register 0 -- 12 on/off bit in 11-0  
      axiSlaveDefault(axilEp, v.axilWriteSlave, v.axilReadSlave);   
      
      if (axilRst = '1') then 
        v := REG_INIT_C;
      end if;
      
      rin <= v;
     
      mbDataTx  <= r.mobusDataTx;
      axilWriteSlave  <= r.axilWriteSlave;      
      axilReadSlave  <= r.axilReadSlave;  
     
    end process comb;
--end of combinational block-----------------------------    
end architecture Behavioral;
