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
        
        coreStride = 0x00000 
        appStride  = 0x1000 
        
        # Add Core device
        self.add(base.Core())            
        
        # Add User devices
        self.add(CtrlReg(
            name    = 'Registers',
            offset  = (1*coreStride)+ (appStride * 0),
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
		