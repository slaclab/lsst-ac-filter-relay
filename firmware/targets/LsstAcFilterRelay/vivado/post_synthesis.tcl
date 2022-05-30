##############################################################################
## This file is part of 'Simple-10GbE-RUDP-KCU105-Example'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'Simple-10GbE-RUDP-KCU105-Example', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

##############################
# Get variables and procedures
##############################
source -quiet $::env(RUCKUS_DIR)/vivado_env_var.tcl
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

######################################################
# Bypass the debug chipscope generation via return cmd
# ELSE ... comment out the return to include chipscope
######################################################
return

############################
## Open the synthesis design
############################
open_run synth_1

###############################
## Set the name of the ILA core
###############################
set ilaName u_ila_0

##################
## Create the core
##################
CreateDebugCore ${ilaName}

#######################
## Set the record depth
#######################
set_property C_DATA_DEPTH 8192 [get_debug_cores ${ilaName}]
# set_property C_DATA_DEPTH 1024 [get_debug_cores ${ilaName}]

#################################
## Set the clock for the ILA core
#################################
SetDebugCoreClk ${ilaName} {U_ModbusRTU/clk}

#######################
## Set the debug Probes
#######################

ConfigProbe ${ilaName} {U_ModbusRTU/r[charTime][*]}
ConfigProbe ${ilaName} {U_ModbusRTU/r[count][*]}
# ConfigProbe ${ilaName} {U_ModbusRTU/r[data][*]}
ConfigProbe ${ilaName} {U_ModbusRTU/r[errorCode][*]}
ConfigProbe ${ilaName} {U_ModbusRTU/r[fifoDin][*]}
# ConfigProbe ${ilaName} {U_ModbusRTU/r[holdReg][*]}
ConfigProbe ${ilaName} {U_ModbusRTU/r[mbState][*]}
ConfigProbe ${ilaName} {U_ModbusRTU/r[mycounter][*]}
# ConfigProbe ${ilaName} {U_ModbusRTU/r[responseData][*]}
ConfigProbe ${ilaName} {U_ModbusRTU/uartRxData[*]}
ConfigProbe ${ilaName} {U_ModbusRTU/uartTxData[*]}

ConfigProbe ${ilaName} {U_ModbusRTU/r[crcReset]}
ConfigProbe ${ilaName} {U_ModbusRTU/r[crcValid]}
ConfigProbe ${ilaName} {U_ModbusRTU/r[fifoTxValid]}
ConfigProbe ${ilaName} {U_ModbusRTU/r[recFlag]}
ConfigProbe ${ilaName} {U_ModbusRTU/r[respValid]}
ConfigProbe ${ilaName} {U_ModbusRTU/r[wrReady]}
# ConfigProbe ${ilaName} {U_ModbusRTU/rst}

ConfigProbe ${ilaName} {U_ModbusRTU/r[txEnable]}
ConfigProbe ${ilaName} {U_ModbusRTU/rx}
ConfigProbe ${ilaName} {U_ModbusRTU/tx}

ConfigProbe ${ilaName} {U_ModbusRTU/uartTxValid}
ConfigProbe ${ilaName} {U_ModbusRTU/uartTxReady}
ConfigProbe ${ilaName} {U_ModbusRTU/uartTxRdEn}
ConfigProbe ${ilaName} {U_ModbusRTU/fifoTxValid}
ConfigProbe ${ilaName} {U_ModbusRTU/fifoTxReady}
ConfigProbe ${ilaName} {U_ModbusRTU/fifoTxEmpty}
ConfigProbe ${ilaName} {U_ModbusRTU/uartRxValid}
ConfigProbe ${ilaName} {U_ModbusRTU/uartRxValidInt}
ConfigProbe ${ilaName} {U_ModbusRTU/uartRxReady}
ConfigProbe ${ilaName} {U_ModbusRTU/fifoRxValid}
ConfigProbe ${ilaName} {U_ModbusRTU/fifoRxReady}
ConfigProbe ${ilaName} {U_ModbusRTU/fifoRxRdEn}
ConfigProbe ${ilaName} {U_ModbusRTU/baud16x}
ConfigProbe ${ilaName} {U_ModbusRTU/crcOut[*]}
ConfigProbe ${ilaName} {U_ModbusRTU/crcRem[*]}


##########################
## Write the port map file
##########################
WriteDebugProbes ${ilaName}
