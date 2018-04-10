-------------------------------------------------------------------------------
-- File       : UartAxiLiteMaster.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2016-06-09
-- Last update: 2016-06-09
-------------------------------------------------------------------------------
-- Description: Ties together everything needed for a full duplex UART.
-- This includes Baud Rate Generator, Transmitter, Receiver and FIFOs.
-------------------------------------------------------------------------------
-- This file is part of 'SLAC Firmware Standard Library'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC Firmware Standard Library', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.StdRtlPkg.all;

entity ModbusRTU is

   generic (
   	 --1 character-time = 8bit
     --3.5 character-time = 28 bit
     --1 bit is 16 rising edge of the baud16x "clock"
     --therefore it will take 448 baud16x count to = 3.5 character time
     TIMEOUT_G        : slv(11 downto 0) := x"1C0"; --  d'448=x'1C0
     TIMEOUT_RESET_G  : slv(11 downto 0) := x"000";
     
     RESP_TIMEOUT_G   : slv(11 downto 0) := x"fff"; --arbitrary time to wait for response before timing out
   
      TPD_G             : time                  := 1 ns;
      CLK_FREQ_G        : real                  := 125.0e6;
      BAUD_RATE_G       : integer               := 115200;
      FIFO_BRAM_EN_G    : boolean               := false;
      FIFO_ADDR_WIDTH_G : integer range 4 to 48 := 4);
   port (
      clk     : in  sl;
      rst     : in  sl;
      -- Transmit parallel interface
      wrData  : in  slv(47 downto 0);
      wrValid : in  sl;
      wrReady : out sl;
      -- Receive parallel interface
      rdData  : out slv(7 downto 0);
      rdValid : out sl;
      rdReady : in  sl;
      
-- SN65HVD1780QDRQ1 interface (RS485 transceiver) --
      rx      : in sl; 
      rx_En   : out sl; --needs to be not(driver_en)
      tx      : out sl; 
      tx_En   : out sl --needs to be not(rec_en)

      );

end entity ModbusRTU;

architecture rtl of ModbusRTU is
	
	type StateType is (
      TX_INIT_S,
      TX_IDLE_S,
      TX_CALC_CRC_S,
      TX_INTERMEDIATE_S,
      TX_TRANSMIT_S,
      
      RX_REC_RESP_S,
      RX_PROCESS_RESP_S,
      RX_ERROR_S
    );

    type RegType is record
	  wrReady      : sl;
	  data	       : slv(63 downto 0);
	  charTime	   : slv(8 downto 0);
	  mbState	   : StateType;
	  crcValid     : sl;
	  holdReg      : slv(47 downto 0);
	  crcReset     : sl;
	  uartTxValid  : sl;
	  count        : slv(3 downto 0);
	  fifoDin      : slv(7 downto 0);
	  errorFlag    : slv(2 downto 0);
	  
      responseData : slv(63 downto 0);
	end record RegType;

   constant REG_INIT_C : RegType := (
	  wrReady   => '0',
	  data	    => (others => '0'),
	  charTime	=> (others => '0'),
	  mbState	=> TX_INIT_S,
	  crcValid  => '0',
	  holdReg   => (others => '0'),
	  crcReset  => '0',
	  uartTxValid => '0',
	  count     => x"0",
	  fifoDin   => x"00",
	  errorFlag => "000",       -- "000" no error - "001" response timedout
	  
	  responseData => (others => '0')
	  );

   signal uartTxData  : slv(7 downto 0);
   signal uartTxValid : sl;
   signal uartTxReady : sl;
   signal uartTxRdEn  : sl;
   signal fifoTxData  : slv(7 downto 0);
   signal fifoTxValid : sl;
   signal fifoTxReady : sl;

   signal uartRxData     : slv(7 downto 0);
   signal uartRxValid    : sl;
   signal uartRxValidInt : sl;
   signal uartRxReady    : sl;
   signal fifoRxData     : slv(7 downto 0);
   signal fifoRxValid    : sl;
   signal fifoRxReady    : sl;
   signal fifoRxRdEn     : sl;

   signal baud16x : sl;

   signal r 	: RegType := REG_INIT_C;
   signal rin : RegType;

   signal crcOut   : slv(15 downto 0);
   signal crcRem   : slv(15 downto 0);


  
