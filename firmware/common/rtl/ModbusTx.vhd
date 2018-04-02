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
-- File       : ModbusTX.vhd
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
use ieee.std_logic_unsigned.all;
use work.StdRtlPkg.all;
use work.AxiLitePkg.all;

entity ModbusTx is
generic (
	TPD_G		    : time		:= 1 ns;
	
	--1 character-time = 8bit
	--3.5 character-time = 28 bit
	--1 bit is 16 rising edge of the baud16x "clock"
	--therefore it will take 448 baud16x count to = 3.5 character time
	TIMEOUT_G	    : slv(8 downto 0) := x"1C0"; --  d'448=x'1C0
	TIMEOUT_RESET_G : slv(8 downto 0) := x"000"
);

Port (
	clk			: in sl;
	rst			: in sl;
	baud16x		: in sl;
	wrData		: in slv(47 downto 0); -- lsb -> msb : 1byte ID, 1 byte func, 2 byte addr, 2 byte read quantity
	wrValid		: in sl;
	wrReady		: out sl;	
	dataTx		: out slv(63 downto 0); --wrData appendded with CRC
	tx          : out sl

);
end entity ModbusTX;


architecture Behavioral of ModbusTx is
	
	type StateType is (
	  TX_INIT_S,
	  TX_IDLE_S,
	  TX_CALC_CRC_S,
	  TX_TRANSMIT_S
	  );
	  
		
	type RegType is record
	  wrReady      : sl;
	  data	       : slv(63 downto 0);
	  charTime	   : slv(8 downto 0);
	  txState	   : StateType;
	  crcValid     : sl;
	  holdReg      : slv(47 downto 0);
	  crcReset     : sl;
	end record RegType;
	 
	 
	constant REG_INIT_C : RegType := (
	  wrReady   => '0',
	  data	    => (others => '0'),
	  charTime	=> (others => '0'),
	  txState	=> TX_INIT_S,
	  crcValid  => '0',
	  holdReg   => (others => '0'),
	  crcReset  => '0'
	  );
	  
	 signal r 	: RegType := REG_INIT_C;
	 signal rin : RegType;
	 
     signal crcOut   : slv(15 downto 0);
	 signal crcOutLo : slv(7 downto 0);
	 signal crcOutHi : slv(7 downto 0);
     signal crcRem   : slv(15 downto 0);

     signal uartTxValid : sl;
     signal uartTxReady : sl;

	
  begin
	
	
	
   -------------------------------------------------------------------------------------------------
  -- Instantiate Crc16Parallel
  -------------------------------------------------------------------------------------------------    
   U_Crc16Parallel_Tx : entity work.Crc16Parallel
      generic map (
        TPD_G            => TPD_G,
        BYTE_WIDTH_G     => 6,
        INPUT_REGISTER_G => true,
        CRC_INIT_G       => x"FFFF"
        )
        
      port map(
        crcOut            => crcOut,            --[out]
        crcClk            => clk,               --[in]
        crcDataValid      => rin.crcValid,      --[in]
        crcDataWidth      => "101",             --[in]           -- 000=1, 001=2, 010=3, ... 101=6 data byte
        crcIn             => rin.holdReg,       --[in]
        crcReset          => rin.crcReset       --[in]
      );
		
		
   -------------------------------------------------------------------------------------------------
   -- UART transmitter
   -------------------------------------------------------------------------------------------------
   U_UartTx_1 : entity work.UartTx
     generic map (
       TPD_G => TPD_G)
     port map (
       clk     => clk,                -- [in]
       rst     => rst,                -- [in]
       baud16x => baud16x,            -- [in]
       wrData  => rin.data,           -- [in]
       wrValid => uartTxValid,        -- [in]
       wrReady => uartTxReady,        -- [out]
       tx => tx); -- [out]


		
    combCrc : process (baud16x, r, rst, wrValid ) is
      variable v : RegType;
    begin
      v := r;
      
      case r.txState is
      
        when TX_INIT_S =>
          if (baud16x = '1') then
            v.charTime   := r.charTime + 1;
            if (r.charTime = TIMEOUT_G) then
              v.txState  := TX_IDLE_S;
              v.charTime := TIMEOUT_RESET_G;
            end if;
          end if;
      
        when TX_IDLE_S =>
          v.wrReady   := '1';
          if (wrValid = '1' and r.wrReady = '1') then
            v.wrReady := '0';
            v.txState := TX_CALC_CRC_S;
          end if;
        
        when TX_CALC_CRC_S =>
          v.holdReg  := wrData;
          v.crcValid := '1';
          v.txState  := TX_TRANSMIT_S;
          
        when TX_TRANSMIT_S =>
          v.data := wrData & crcOutLo & crcOutHi;
          
      end case;
    
      if (rst = '1') then
        v := REG_INIT_C;
      end if;
      
      rin  <= v;
      
    end process;
    
   
    seq : process (clk) is
    begin
      if (rising_edge(clk)) then
        r <= rin after TPD_G;
      end if;
    end process seq;

end architecture Behavioral;
