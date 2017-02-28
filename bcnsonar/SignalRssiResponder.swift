//
//  SignalRssiResponder.swift
//  bcnsonar
//
//  Created by Cole Richards on 5/5/16.
//  Copyright © 2016 Cole Richards. All rights reserved.
//

import Foundation


protocol SignalRssiResonderDelegate{
    func didRecieveSignalUpdateWithIdentifer(_ identifier: String, andRSSI rssi:Int)
    func updateRangedSignals(_ signalsByRssi: [UUID:NSNumber])
}
