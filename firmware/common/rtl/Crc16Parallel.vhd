-------------------------------------------------------------------------------
-- File       : Crc16Parallel.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description:
-- 16 bit CRC with 48-bit wide input
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

use work.Crc16D48Pkg.all;

entity Crc16Parallel is 
   generic (
      TPD_G            : time             := 1 ns;
      BYTE_WIDTH_G     : positive         := 6;
      INPUT_REGISTER_G : boolean          := true;
      CRC_INIT_G       : slv(15 downto 0) := x"FFFF");
   port (
      crcOut       : out slv(15 downto 0);  -- CRC output
      crcRem       : out slv(15 downto 0);  -- CRC interim remainder
      crcClk       : in  sl;            -- system clock
      crcDataValid : in  sl;  -- indicate that new data arrived and CRC can be computed
      crcDataWidth : in  slv(2 downto 0);  -- indicate width in bytes minus 1, 0 - 1 byte, 1 - 2 bytes ... , 7 - 8 bytes
      crcIn        : in  slv((BYTE_WIDTH_G*8-1) downto 0);  -- input data for CRC calculation
      crcInit      : in  slv(15 downto 0) := CRC_INIT_G;  -- optional override of CRC_INIT_G
      crcReset     : in  sl);  -- initializes CRC logic to crcInit     
end Crc16Parallel;

architecture rtl of Crc16Parallel is

   type RegType is record
      crc       : slv(15 downto 0);
      data      : slv((BYTE_WIDTH_G*8-1) downto 0);
      valid     : sl;
      byteWidth : slv(2 downto 0);
   end record RegType;

   constant REG_INIT_C : RegType := (
      crc       => CRC_INIT_G,
      data      => (others => '0'),
      valid     => '0',
      byteWidth => (others => '0'));

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   assert (BYTE_WIDTH_G > 0 and BYTE_WIDTH_G <= 8) report "BYTE_WIDTH_G must be in the range [1,8]" severity failure;

   comb : process(crcDataValid, crcDataWidth, crcIn, crcInit, crcReset, r)
      variable v         : RegType;
      variable prevCrc   : slv(15 downto 0);
      variable byteWidth : slv(2 downto 0);
      variable valid     : sl;
      variable data      : slv((BYTE_WIDTH_G*8-1) downto 0);
   begin
      -- Latch the current value
      v := r;

      -- Latch the signals
      v.byteWidth := crcDataWidth;
      v.valid     := crcDataValid;

      -- Transpose the input data
      for byte in (BYTE_WIDTH_G-1) downto 0 loop
         if (crcDataWidth >= BYTE_WIDTH_G-byte-1) then
            for b in 0 to 7 loop
               v.data((byte+1)*8-1-b) := crcIn(byte*8+b);
            end loop;
         else
            v.data((byte+1)*8-1 downto byte*8) := (others => '0');
         end if;
      end loop;

      -- Select where to register the inputs
      if (INPUT_REGISTER_G) then
         byteWidth := r.byteWidth;
         valid     := r.valid;
         data      := r.data;
      else
         byteWidth := v.byteWidth;
         valid     := v.valid;
         data      := v.data;
      end if;

      -- Reset handling
      if (crcReset = '0') then
         -- Use remainder from previous cycle
         prevCrc := r.crc;
      else
         -- Pre-load the remainder
         prevCrc := crcInit;
      end if;

      -- Calculate CRC in parallel - implementation used depends on the 
      -- byte width in use.      
      if (valid = '1') then
         case(byteWidth) is
           
            when "101" =>
               if (BYTE_WIDTH_G >= 6) then
                  v.crc := crc16Parallel6Byte(prevCrc, data(BYTE_WIDTH_G*8-1 downto (BYTE_WIDTH_G-6)*8));
               end if;

            when others => v.crc := (others => '0');
         end case;
      else
         -- No change
         v.crc := prevCrc;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

      -- Outputs
      crcRem <= r.crc;

      -- Transpose each byte in the data out and invert
      -- This inversion is equivalent to an XOR of the CRC register with xFFFFFFFF 
      for byte in 0 to 1 loop
         for b in 0 to 7 loop
            crcOut(byte*8+b) <= not(r.crc((byte+1)*8-1-b));
         end loop;
      end loop;

   end process;

   seq : process (crcClk) is
   begin
      if (rising_edge(crcClk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end rtl;
