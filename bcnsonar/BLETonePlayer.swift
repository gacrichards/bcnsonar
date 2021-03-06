//
//  BLETonePlayer.swift
//  bcnsonar
//
//  Created by Cole Richards on 5/13/16.
//  Copyright © 2016 Cole Richards. All rights reserved.
//

import Foundation
import AVFoundation

infix operator ^^
func ^^ (radix: Float, power: Float) -> Float {
    return Float(pow(Double(radix), Double(power)))
}

class BLETonePlayer: NSObject, SignalRssiResonderDelegate {

    
    private let maxVolume: Float = 1.0
    private let minVolume: Float = 0.01
    private let rssiMaxValue = -30.0 //maps to maxVol
    private let rssiMinValue = -90.0 //maps to minVol
    var playerTimers = [String: Timer]()
    private var hostView: SignalSelectorDisplay
    private var scanner: BLEScanner!
    private var toneURLs = [URL]()
    
    
    var audioPlayersById: [String: AVAudioPlayer] = [String: AVAudioPlayer]();
    
    init(hostView: SignalSelectorDisplay) {
        self.hostView = hostView
        super.init()
        scanner = BLEScanner.init(delegate:self)
        loadTones()
        //createBassoonPlayer()
        //createBassPlayer()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func loadTones(){
        let toneNames = ["500Hz","550Hz","600Hz","650Hz","700Hz","750Hz","800Hz","850Hz","900Hz","950Hz","1000Hz"]
        for name in toneNames{
            if let soundFilePath = loadWavWithString(name){
                let fileURL = URL.init(fileURLWithPath:(soundFilePath))
                toneURLs.append(fileURL)
            }
        }
    }
    
    func loadWavWithString(_ name:String) ->String?{
        return Bundle.main.path(forResource: name, ofType: "wav")
    }
    
    func getToneAtIndex(_ index:Int) -> URL?{
        if (index < toneURLs.count){
            return toneURLs[index];
        }
        
        return nil;
    }
    
    func createAudioPlayerWithIdentifier(_ identifier: String, andAudioFileURL fileURL:URL){
        do{
            let newPlayer = try AVAudioPlayer.init(contentsOf: fileURL)
            addAudioPlayer(newPlayer, withIdentifier: identifier)
        }catch{
            print("cannot create audioPlayer")
        }
    }
    
    func removeToneForIdentifier(_ identifier: String){
        audioPlayersById.removeValue(forKey: identifier);
        scanner.resetBandMembers([String](audioPlayersById.keys))
    }
    
    
    func addAudioPlayer(_ player:AVAudioPlayer, withIdentifier identifier:String){
        audioPlayersById[identifier] = player;
        scanner.resetBandMembers([String](audioPlayersById.keys))
    }
    
    func updateRangedSignals(_ signalsByRssi:[UUID:NSNumber]){
        
        var signals = [BLESignal]()
        
        for key in signalsByRssi.keys{
            signals.append(BLESignal.init(identifier: key.uuidString, signalStrength: signalsByRssi[key]!))
        }
        signals.sort {$0.identifer.compare($1.identifer) == .orderedAscending}
        
        DispatchQueue.main.async(execute: {
            self.hostView.didReceivedNewSignalsToDisplay(signals);
        });
    }
    
    func didRecieveSignalUpdateWithIdentifer(_ identifier: String, andRSSI rssi:Int){
        
        if let playerTimer = playerTimers[identifier]{
            playerTimer.invalidate()
        }
        let newPlayerTimer = Timer.init(timeInterval: 1.0, target: self, selector: #selector(cancelPlayer), userInfo: identifier, repeats:false)
        RunLoop.main.add(newPlayerTimer, forMode: RunLoopMode.defaultRunLoopMode)
        playerTimers[identifier] = newPlayerTimer
        
        if(rssi < 0){
            var volume = nonLinearMapToVolume(rssi);
            if (volume > maxVolume){
                volume = maxVolume
            }else if(volume < minVolume){
                volume = minVolume
            }
            playAudioPlayerWithIdentifier(identifier, atVolume: volume)
        }else{
            playAudioPlayerWithIdentifier(identifier, atVolume: 0)
        }
        
    }
    
    private func nonLinearMapToVolume(_ rssi: Int) -> Float{
        let r = Float(rssi)
        let part1 = -0.0000333333*(r^^3)
        let part2 = 0.00633333*(r^^2)
        let part3 = 0.364167*r
        let volume = part1-part2-part3-5.56667
        print(volume)
        return volume
    }
    
    private func mapRSSIToVolume(_ rssi: Int) ->Float{
        /*
         (b-a)(x - min)
         f(x) = --------------  + a
         max - min
         */
        let rssiRange = Float(rssiMaxValue - rssiMinValue)
        let volumeRange = Float(maxVolume - minVolume)
        let rssiDeltaMin = Float(rssi) - Float(rssiMinValue)
        return (volumeRange * rssiDeltaMin)/rssiRange + Float(minVolume)
    }
    
    private func playAudioPlayerWithIdentifier(_ identifier:String, atVolume vol:Float){
        if let currentPlayer = self.audioPlayersById[identifier]{
            currentPlayer.volume = vol
            if(!currentPlayer.isPlaying){
                currentPlayer.play()
            }
        }
        
    }
    
    func cancelPlayer(_ timer: Timer){
        print("stopping playback")
        if let identifier = timer.userInfo as? String{
            if let currentPlayer = self.audioPlayersById[identifier]{
                if(currentPlayer.isPlaying){
                    currentPlayer.stop()
                }
                
            }
        }
    }
    
//    private func createBassPlayer(){
//        if let soundFilePath = NSBundle.mainBundle().pathForResource("500Hz", ofType: "wav"){
//            let fileURL = NSURL.init(fileURLWithPath:(soundFilePath))
//            createAudioPlayerWithIdentifier(scanner.bassID.UUIDString, andAudioFileURL:fileURL)
//        }
//    }
//    
//    private func createBassoonPlayer(){
//        if let soundFilePath = NSBundle.mainBundle().pathForResource("800Hz", ofType: "wav"){
//            let fileURL = NSURL.init(fileURLWithPath:(soundFilePath))
//            createAudioPlayerWithIdentifier(scanner.bassonID.UUIDString, andAudioFileURL:fileURL)
//        }
//    }
    
    
    

    
    
}
