#!/usr/bin/env python
#-----------------------------------------------------------------------------
# Title      : 
#-----------------------------------------------------------------------------
# File       : TopLevel.py
# Created    : 2017-04-03
#-----------------------------------------------------------------------------
# Description:
# 
#-----------------------------------------------------------------------------
# This file is part of the rogue_example software. It is subject to 
# the license terms in the LICENSE.txt file found in the top-level directory 
# of this distribution and at: 
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
# No part of the rogue_example software, including this file, may be 
# copied, modified, propagated, or distributed except according to the terms 
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------

import pyrogue as pr
import LsstPwrCtrlCore as base
  
class Fpga(pr.Device):
    def __init__(self, 
                 name        = "Fpga",
                 description = "Device Memory Mapping",
                 **kwargs):
        super().__init__(name=name, description=description, **kwargs)
        
        coreStride = 0x40000 
        appStride  = 0x1000 
        
        # Add Core device
        self.add(base.Core())            
        
        # Add User devices
        self.add(CtrlReg(
            name    = 'Relay Registers',
            offset  = (1*coreStride)+ (appStride * 0),
            expand  = False,
        ))
		
        self.add(Modbus(
            name    = 'Modbus Registers',
            offset  = (2*coreStride)+ (appStride * 0),
            expand  = False,
        ))


class CtrlReg(pr.Device):
    def __init__(self, 
                 name        = "CtrlReg",
                 description = "Container for CtrlReg",
                 **kwargs):
        super().__init__(name=name, description=description, **kwargs)
        
        self.add(pr.RemoteVariable(
            name    = 'Relay_1',
            offset  = 0x0,
            mode    = 'RW',
        ))
        self.add(pr.RemoteVariable(
            name    = 'Relay_2',
            offset  = 0x04,
            mode    = 'RW',
        ))
        self.add(pr.RemoteVariable(
            name    = 'Relay_3',
            offset  = 0x08,
            mode    = 'RW',
        ))
        self.add(pr.RemoteVariable(
            name    = 'Relay_4',
            offset  = 0x0C,
            mode    = 'RW',
        ))
        self.add(pr.RemoteVariable(
            name    = 'Relay_5',
            offset  = 0x10,
            mode    = 'RW',
        ))
        self.add(pr.RemoteVariable(
            name    = 'Relay_6',
            offset  = 0x14,
            mode    = 'RW',
        ))
        self.add(pr.RemoteVariable(
            name    = 'Relay_7',
            offset  = 0x18,
            mode    = 'RW',
        ))
        self.add(pr.RemoteVariable(
            name    = 'Relay_8',
            offset  = 0x1C,
            mode    = 'RW',
        ))
        self.add(pr.RemoteVariable(
            name    = 'Relay_9',
            offset  = 0x20,
            mode    = 'RW',
        ))
        self.add(pr.RemoteVariable(
            name    = 'Relay_10',
            offset  = 0x24,
            mode    = 'RW',
        ))
        self.add(pr.RemoteVariable(
            name    = 'Relay_11',
            offset  = 0x28,
            mode    = 'RW',
        ))
        self.add(pr.RemoteVariable(
            name    = 'Relay_12',
            offset  = 0x2C,
            mode    = 'RW',
        ))

class Modbus(pr.Device):
    def __init__(self, 
                 name        = "Modbus",
                 description = "Modbus Data in and out",
                 **kwargs):
        super().__init__(name=name, description=description, **kwargs)
        
        self.add(pr.RemoteVariable(
            name    = 'ModbusTxHi',
            offset  = 0x0,
            mode    = 'RW',
        ))
        self.add(pr.RemoteVariable(
            name    = 'ModbusTxLo',
            offset  = 0x4,
            mode    = 'RW',
        ))
        self.add(pr.RemoteVariable(
            name    = 'echo0',
            offset  = 0x08,
            mode    = 'RO',
        ))
        self.add(pr.RemoteVariable(
            name    = 'echo1',
            offset  = 0x0C,
            mode    = 'RO',
        ))
        self.add(pr.RemoteVariable(
            name    = 'Byte',
            offset  = 0x10,
            mode    = 'RO',
        ))
        self.add(pr.RemoteVariable(
            name    = 'MbData0',
            offset  = 0x14,
            mode    = 'RO',
        ))
        self.add(pr.RemoteVariable(
            name    = 'MbData1',
            offset  = 0x18,
            mode    = 'RO',
        ))
        self.add(pr.RemoteVariable(
            name    = 'MbData2',
            offset  = 0x1C,
            mode    = 'RO',
        ))
        self.add(pr.RemoteVariable(
            name    = 'MbData3',
            offset  = 0x20,
            mode    = 'RO',
        ))
        self.add(pr.RemoteVariable(
            name    = 'MbData4',
            offset  = 0x24,
            mode    = 'RO',
        ))
        self.add(pr.RemoteVariable(
            name    = 'count',
            offset  = 0x6C,
            mode    = 'RO',
        ))		
        self.add(pr.RemoteVariable(
            name    = 'Status',
            offset  = 0x70,
            mode    = 'RO',
        ))
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		