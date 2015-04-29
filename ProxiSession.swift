//
//  ProxiSessions.swift
//  Proxi
//
//  Created by Siyuan Gao on 4/28/15.
//  Copyright (c) 2015 Siyuan Gao. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class ProxiSession: NSObject {
    
    var state: MCSessionState!
    var session: MCSession!
    
    init(s: MCSession){
        super.init()
        state = MCSessionState.NotConnected
        session = s
    }
}