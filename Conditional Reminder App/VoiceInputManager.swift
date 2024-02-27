//
//  VoiceInputManager.swift
//  Conditional Reminder App
//
//  Created by Marlene on 26.02.24.
//

import Foundation
import AVFoundation

class VoiceInputManager: NSObject, AVAudioRecorderDelegate {
    static let shared = VoiceInputManager()
    
    private var audioRecorder: AVAudioRecorder?

    private override init() {
            super.init()
            // Additional setup if needed
        }
    func checkMicrophonePermission(completion: @escaping (Bool) -> Void) {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            // Permission already granted
            completion(true)
        case .denied:
            // Permission denied
            completion(false)
        case .undetermined:
            // Request permission
                    AVAudioSession.sharedInstance().requestRecordPermission { granted in
                        DispatchQueue.main.async {
                            completion(granted)
                        }
                    }
        @unknown default:
            // Handle future cases
            completion(false)
        }
    }

    func startListening() {
            let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            do {
                audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                audioRecorder?.delegate = self
                audioRecorder?.record()
            } catch {
                // Handle the error
            }
        }
        
        func stopListening() {
            audioRecorder?.stop()
            audioRecorder = nil
        }
        
        private func getDocumentsDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return paths[0]
        }
    }
