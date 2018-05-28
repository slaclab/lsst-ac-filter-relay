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

set_property -dict {PACKAGE_PIN W11 IOSTANDARD LVCMOS33 DRIVE 12} [get_ports {relOK[11]}]
set_property -dict {PACKAGE_PIN W12 IOSTANDARD LVCMOS33 DRIVE 12} [get_ports {relOK[10]}]
set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS33 DRIVE 12} [get_ports {relOK[9]}]
set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS33 DRIVE 12} [get_ports {relOK[8]}]
set_property -dict {PACKAGE_PIN U15 IOSTANDARD LVCMOS33 DRIVE 12} [get_ports {relOK[7]}]
set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS33 DRIVE 12} [get_ports {relOK[6]}]
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS33 DRIVE 12} [get_ports {relOK[5]}]
set_property -dict {PACKAGE_PIN T15 IOSTANDARD LVCMOS33 DRIVE 12} [get_ports {relOK[4]}]
set_property -dict {PACKAGE_PIN W15 IOSTANDARD LVCMOS33 DRIVE 12} [get_ports {relOK[3]}]
set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVCMOS33 DRIVE 12} [get_ports {relOK[2]}]
set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS33 DRIVE 12} [get_ports {relOK[1]}]
set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS33 DRIVE 12} [get_ports {relOK[0]}]

set_property -dict {PACKAGE_PIN AB17 IOSTANDARD LVCMOS33} [get_ports driverData]
set_property -dict {PACKAGE_PIN Y16 IOSTANDARD LVCMOS33} [get_ports recData]
set_property -dict {PACKAGE_PIN AA16 IOSTANDARD LVCMOS33} [get_ports recEn]
set_property -dict {PACKAGE_PIN AB16 IOSTANDARD LVCMOS33} [get_ports driverEn]

set_property -dict {PACKAGE_PIN F6} [get_ports ethClkP]
set_property -dict {PACKAGE_PIN E6} [get_ports ethClkN]
set_property -dict {PACKAGE_PIN B4} [get_ports ethTxP]
set_property -dict {PACKAGE_PIN A4} [get_ports ethTxN]
set_property -dict {PACKAGE_PIN B8} [get_ports ethRxP]
set_property -dict {PACKAGE_PIN A8} [get_ports ethRxN]



