##############################################################################
## This file is part of 'LSST Firmware'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'LSST Firmware', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

#######################
## Application Ports ##
#######################


#set_property -dict { PACKAGE_PIN L12    IOSTANDARD LVCMOS33 } [get_ports { BOOT_SCK}]
#set_property -dict { PACKAGE_PIN P22    IOSTANDARD LVCMOS33 } [get_ports { BOOT_D[O]}]
#set_property -dict { PACKAGE_PIN R22    IOSTANDARD LVCMOS33 } [get_ports { BOOT_D[1]}]
#set_property -dict { PACKAGE_PIN P21    IOSTANDARD LVCMOS33 } [get_ports { BOOT_D[2]}]
#set_property -dict { PACKAGE_PIN R21    IOSTANDARD LVCMOS33 } [get_ports { BOOT_D[3]}]

set_property -dict {PACKAGE_PIN P22 IOSTANDARD LVCMOS33} [get_ports bootMosi]
set_property -dict {PACKAGE_PIN R22 IOSTANDARD LVCMOS33} [get_ports bootMiso]
set_property -dict {PACKAGE_PIN T19 IOSTANDARD LVCMOS33} [get_ports bootCsL]

#set_property -dict { PACKAGE_PIN F10    IOSTANDARD LVCMOS33 } [get_ports { ethClkP}]
#set_property -dict { PACKAGE_PIN E10    IOSTANDARD LVCMOS33 } [get_ports { ethClkN}]

#set_property -dict { PACKAGE_PIN B4     IOSTANDARD LVCMOS33 } [get_ports { ethTxP}]
#set_property -dict { PACKAGE_PIN A4     IOSTANDARD LVCMOS33 } [get_ports { ethTxN}]
#set_property -dict { PACKAGE_PIN B8     IOSTANDARD LVCMOS33 } [get_ports { ethRxP}]
#set_property -dict { PACKAGE_PIN A8     IOSTANDARD LVCMOS33 } [get_ports { ethRxN}]




set_property IOSTANDARD LVCMOS33 [get_ports {relOK[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {relOK[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {relOK[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {relOK[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {relOK[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {relOK[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {relOK[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {relOK[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {relOK[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {relOK[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {relOK[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {relOK[11]}]
set_property PACKAGE_PIN W11 [get_ports {relOK[11]}]
set_property PACKAGE_PIN W12 [get_ports {relOK[10]}]
set_property PACKAGE_PIN V13 [get_ports {relOK[9]}]
set_property PACKAGE_PIN V14 [get_ports {relOK[8]}]
set_property PACKAGE_PIN U15 [get_ports {relOK[7]}]
set_property PACKAGE_PIN V15 [get_ports {relOK[6]}]
set_property PACKAGE_PIN T14 [get_ports {relOK[5]}]
set_property PACKAGE_PIN T15 [get_ports {relOK[4]}]
set_property PACKAGE_PIN W15 [get_ports {relOK[3]}]
set_property PACKAGE_PIN W16 [get_ports {relOK[2]}]
set_property PACKAGE_PIN T16 [get_ports {relOK[1]}]
set_property PACKAGE_PIN U16 [get_ports {relOK[0]}]
set_property DRIVE 12 [get_ports {relOK[10]}]
set_property DRIVE 12 [get_ports {relOK[9]}]
set_property DRIVE 12 [get_ports {relOK[8]}]
set_property DRIVE 12 [get_ports {relOK[7]}]
set_property DRIVE 12 [get_ports {relOK[6]}]
set_property DRIVE 12 [get_ports {relOK[5]}]
set_property DRIVE 12 [get_ports {relOK[4]}]
set_property DRIVE 12 [get_ports {relOK[3]}]
set_property DRIVE 12 [get_ports {relOK[2]}]
set_property DRIVE 12 [get_ports {relOK[1]}]
set_property DRIVE 12 [get_ports {relOK[0]}]
set_property DRIVE 12 [get_ports {relOK[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports driver_Data]
set_property PACKAGE_PIN Y16 [get_ports rec_Data]
set_property PACKAGE_PIN AB17 [get_ports driver_Data]
set_property PACKAGE_PIN AB16 [get_ports driver_En]
set_property PACKAGE_PIN AA16 [get_ports rec_En]
set_property IOSTANDARD LVCMOS33 [get_ports driver_En]
set_property IOSTANDARD LVCMOS33 [get_ports rec_En]
set_property IOSTANDARD LVCMOS33 [get_ports rec_Data]


###########################################################################################

set_property -dict { PACKAGE_PIN F6} [get_ports { ethClkP}]
set_property -dict { PACKAGE_PIN E6} [get_ports { ethClkN}]
set_property -dict { PACKAGE_PIN B4 } [get_ports { ethTxP}]
set_property -dict { PACKAGE_PIN A4 } [get_ports { ethTxN}]
set_property -dict { PACKAGE_PIN B8 } [get_ports { ethRxP}]
set_property -dict { PACKAGE_PIN A8 } [get_ports { ethRxN}]

###########################################################################################

