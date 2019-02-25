//
//  AudioManager.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import AVFoundation

class AudioManager: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var player : AVAudioPlayer?
    var playingContent = -1
    
    static let sharedInstance: AudioManager = {
        let instance = AudioManager()
        return instance
    }()
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func checkPermision(onSuccess: @escaping (Bool) -> ()) {
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        onSuccess(true)
                      
                        
                    } else {
                        onSuccess(false)
                    }
                }
            }
        } catch {
            onSuccess(false)
        }
    }
    
    func getData() -> Data?{
        let audioFilename = self.getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        do {
          let data = try Data(contentsOf: audioFilename)
         return data

        } catch {
            return nil
        }
        
    }
    
    func startRecording(){
        let audioFilename = self.getDocumentsDirectory().appendingPathComponent("recording.m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            self.audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            self.audioRecorder.delegate = self
            self.audioRecorder.record()
            
            // recordButton.setTitle("Tap to Stop", for: .normal)
        } catch {
            self.finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        if audioRecorder != nil{
            audioRecorder.stop()
            audioRecorder = nil
        }
      
        
        if success {
          //  recordButton.setTitle("Tap to Re-record", for: .normal)
        } else {
        //    recordButton.setTitle("Tap to Record", for: .normal)
            // recording failed :(
        }
    }
    
    func playRecording(){
        
    }
    
    func saveRecording(contentId: Int){
        if let data = self.getData(){
            do {
                let audioFilenameNew = self.getDocumentsDirectory().appendingPathComponent("audio\(contentId).m4a")
                try data.write(to: audioFilenameNew)
            } catch {
            }
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func audioStop(){
        NotificationCenter.default.post(name: Notification.Name("AudioStop"), object: nil)
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        NotificationCenter.default.post(name: Notification.Name("AudioStop"), object: nil)
    }
}
