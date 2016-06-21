//
//  BLESignal.swift
//  bcnsonar
//
//  Created by Cole Richards on 5/13/16.
//  Copyright © 2016 Cole Richards. All rights reserved.
//

import Foundation

class BLESignal: NSObject {
    
    var identifer: String
    var signalStrength: NSNumber
    var taps = 0
    
    init(identifier: String, signalStrength: NSNumber){
        self.identifer = identifier
        self.signalStrength = signalStrength
        
    }
}
