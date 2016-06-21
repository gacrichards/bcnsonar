//
//  SignalRssiResponder.swift
//  bcnsonar
//
//  Created by Cole Richards on 5/5/16.
//  Copyright © 2016 Cole Richards. All rights reserved.
//

import Foundation


protocol SignalRssiResonderDelegate{
    func didRecieveSignalUpdateWithIdentifer(identifier: String, andRSSI rssi:Int)
    func updateRangedSignals(signalsByRssi: [NSUUID:NSNumber])
}