begin

	
    comb : process (baud16x, r, rst, wrValid ) is
      variable v : RegType;
    begin
      v := r;
      
      v.crcValid :='0';
      v.crcReset :='0';
      
      case r.mbState is
      
        when TX_INIT_S =>
          if (baud16x = '1') then
            v.charTime   := r.charTime + 1;
            if (r.charTime = TIMEOUT_G) then    --Modbus requires silince of atleast 3.5 character time
              v.mbState  := TX_IDLE_S;
              v.charTime := TIMEOUT_RESET_G;
            end if;
          end if;
      
        when TX_IDLE_S =>
          v.wrReady    := '1';
          if (wrValid = '1' and r.wrReady = '1') then
            v.wrReady  := '0';
            v.crcReset := '1';          --reset crc before sending in the next data
            v.mbState  := TX_CALC_CRC_S;
          end if;
        
        when TX_CALC_CRC_S =>
          v.holdReg  := wrData;     --CRC data in
          v.crcValid := '1';
          v.mbState  := TX_INTERMEDIATE_S;
        
        when TX_INTERMEDIATE_S =>         
        --probably wait until crc finish before loading into v.data
          v.data := wrData & crcout(7 downto 0) & crcOut(15 downto 8);  --original data + CRC low + CRC hi per Modbus protocol
          v.mbState  := TX_TRANSMIT_S;
        
        when TX_TRANSMIT_S =>
          if (fifoTxReady = '1') then
            case r.count is 
              when x"0" =>
                v.fifoDin := r.data(63 downto 56);  --MBID address of control unit
                v.count := r.count + 1;

              when x"1" =>
                v.fifoDin := r.data(55 downto 48);  --Function code
                v.count := r.count + 1;
                
              when x"2" =>
                v.fifoDin := r.data(47 downto 40);  --Starting address (hi)
                v.count := r.count + 1;
              
              when x"3" =>
                v.fifoDin := r.data(39 downto 32);  --Starting address (lo)
                v.count := r.count + 1;
              
              when x"4" =>
                v.fifoDin := r.data(31 downto 24);  --Qunatity of registers (hi)
                v.count := r.count + 1;
                
              when x"5" => 
                v.fifoDin := r.data(23 downto 16);  --Qunatity of registers (low)
                v.count :=r.count + 1;
                
              when x"6" =>
                v.fifoDin := r.data(15 downto 8);   -- CRC lo
                v.count := r.count + 1;
                
              when x"7" => 
                v.fifoDin := r.data(7 downto 0);   -- CRC hi
                v.count := x"0";
                v.mbState := RX_REC_RESP_S;
            
            end case;
          end if;
              
            
        when RX_REC_RESP_S =>
          if (baud16x = '1') then
            v.charTime   := r.charTime + 1;
            if (r.charTime = RESP_TIMEOUT_G) then    --response timed out
              v.mbState  := RX_ERROR_S;
              v.charTime := TIMEOUT_RESET_G;  
              v.errorFlag := "001";                  --set flag here for response timed-out error
            end if;
          end if;
          
          if (fifoRxValid = '1') then
            v.charTime   := TIMEOUT_RESET_G;        --reset timeout timer
            case r.count is 
            when x"0" =>
              v.responseData(63 downto 56) := fifoRxData;  --MBID address
              v.count := r.count + 1;

            when x"1" =>
              v.responseData(55 downto 48) := fifoRxData;  --Function code
              v.count := r.count + 1;
              
            when x"2" =>
              v.responseData(47 downto 40) := fifoRxData;  --Quantity of bytes in the data field (will be fixed at 2 bytes for now)
              v.count := r.count + 1;
            
            when x"3" =>
              v.responseData(39 downto 32) := fifoRxData;  --Register value (hi)
              v.count := r.count + 1;
            
            when x"4" =>
              v.responseData(31 downto 24) := fifoRxData;  --Register value (lo)
              v.count := r.count + 1;
              
            when x"5" =>  
              v.responseData(23 downto 16) := fifoRxData;  --CRC (lo)
              v.count :=r.count + 1;
              
            when x"6" =>
              v.responseData(15 downto 8)  := fifoRxData;   --CRC (hi)
              v.count := r.count + 1;
              
            when x"7" => 
              v.responseData(7 downto 0) := x"00";                 --nothing for now
              v.count := x"0";
              v.mbState := RX_PROCESS_RESP_S;
            end case;
          end if;
        
        when RX_PROCESS_RESP_S =>
          if (v.data(55 downto 48) /= v.responseData(55 downto 48)) then --compare sent and rec function code. They should be the same if no error.
            if(v.responseData(55 downto 52) = 1000) then                 --per modbus protocol, this byte should be empty. Error if MSB is 1.
              v.errorFlag := v.responseData(47 downto 40);               
                    --error exception code returned in data field. Data fields starts from bit 47 down.
                    ----------------------------------------------------------------------------------------
                    --Code   Name                 Description
                    --01h    Illiegal function    Function is not supported
                    --02h    Illegal data addr    Reg addr is out of range / trying to read write only reg
                    --03h    Illegal data value   Value is out of range
                    --04h    Slave device fault   Unrecoverable error, e.g. time-out
                    --06h    Slave device busy    Unit busy. Requested action not possible
                    ------------------------------------------------------------------------------------------
              v.mbState := RX_ERROR_S;
            end if;
          end if;
       
        when RX_ERROR_S =>
          v.mbState := TX_INIT_S;
          
      end case;
    
      if (rst = '1') then
        v := REG_INIT_C;
      end if;
      
      rin  <= v;
      
    end process comb; 
    
   
    seq : process (clk) is
    begin
      if (rising_edge(clk)) then
        r <= rin after TPD_G;
      end if;
    end process seq; 
    












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
   -- UART transmitter
   -------------------------------------------------------------------------------------------------
   U_UartTx_1 : entity work.UartTx
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => clk,                -- [in]
         rst     => rst,                -- [in]
         baud16x => baud16x,            -- [in]
         wrData  => uartTxData,         -- [in]
         wrValid => uartTxValid,        -- [in]
         wrReady => uartTxReady,        -- [out]
         tx      => tx);                -- [out]

   -------------------------------------------------------------------------------------------------
   -- FIFO to feed UART transmitter
   -------------------------------------------------------------------------------------------------
   wrReady     <= fifoTxReady;
   fifoTxData  <= wrData;
   fifoTxValid <= wrValid and fifoTxReady;
   uartTxRdEn  <= uartTxReady and uartTxValid;
   U_Fifo_Tx : entity work.Fifo
      generic map (
         TPD_G           => TPD_G,
         GEN_SYNC_FIFO_G => true,
         BRAM_EN_G       => FIFO_BRAM_EN_G,
         FWFT_EN_G       => true,
         PIPE_STAGES_G   => 0,
         DATA_WIDTH_G    => 8,
         ADDR_WIDTH_G    => FIFO_ADDR_WIDTH_G)
      port map (
         rst      => rst,               -- [in]
         wr_clk   => clk,               -- [in]
         wr_en    => fifoTxValid,       -- [in]
         din      => fifoTxData,        -- [in]
         not_full => fifoTxReady,       -- [out]
         rd_clk   => clk,               -- [in]
         rd_en    => uartTxRdEn,        -- [in]
         dout     => uartTxData,        -- [out]
         valid    => uartTxValid);      -- [out]

   -------------------------------------------------------------------------------------------------
   -- UART Receiver
   -------------------------------------------------------------------------------------------------
   U_UartRx_1 : entity work.UartRx
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => clk,                -- [in]
         rst     => rst,                -- [in]
         baud16x => baud16x,            -- [in]
         rdData  => uartRxData,         -- [out]
         rdValid => uartRxValid,        -- [out]
         rdReady => uartRxReady,        -- [in]
         rx      => rx);                -- [in]

   -------------------------------------------------------------------------------------------------
   -- FIFO for UART Received data
   -------------------------------------------------------------------------------------------------
   fifoRxRdEn     <= fifoRxReady and fifoRxValid;
   uartRxValidInt <= uartRxValid and uartRxReady;

   rdData      <= fifoRxData; --this needs to change 
   rdValid     <= fifoRxValid;
   fifoRxReady <= rdReady;

   U_Fifo_Rx : entity work.Fifo
      generic map (
         TPD_G           => TPD_G,
         GEN_SYNC_FIFO_G => true,
         BRAM_EN_G       => FIFO_BRAM_EN_G,
         FWFT_EN_G       => true,
         PIPE_STAGES_G   => 0,
         DATA_WIDTH_G    => 8,
         ADDR_WIDTH_G    => FIFO_ADDR_WIDTH_G)
      port map (
         rst      => rst,               -- [in]
         wr_clk   => clk,               -- [in]
         wr_en    => uartRxValidInt,    -- [in]
         din      => uartRxData,        -- [in]
         not_full => uartRxReady,       -- [out]
         rd_clk   => clk,               -- [in]
         rd_en    => fifoRxRdEn,        -- [in]
         dout     => fifoRxData,        -- [out]
         valid    => fifoRxValid);      -- [out]

end architecture rtl;
