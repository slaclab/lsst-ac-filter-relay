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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.StdRtlPkg.all;

entity ModbusMaster is

   generic (
      TPD_G             : time                  := 1 ns;
      CLK_FREQ_G        : real                  := 125.0e6;
      BAUD_RATE_G       : integer               := 115200;
      FIFO_BRAM_EN_G    : boolean               := false;
      FIFO_ADDR_WIDTH_G : integer range 4 to 48 := 4);
   
   port (
-- SN65HVD1780QDRQ1 interface (RS485 transceiver) --
       rec_Data    : in sl; 
       rec_En      : out sl; --needs to be not(driver_en)
       driver_Data : out sl; --needs to be not(rec_en)
       driver_En   : out sl;
   
   
-- Modbus Data TX --    
       mbDataTx    : in slv(47 downto 0);

-- clk & rst signal --   
      clk     : in  sl;
      rst     : in  sl
      );

end entity ModbusMaster;

--------------------------------------------------------------------------------------------------------------------

architecture rtl of ModbusMaster is



  signal baud16x : sl;
  
  
begin

-------------------------------------------------------------------------------------------------
-- Baud Rate Generator.
-- Create a clock enable that is 16x the baud rate.
-- UartTx and UartRx use this.
-------------------------------------------------------------------------------------------------
  U_UartBrg_1 : entity work.UartBrg
    generic map (
      CLK_FREQ_G   => CLK_FREQ_G,
      BAUD_RATE_G  => BAUD_RATE_G,
      MULTIPLIER_G => 16)
    port map (
      clk   => clk,                  -- [in]
      rst   => rst,                  -- [in]
      clkEn => baud16x);             -- [out]


-------------------------------------------------------------------------------------------------
-- Modbus transmitter
-------------------------------------------------------------------------------------------------
  U_ModbusTx : entity work.ModbusTx
    generic map (
      TPD_G		  => TPD_G
      )
    port map (
      clk			=> clk,
      rst           => rst,
      baud16x       => baud16x,
      wrData        => mbDataTx,
      wrValid       => '0',
      wrReady       => driver_En,
      tx            => driver_Data
      );

-------------------------------------------------------------------------------------------------
-- Modbus receiver
-------------------------------------------------------------------------------------------------
--  U_ModbusRx : entity work.ModbusRx
--  generic map (
--    TPD_G          => TPD_G,
--    TIMEOUT_G   => "100"
--    )
--  port map (
 
--    );


end architecture rtl;