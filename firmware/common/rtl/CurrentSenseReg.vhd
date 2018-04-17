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
	mbDataTx		: out slv(47 downto 0);
			--mbid          : out slv(7 downto 0);
			--functionCode  : out slv(7 downto 0);
			--sensorAddress : out slv(15 downto 0);
			--wrdata		: out slv(15 downto 0);
			--CRC		    : out slv(15 downto 0);
    
    mbDataRx        : in slv(63 downto 0);
            --mbid           : in slv(7 downto 0);
            --functionCode   : in slv(7 downto 0);
            --number of byte : in slv(7 downto 0);
            --rddata         : in slv(15 downto 0);
            --CRC            : in slv(15 downto 0);
            --x"00"          : in slv(7 downto 0);
    responseValid   : in sl;
    txValid         : out sl
    );
end CurrentSenseReg;

architecture Behavioral of CurrentSenseReg is

    type RegType is record
      modbusTxHi             :  slv(31 downto 0);
      modbusTxLo             :  slv(31 downto 0);
      respDataHi            :  slv(31 downto 0);
      respDataLo            :  slv(31 downto 0);
      txValid               : sl;
      
      axilReadSlave     :  AxiLiteReadSlaveType;
      axilWriteSlave    :  AxiLiteWriteSlaveType;
    end record;   
      
    constant REG_INIT_C : RegType := (
      modbusTxHi       => x"00_00_00_00",
      modbusTxLo       => x"00_00_00_00",
      respDataHi       => x"00_00_00_00",
      respDataLo       => x"00_00_00_00",
      txValid          => '0',
      
      axilReadSlave   => AXI_LITE_READ_SLAVE_INIT_C,
      axilWriteSlave  => AXI_LITE_WRITE_SLAVE_INIT_C
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
    comb : process (r, axilRst, axilReadMaster, axilWriteMaster, responseValid) is
      variable v : RegType;
      variable axilEp : AxiLiteEndpointType;
    begin
      v := r; --initialize v
      
      axiSlaveWaitTxn(axilEp, axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave);
      
      axiSlaveRegister(axilEp, X"00", 0, v.modbusTxHi);  -- 4 high byte of modbus 
      axiSlaveRegister(axilEp, X"04", 0, v.modbusTxLo);  -- 4 low byte of modbus 
      axiSlaveRegister(axilEp, X"08", 0, v.respDataHi);   
      axiSlaveRegister(axilEp, X"0C", 0, v.respDataLo);
      axiSlaveDefault(axilEp, v.axilWriteSlave, v.axilReadSlave);   
      
      if (axilRst = '1') then 
        v := REG_INIT_C;
      else
        v.txValid := '1';
      end if;
      
      if(responseValid = '1') then
        v.respDataHi := mbDataRx(63 downto 32);
        v.respDataLo := mbDataRx(31 downto 0);
      end if;
      
      rin <= v;
      
      mbDataTx  <= r.modbusTxHi & r.modbusTxLo(31 downto 16); --only the first 2 left-most bytes of the lower 8 bytes are used
      axilWriteSlave  <= r.axilWriteSlave;      
      axilReadSlave  <= r.axilReadSlave;  
      
      txValid <= r.txValid;
     
    end process comb;
--end of combinational block-----------------------------    
end architecture Behavioral;
