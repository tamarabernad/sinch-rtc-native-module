//
//  PhoneAudioController.swift
//  BlueCall
//
//  Created by Tamara Bernad on 2017-10-30.
//  Copyright © 2017 Blue Call. All rights reserved.
//

import Foundation
class PhoneAudioController:NSObject{
    var callVibrationTimer:Timer?
    var callAudioPlayer:AVAudioPlayer?;
    var vibrationCount:Int = 0;
    func startCallVibration(repeatCount:Int = -1){
        
        if let _timer = callVibrationTimer{
            _timer.invalidate();
        }
        vibrationCount = 0;
        vibrate()
        callVibrationTimer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(onTimerTrigger(_ :)), userInfo: ["maxVibrations":repeatCount], repeats: true);
    }
    func stopCallVibration(){
        if let _timer = callVibrationTimer{
            _timer.invalidate();
        }
    }
    func playIncomingCall(){
        playCall(file: "incoming.wav")
        startCallVibration()
    }
    func playOutgoingCall(){
        playCall(file: "ringback.wav")
    }
    func playCall(file:String){
        if let _player = self.callAudioPlayer{
            _player.stop();
        }
        guard let _path = Bundle.main.resourcePath else{return}
        guard let player = try? AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: _path+"/"+file) as URL) else{return}
        
        self.callAudioPlayer = player;
        
        player.prepareToPlay()
        player.numberOfLoops = -1
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategorySoloAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
        }catch{
            print("error!!!");
        }
        player.play()
    }
    func stopCallSound(){
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            try AVAudioSession.sharedInstance().setActive(true)
        }catch{
            
        }
        callAudioPlayer?.stop()
        stopCallVibration()
    }
    @objc func onTimerTrigger(_ timer:Timer){
        if let _userInfo = timer.userInfo as? [AnyHashable:Any], let _maxVibrations = _userInfo["maxVibrations"] as? Int, _maxVibrations != -1{
            vibrationCount += 1;
            if(vibrationCount >= _maxVibrations){
                self.callVibrationTimer?.invalidate();
            }
        }
        vibrate()
    }
    func vibrate(){
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
}
