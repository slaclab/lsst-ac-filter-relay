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
-- Last update: 2018-05-04
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
    TPD_G : time := 1 ns);
  port (
    -- Slave AXI-Lite Interface
    axilClk         : in  sl;
    axilRst         : in  sl;
    axilReadMaster  : in  AxiLiteReadMasterType;
    axilReadSlave   : out AxiLiteReadSlaveType;
    axilWriteMaster : in  AxiLiteWriteMasterType;
    axilWriteSlave  : out AxiLiteWriteSlaveType;
    -- RX Interface
    rxValid         : in  sl;
    rxData          : in  slv(63 downto 0);
    -- TX Interface
    txValid         : out sl;
    -------wrNotValid      : in  sl;
    txData          : out slv(47 downto 0);
    txReady         : in  sl);
end CurrentSenseReg;

architecture Behavioral of CurrentSenseReg is

  type RegType is record
    modbusTxHi     : slv(31 downto 0);
    modbusTxLo     : slv(31 downto 0);
    rxData         : slv(63 downto 0);
    txValid        : sl;
    rxValid        : sl;
    axilReadSlave  : AxiLiteReadSlaveType;
    axilWriteSlave : AxiLiteWriteSlaveType;
  end record;

  constant REG_INIT_C : RegType := (
    modbusTxHi     => x"00_00_00_00",
    modbusTxLo     => x"00_00_00_00",
    rxData         => (others => '1'),
    txValid        => '0',
    rxValid        => '0',
    axilReadSlave  => AXI_LITE_READ_SLAVE_INIT_C,
    axilWriteSlave => AXI_LITE_WRITE_SLAVE_INIT_C);

  signal r   : RegType := REG_INIT_C;
  signal rin : RegType;

begin

  comb : process (axilReadMaster, axilRst, axilWriteMaster, r, rxData,
                  rxValid, txReady) is
    variable v         : RegType;
    variable axilEp    : AxiLiteEndpointType;
    variable axiStatus : AxiLiteStatusType;
  begin
    -- Latch the current value
    v := r;

    -- Reset the strobe
      v.txValid := '0';

    -- Check for valid
    if (rxValid = '1') then
      -- Sample the bus
      v.rxData  := rxData;
      -- Set the flag
      v.rxValid := '1';
    end if;

    -- Check if ready for data
    if (txReady = '1') then

      -- Determine the AXI-Lite transaction
      axiSlaveWaitTxn(axilEp, axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave);

      -- Map the register space
      axiSlaveRegister(axilEp, X"00", 0, v.modbusTxHi);  -- 4 high byte of modbus 
      axiSlaveRegister(axilEp, X"04", 0, v.modbusTxLo);  -- 4 low byte of modbus 
      axiWrDetect(axilEp, x"04", v.txValid);

      axiSlaveRegisterR(axilEp, X"08", 0, r.rxData(63 downto 32));
      axiSlaveRegisterR(axilEp, X"0C", 0, r.rxData(31 downto 0));
      axiSlaveRegisterR(axilEp, X"10", 0, r.rxValid);

      -- Close out the AXI-Lite transaction
      axiSlaveDefault(axilEp, v.axilWriteSlave, v.axilReadSlave);

    end if;

    -- Check for write transaction
    if (r.txValid = '1') then
      -- Reset the bus
      v.rxData  := (others => '1');
      -- Reset the flag
      v.rxValid := '0';
    end if;

    -- Reset
    if (axilRst = '1') then
      v := REG_INIT_C;
    end if;

    -- Register the variable for next clock cycle
    rin <= v;

    -- Registered Outputs       
    axilWriteSlave <= r.axilWriteSlave;
    axilReadSlave  <= r.axilReadSlave;
    txValid        <= r.txValid;
    txData         <= r.modbusTxHi & r.modbusTxLo(31 downto 16);  --only the first 2 left-most bytes of the lower 8 bytes are used

  end process comb;

  seq : process (axilClk) is
  begin
    if (rising_edge(axilClk)) then
      r <= rin;
    end if;
  end process seq;

end architecture Behavioral;
