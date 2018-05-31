
library ieee;
use ieee.std_logic_1164.all;
use work.StdRtlPkg.all;


package Crc16D48Pkg is
   -- polynomial: x^16 + x^15 + x^2 + 1 
   -- data width: 48
   -- convention: the first serial bit is D[47]
   function crc16Parallel6Byte
      (crc  : slv(15 downto 0);
       Data : slv(47 downto 0))
      return slv;
end Crc16D48Pkg;


package body Crc16D48Pkg is

   -- polynomial: x^16 + x^15 + x^2 + 1
   -- data width: 48
   -- convention: the first serial bit is D[47]
   function crc16Parallel6Byte
      (crc  : slv(15 downto 0);
       Data : slv(47 downto 0))
      return slv is

      variable d      : slv(47 downto 0);
      variable c      : slv(15 downto 0);
      variable newcrc : slv(15 downto 0);

   begin
      d := Data;
      c := crc;

      newcrc(0)  := '1' xor d(47) xor d(46) xor d(45) xor d(43) xor d(41) xor d(40) xor d(39) xor d(38) xor d(37) xor d(36) xor d(35) xor d(34) xor d(33) xor d(32) xor d(31) xor d(30) xor d(27) xor d(26) xor d(25) xor d(24) xor d(23) xor d(22) xor d(21) xor d(20) xor d(19) xor d(18) xor d(17) xor d(16) xor d(15) xor d(13) xor d(12) xor d(11) xor d(10) xor d(9) xor d(8) xor d(7) xor d(6) xor d(5) xor d(4) xor d(3) xor d(2) xor d(1) xor d(0) xor c(0) xor c(1) xor c(2) xor c(3) xor c(4) xor c(5) xor c(6) xor c(7) xor c(8) xor c(9) xor c(11) xor c(13) xor c(14) xor c(15);
      newcrc(1)  := '1' xor d(47) xor d(46) xor d(44) xor d(42) xor d(41) xor d(40) xor d(39) xor d(38) xor d(37) xor d(36) xor d(35) xor d(34) xor d(33) xor d(32) xor d(31) xor d(28) xor d(27) xor d(26) xor d(25) xor d(24) xor d(23) xor d(22) xor d(21) xor d(20) xor d(19) xor d(18) xor d(17) xor d(16) xor d(14) xor d(13) xor d(12) xor d(11) xor d(10) xor d(9) xor d(8) xor d(7) xor d(6) xor d(5) xor d(4) xor d(3) xor d(2) xor d(1) xor c(0) xor c(1) xor c(2) xor c(3) xor c(4) xor c(5) xor c(6) xor c(7) xor c(8) xor c(9) xor c(10) xor c(12) xor c(14) xor c(15);
      newcrc(2)  := '1' xor d(46) xor d(42) xor d(31) xor d(30) xor d(29) xor d(28) xor d(16) xor d(14) xor d(1) xor d(0) xor c(10) xor c(14);
      newcrc(3)  := '1' xor d(47) xor d(43) xor d(32) xor d(31) xor d(30) xor d(29) xor d(17) xor d(15) xor d(2) xor d(1) xor c(0) xor c(11) xor c(15);
      newcrc(4)  := '1' xor d(44) xor d(33) xor d(32) xor d(31) xor d(30) xor d(18) xor d(16) xor d(3) xor d(2) xor c(0) xor c(1) xor c(12);
      newcrc(5)  := '1' xor d(45) xor d(34) xor d(33) xor d(32) xor d(31) xor d(19) xor d(17) xor d(4) xor d(3) xor c(0) xor c(1) xor c(2) xor c(13);
      newcrc(6)  := '1' xor d(46) xor d(35) xor d(34) xor d(33) xor d(32) xor d(20) xor d(18) xor d(5) xor d(4) xor c(0) xor c(1) xor c(2) xor c(3) xor c(14);
      newcrc(7)  := '1' xor d(47) xor d(36) xor d(35) xor d(34) xor d(33) xor d(21) xor d(19) xor d(6) xor d(5) xor c(1) xor c(2) xor c(3) xor c(4) xor c(15);
      newcrc(8)  := '1' xor d(37) xor d(36) xor d(35) xor d(34) xor d(22) xor d(20) xor d(7) xor d(6) xor c(2) xor c(3) xor c(4) xor c(5);
      newcrc(9)  := '1' xor d(38) xor d(37) xor d(36) xor d(35) xor d(23) xor d(21) xor d(8) xor d(7) xor c(3) xor c(4) xor c(5) xor c(6);
      newcrc(10) := '1' xor d(39) xor d(38) xor d(37) xor d(36) xor d(24) xor d(22) xor d(9) xor d(8) xor c(4) xor c(5) xor c(6) xor c(7);
      newcrc(11) := '1' xor d(40) xor d(39) xor d(38) xor d(37) xor d(25) xor d(23) xor d(10) xor d(9) xor c(5) xor c(6) xor c(7) xor c(8);
      newcrc(12) := '1' xor d(41) xor d(40) xor d(39) xor d(38) xor d(26) xor d(24) xor d(11) xor d(10) xor c(6) xor c(7) xor c(8) xor c(9);
      newcrc(13) := '1' xor d(42) xor d(41) xor d(40) xor d(39) xor d(27) xor d(25) xor d(12) xor d(11) xor c(7) xor c(8) xor c(9) xor c(10);
      newcrc(14) := '1' xor d(43) xor d(42) xor d(41) xor d(40) xor d(28) xor d(26) xor d(13) xor d(12) xor c(8) xor c(9) xor c(10) xor c(11);
      newcrc(15) := '1' xor d(47) xor d(46) xor d(45) xor d(44) xor d(42) xor d(40) xor d(39) xor d(38) xor d(37) xor d(36) xor d(35) xor d(34) xor d(33) xor d(32) xor d(31) xor d(30) xor d(29) xor d(26) xor d(25) xor d(24) xor d(23) xor d(22) xor d(21) xor d(20) xor d(19) xor d(18) xor d(17) xor d(16) xor d(15) xor d(14) xor d(12) xor d(11) xor d(10) xor d(9) xor d(8) xor d(7) xor d(6) xor d(5) xor d(4) xor d(3) xor d(2) xor d(1) xor d(0) xor c(0) xor c(1) xor c(2) xor c(3) xor c(4) xor c(5) xor c(6) xor c(7) xor c(8) xor c(10) xor c(12) xor c(13) xor c(14) xor c(15);
      return newcrc;
   end crc16Parallel6Byte;

end Crc16D48Pkg;
