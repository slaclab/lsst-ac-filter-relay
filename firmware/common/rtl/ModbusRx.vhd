-----------------------------------------------------------------
--                                                             --
-----------------------------------------------------------------
--
--      Modbus.vhd -
--
--      Copyright(c) SLAC National Accelerator Laboratory 2000
--
--      Author: Van Xiong
--      Created on: 2018-03-22
--      Last change: 2018-03-22
--
-------------------------------------------------------------------------------
-- File       : Modbus.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2018-03-22
-- Last update: 2018-03-22
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

entity ModbusRX is
generic (
	TPD_G		: time		:= 1 ns
);

Port (
	clk			: in sl;
	rst			: in sl;
	baud		: in sl
	);
end entity ModbusRX;

architecture Behavioral of ModbusRX is
	
	type StateType is (
	  RX_INIT_S,
	  RX_IDLE_S,
	  RX_RCV_S,
	  RX_ERROR_S
	  );
		
	type RegType is
	record
	  rdValid      : sl;
	  rdData       : slv(7 downto 0);
	  rxState      : stateType;
	  rxShiftReg   : slv(7 downto 0);
	  rxShiftCount : slv(2 downto 0);
	  baud16xCount : slv(3 downto 0);
	end record;
	
	constant REG_INIT_C : RegType := (
	  rdValid      => '0',
	  rdData       => (others => '0'),
	  rxState      => RX_INIT_S,
	  rxShiftReg   => (others => '0'),
	  rxShiftCount => (others => '0'),
	  baud16xCount => (others => '0'));
	
	signal r   : RegType := REG_INIT_C;
	signal rin : RegType;
		

begin
	

		
	
	  
		
		
		






end architecture Behavioral;
