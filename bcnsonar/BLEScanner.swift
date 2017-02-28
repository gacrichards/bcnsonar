//
//  BLEScanner.swift
//  bcnsonar
//
//  Created by Cole Richards on 5/5/16.
//  Copyright © 2016 Cole Richards. All rights reserved.
//

import CoreBluetooth

class BLEScanner: NSObject, CBCentralManagerDelegate {
    
    
    var centralManager : CBCentralManager!
    var rssiDelegate: SignalRssiResonderDelegate
    
    var bandIds = [CBUUID]()
    
    var rssiBySignalId = [UUID:NSNumber]()
    var lastUpdateSent = Date.distantPast
    static let updateTimeInterval: Double = 1
    
    init(delegate: SignalRssiResonderDelegate){
        rssiDelegate = delegate
        super.init()
        setupCentralManager()
    }
    
    func setupCentralManager(){
        let centralQueue = DispatchQueue(label: "com.chaco.BLEScanner", attributes: []);
        self.centralManager = CBCentralManager.init(delegate:self, queue:centralQueue)
    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager){
        if (central.state == .poweredOn){
            print("bluetooth on and in useable state")
            startScanningWithService(nil);
        }
    }
    
    func startScanningWithService(_ services:[CBUUID]?){
        let options = [CBCentralManagerScanOptionAllowDuplicatesKey: true]
        if (services != nil){
            self.centralManager.scanForPeripherals(withServices: services, options:options)
        }else{
            self.centralManager.scanForPeripherals(withServices: nil, options: options)
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        rssiBySignalId[peripheral.identifier] = RSSI
        sendRSSIBySignalUpdate()
        
        let peripheralID = peripheral.identifier.uuidString
        if(bandIds.map({$0.uuidString}).contains(peripheralID)){
            rssiDelegate.didRecieveSignalUpdateWithIdentifer(peripheralID, andRSSI: Int(RSSI))
        }
    }
    
    func resetBandMembers(_ identifiers:[String]){
        self.bandIds = [CBUUID]()
        for identifier in identifiers{
            let member = CBUUID.init(string:identifier)
            self.bandIds.append(member)
        }
    }
    
    private func sendRSSIBySignalUpdate(){
        if(self.lastUpdateSent.timeIntervalSinceNow < -BLEScanner.updateTimeInterval){
            rssiDelegate.updateRangedSignals(rssiBySignalId)
            rssiBySignalId.removeAll()
            self.lastUpdateSent = Date.init()
        }
    }
    
}
