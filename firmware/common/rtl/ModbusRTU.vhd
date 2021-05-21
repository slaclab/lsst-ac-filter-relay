-------------------------------------------------------------------------------
-- File       : ModbusRTU.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Modbus RTU module.
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

library surf;
use surf.StdRtlPkg.all;

entity ModbusRTU is

   generic (
      --1 character-time = 8bit
      --3.5 character-time = 28 bit
      --1 bit is 16 rising edge of the baud16x "clock"
      --it will take 448 baud16x count to = 3.5 character time
      TIMEOUT_G       : slv(31 downto 0) := x"0000_01C0";  --  d'448
      TIMEOUT_RESET_G : slv(31 downto 0) := x"0000_0000";
      RESP_TIMEOUT_G  : slv(31 downto 0) := x"0010_0000";  --arbitrary time to wait for response before timing out

      --UART generics
      STOP_BITS_G  : integer range 1 to 2 := 2;
      PARITY_G     : string               := "NONE"; --"NONE "EVEN" "ODD"
      DATA_WIDTH_G : integer range 5 to 8 := 8;

      TPD_G             : time                  := 1 ns;
      CLK_FREQ_G        : real                  := 125.0e6;
      BAUD_RATE_G       : integer               := 115200;
      FIFO_BRAM_EN_G    : boolean               := false;
      FIFO_ADDR_WIDTH_G : integer range 4 to 48 := 4);
   port (
      clk : in sl;
      rst : in sl;

      mycounter : out slv(31 downto 0);
      errorCode : out slv(7 downto 0);
      -- Transmit parallel interface
      wrData    : in  slv(47 downto 0);
      wrValid   : in  sl;
      wrReady   : out sl;

      -- Receive parallel interface
      rdData  : out slv(255 downto 0);
      rdValid : out sl;
      rdReady : in  sl;

      -- SN65HVD1780QDRQ1 interface (RS485 transceiver) --
      rx    : in  sl;
      rx_En : out sl;                   --needs to be same as tx_En
      tx    : out sl;
      tx_En : out sl                    --needs to be same as rx_EN

      );

end entity ModbusRTU;

architecture rtl of ModbusRTU is

   type StateType is (
      TX_INIT_S,
      TX_IDLE_S,
      TX_CALC_CRC_S,
      TX_INTERMEDIATE_S,
      TX_TRANSMIT_S,
      TX_DELAY_S,
      TX_WAIT_S,
      RX_REC_RESP_S,
      RX_PROCESS_RESP_S);

   type RegType is record
      wrReady      : sl;
      data         : slv(63 downto 0);
      charTime     : slv(31 downto 0);
      mbState      : StateType;
      crcValid     : sl;
      holdReg      : slv(47 downto 0);
      crcReset     : sl;
      fifoTxValid  : sl;
      count        : slv(4 downto 0);
      fifoDin      : slv(7 downto 0);
      errorCode    : slv(7 downto 0);
      recFlag      : sl;
      mycounter    : slv(31 downto 0);
      responseData : slv(255 downto 0);
      txEnable     : sl;
      respValid    : sl;

   end record RegType;

   constant REG_INIT_C : RegType := (
      wrReady      => '0',
      data         => (others => '0'),
      charTime     => (others => '0'),
      mbState      => TX_INIT_S,
      crcValid     => '0',
      holdReg      => (others => '0'),
      crcReset     => '0',
      fifoTxValid  => '0',
      count        => (others => '0'),
      fifoDin      => x"00",
      errorCode    => x"00",            -- x"00" no error
      recFlag      => '0',
      mycounter    => (others => '0'),
      responseData => (others => '0'),
      txEnable     => '0',
      respValid    => '0'
      );

   signal uartTxData     : slv(7 downto 0);
   signal uartTxValid    : sl;
   signal uartTxReady    : sl;
   signal uartTxRdEn     : sl;
   signal fifoTxValid    : sl;
   signal fifoTxReady    : sl;
   signal fifoTxEmpty    : sl;
   signal uartRxData     : slv(7 downto 0);
   signal uartRxValid    : sl;
   signal uartRxValidInt : sl;
   signal uartRxReady    : sl;
   signal fifoRxData     : slv(7 downto 0);
   signal fifoRxValid    : sl;
   signal fifoRxReady    : sl;
   signal fifoRxRdEn     : sl;
   signal baud16x        : sl;
   signal r              : RegType := REG_INIT_C;
   signal rin            : RegType;
   signal crcOut         : slv(15 downto 0);
   signal crcRem         : slv(15 downto 0);

