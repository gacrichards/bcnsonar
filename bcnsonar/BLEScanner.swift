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
    
    var rssiBySignalId = [NSUUID:NSNumber]()
    var lastUpdateSent = NSDate.distantPast()
    static let updateTimeInterval: Double = 1
    
    init(delegate: SignalRssiResonderDelegate){
        rssiDelegate = delegate
        super.init()
        setupCentralManager()
    }
    
    func setupCentralManager(){
        let centralQueue = dispatch_queue_create("com.chaco.BLEScanner", nil);
        self.centralManager = CBCentralManager.init(delegate:self, queue:centralQueue)
    }
    
    
    func centralManagerDidUpdateState(central: CBCentralManager){
        if (central.state == CBCentralManagerState.PoweredOn){
            print("bluetooth on and in useable state")
            startScanningWithService(nil);
        }
    }
    
    func startScanningWithService(services:[CBUUID]?){
        let options = [CBCentralManagerScanOptionAllowDuplicatesKey: true]
        if (services != nil){
            self.centralManager.scanForPeripheralsWithServices(services, options:options)
        }else{
            self.centralManager.scanForPeripheralsWithServices(nil, options: options)
        }
        
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        rssiBySignalId[peripheral.identifier] = RSSI
        sendRSSIBySignalUpdate()
        
        let peripheralID = peripheral.identifier.UUIDString
        if(bandIds.map({$0.UUIDString}).contains(peripheralID)){
            rssiDelegate.didRecieveSignalUpdateWithIdentifer(peripheralID, andRSSI: Int(RSSI))
        }
    }
    
    func resetBandMembers(identifiers:[String]){
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
            self.lastUpdateSent = NSDate.init()
        }
    }
    
}