begin


   comb : process (baud16x, crcout, fifoRxData, fifoRxValid, fifoTxEmpty,
                   fifoTxReady, r, rst, uartTxReady, wrData, wrValid) is
      variable v : RegType;
   begin
      v := r;

      v.crcValid    := '0';
      v.crcReset    := '0';
      v.respValid   := '0';
      v.fifoTxValid := '0';

      case r.mbState is

         when TX_INIT_S =>
            if (baud16x = '1') then
               v.charTime := r.charTime + 1;
               if (r.charTime = TIMEOUT_G) then  --Modbus requires silence of at least 3.5 character time
                  v.mbState  := TX_IDLE_S;
                  v.charTime := TIMEOUT_RESET_G;
               end if;
            end if;
            v.txEnable := '0';

         when TX_IDLE_S =>
            v.wrReady := '1';
            if (wrValid = '1' and r.wrReady = '1') then
               v.wrReady      := '0';
               v.recFlag      := '0';
               v.errorCode    := x"00";
               v.crcReset     := '1';  --reset crc before sending in the next data
               v.responseData := (others => '0');  --reset response data
               v.mbState      := TX_CALC_CRC_S;
               v.mycounter    := r.mycounter + 1;
            end if;

         when TX_CALC_CRC_S =>
            v.holdReg  := wrData;       --CRC data in
            v.crcValid := '1';
            v.mbState  := TX_INTERMEDIATE_S;

         when TX_INTERMEDIATE_S =>
            v.charTime := r.charTime + 1;
            if (r.charTime = TIMEOUT_G) then  --arbitrary wait 
               v.charTime := TIMEOUT_RESET_G;
               v.data     := wrData & crcout(15 downto 8) & crcOut(7 downto 0);  --original data + CRC hi + CRC low per Modbus protocol
               v.mbState  := TX_TRANSMIT_S;
               v.txEnable := '1';
            end if;

         when TX_TRANSMIT_S =>
            if (fifoTxReady = '1') then
               v.count       := r.count + 1;
               v.fifoTxValid := '1';
               case r.count is
                  when "00000" => v.fifoDin := r.data(63 downto 56);  --MBID address of control unit
                  when "00001" => v.fifoDin := r.data(55 downto 48);  --Function code
                  when "00010" => v.fifoDin := r.data(47 downto 40);  --Starting address (hi)
                  when "00011" => v.fifoDin := r.data(39 downto 32);  --Starting address (lo)
                  when "00100" => v.fifoDin := r.data(31 downto 24);  --Quantity of registers (hi)
                  when "00101" => v.fifoDin := r.data(23 downto 16);  --Quantity of registers (low)
                  when "00110" => v.fifoDin := r.data(15 downto 8);   -- CRC lo
                  when "00111" =>
                     v.fifoDin := r.data(7 downto 0);                 -- CRC hi
                     v.count   := (others => '0');
                     v.mbState := TX_DELAY_S;
                  when others => null;
               end case;
            end if;
            
         when TX_DELAY_S =>
            v.mbState := TX_WAIT_S;

            --wait for UART to finish transmission
         when TX_WAIT_S =>
            if (fifoTxEmpty = '1' and uartTxReady = '1') then
               v.mbState := RX_REC_RESP_S;
            end if;

         when RX_REC_RESP_S =>
            v.txEnable := '0';
            if (fifoRxValid = '1') then
               v.charTime := TIMEOUT_RESET_G;         --reset timeout timer
               v.recFlag  := '1';
               v.count    := r.count + 1;
               --message frame: MBID 1 byte | Function Code 1 byte | byte count 1 byte | reg value 2n byte | CRClo 1 byte | CRChi 1byte
               case r.count is
                  when "00000" => v.responseData(255 downto 248) := fifoRxData;
                  when "00001" => v.responseData(247 downto 240) := fifoRxData;
                  when "00010" => v.responseData(239 downto 232) := fifoRxData;
                  when "00011" => v.responseData(231 downto 224) := fifoRxData;
                  when "00100" => v.responseData(223 downto 216) := fifoRxData;
                  when "00101" => v.responseData(215 downto 208) := fifoRxData;
                  when "00110" => v.responseData(207 downto 200) := fifoRxData;
                  when "00111" => v.responseData(199 downto 192) := fifoRxData;
                  when "01000" => v.responseData(191 downto 184) := fifoRxData;
                  when "01001" => v.responseData(183 downto 176) := fifoRxData;
                  when "01010" => v.responseData(175 downto 168) := fifoRxData;
                  when "01011" => v.responseData(167 downto 160) := fifoRxData;
                  when "01100" => v.responseData(159 downto 152) := fifoRxData;
                  when "01101" => v.responseData(151 downto 144) := fifoRxData;
                  when "01110" => v.responseData(143 downto 136) := fifoRxData;
                  when "01111" => v.responseData(135 downto 128) := fifoRxData;
                  when "10000" => v.responseData(127 downto 120) := fifoRxData;
                  when "10001" => v.responseData(119 downto 112) := fifoRxData;
                  when "10010" => v.responseData(111 downto 104) := fifoRxData;
                  when "10011" => v.responseData(103 downto 96)  := fifoRxData;
                  when "10100" => v.responseData(95 downto 88)   := fifoRxData;
                  when "10101" => v.responseData(87 downto 80)   := fifoRxData;
                  when "10110" => v.responseData(79 downto 72)   := fifoRxData;
                  when "10111" => v.responseData(71 downto 64)   := fifoRxData;
                  when "11000" => v.responseData(63 downto 56)   := fifoRxData;
                  when "11001" => v.responseData(55 downto 48)   := fifoRxData;
                  when "11010" => v.responseData(47 downto 40)   := fifoRxData;
                  when "11011" => v.responseData(39 downto 32)   := fifoRxData;
                  when "11100" => v.responseData(31 downto 24)   := fifoRxData;
                  when "11101" => v.responseData(23 downto 16)   := fifoRxData;
                  when "11110" => v.responseData(15 downto 8)    := fifoRxData;
                                  --when x"31"  => v.responseData(7 downto 0)     := fifoRxData;
                  when others  =>
                     v.mbState   := RX_PROCESS_RESP_S;
                     v.errorCode := x"bb";
                     v.count     := (others => '0');
               end case;
            end if;
            --silence of 3.5 character time indicate end of transmission
            if (baud16x = '1' and r.recFlag = '1') then
               v.charTime := r.charTime + 1;
               if (r.charTime = TIMEOUT_G) then
                  v.count    := (others => '0');
                  v.mbState  := RX_PROCESS_RESP_S;
                  v.charTime := TIMEOUT_RESET_G;
               end if;
            end if;
            --generate time-out error if no response received
            if (baud16x = '1' and r.recFlag = '0') then
               v.charTime := r.charTime + 1;
               if (r.charTime = RESP_TIMEOUT_G) then  --response timed out
                  v.count     := (others => '0');
                  v.mbState   := RX_PROCESS_RESP_S;
                  v.charTime  := TIMEOUT_RESET_G;
                  v.errorCode := x"aa";  --set flag here for response timed-out error
               end if;
            end if;

         when RX_PROCESS_RESP_S =>
            v.respValid := '1';
            v.mbState   := TX_INIT_S;

      end case;

      if (rst = '1') then
         v := REG_INIT_C;
      end if;

      rin       <= v;
      tx_En     <= r.txEnable;          --tx_En is active high
      rx_En     <= r.txEnable;          --rx_En is active low
      rdValid   <= r.respValid;
      rdData    <= r.responseData;
      mycounter <= r.mycounter;
      errorCode <= r.errorCode;

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
         CRC_INIT_G       => x"FFFF")
      port map(
         crcOut       => crcOut,         --[out]
         crcClk       => clk,            --[in]
         crcDataValid => rin.crcValid,   --[in]
         crcDataWidth => "101",  --[in]           -- 000=1, 001=2, 010=3, ... 101=6 data byte
         crcIn        => rin.holdReg,    --[in]
         crcReset     => rin.crcReset);  --[in]

   -------------------------------------------------------------------------------------------------
   -- Baud Rate Generator.
   -- Create a clock enable that is 16x the baud rate.
   -- UartTx and UartRx use this.
   -------------------------------------------------------------------------------------------------
   U_UartBrg_1 : entity surf.UartBrg
      generic map (
         CLK_FREQ_G   => CLK_FREQ_G,
         BAUD_RATE_G  => BAUD_RATE_G,
         MULTIPLIER_G => 16)
      port map (
         clk   => clk,                  -- [in]
         rst   => rst,                  -- [in]
         baudClkEn => baud16x);             -- [out]

   -------------------------------------------------------------------------------------------------
   -- UART transmitter
   -------------------------------------------------------------------------------------------------
   U_UartTx_1 : entity surf.UartTx
      generic map (
         TPD_G        => 1 ns,
         STOP_BITS_G  => STOP_BITS_G,
         PARITY_G     => PARITY_G,
         DATA_WIDTH_G => DATA_WIDTH_G)
      port map (
         clk     => clk,                -- [in]
         rst     => rst,                -- [in]
         baudClkEn => baud16x,            -- [in]
         wrData  => uartTxData,         -- [in]
         wrValid => uartTxValid,        -- [in]
         wrReady => uartTxReady,        -- [out]
         tx      => tx);                -- [out]

   -------------------------------------------------------------------------------------------------
   -- FIFO to feed UART transmitter
   -------------------------------------------------------------------------------------------------
   wrReady     <= fifoTxReady;
   fifoTxValid <= r.fifoTxValid and fifoTxReady;
   uartTxRdEn  <= uartTxReady and uartTxValid;
   U_Fifo_Tx : entity surf.Fifo
      generic map (
         TPD_G           => TPD_G,
         GEN_SYNC_FIFO_G => true,
         MEMORY_TYPE_G   => ite(FIFO_BRAM_EN_G,"block","distributed"),
         FWFT_EN_G       => true,
         PIPE_STAGES_G   => 0,
         DATA_WIDTH_G    => DATA_WIDTH_G,
         ADDR_WIDTH_G    => FIFO_ADDR_WIDTH_G)
      port map (
         rst      => rst,               -- [in]
         wr_clk   => clk,               -- [in]
         wr_en    => fifoTxValid,       -- [in]
         din      => r.fifoDin,         -- [in]
         not_full => fifoTxReady,       -- [out]
         rd_clk   => clk,               -- [in]
         rd_en    => uartTxRdEn,        -- [in]
         dout     => uartTxData,        -- [out]
         valid    => uartTxValid,       -- [out]
         empty    => fifoTxEmpty);      -- [out]

   -------------------------------------------------------------------------------------------------
   -- UART Receiver
   -------------------------------------------------------------------------------------------------
   U_UartRx_1 : entity surf.UartRx
      generic map (
         TPD_G        => 1 ns,
         PARITY_G     => PARITY_G,
         DATA_WIDTH_G => DATA_WIDTH_G)
      port map (
         clk     => clk,                -- [in]
         rst     => rst,                -- [in]
         baudClkEn => baud16x,            -- [in]
         rdData  => uartRxData,         -- [out]
         rdValid => uartRxValid,        -- [out]
         rdReady => uartRxReady,        -- [in]
         rx      => rx);                -- [in]

   -------------------------------------------------------------------------------------------------
   -- FIFO for UART Received data
   -------------------------------------------------------------------------------------------------
   fifoRxRdEn     <= fifoRxReady and fifoRxValid;
   uartRxValidInt <= uartRxValid and uartRxReady;

   fifoRxReady <= rdReady;

   U_Fifo_Rx : entity surf.Fifo
      generic map (
         TPD_G           => TPD_G,
         GEN_SYNC_FIFO_G => true,
         MEMORY_TYPE_G   => ite(FIFO_BRAM_EN_G,"block","distributed"),
         FWFT_EN_G       => true,
         PIPE_STAGES_G   => 0,
         DATA_WIDTH_G    => DATA_WIDTH_G,
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
