//
//  VoiceInputManager.swift
//  Conditional Reminder App
//
//  Created by Marlene on 26.02.24.
//

import Foundation
import AVFoundation

class VoiceInputManager: NSObject, ObservableObject, AVAudioRecorderDelegate {
    static let shared = VoiceInputManager()

    @Published var isRecording = false

    private var audioRecorder: AVAudioRecorder?
    private let apiManager = APIManager.shared // Use the shared API manager
    private let gptApiManager: GPTapiManager // Chat GPT API

        init(gptApiManager: GPTapiManager) {
            self.gptApiManager = gptApiManager
        }

    convenience override init() {
          // Initialize with a default or shared GPTapiManager instance
            self.init(gptApiManager: GPTapiManager.shared)
        }
    
    func checkMicrophonePermission(completion: @escaping (Bool) -> Void) {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            print("Microphone permission granted")
            completion(true)
        case .denied:
            print("Microphone permission denied")
            completion(false)
        case .undetermined:
            print("Microphone permission undetermined, requesting access")
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    print("Microphone permission granted: \(granted)")
                    completion(granted)
                }
            }
        @unknown default:
            print("Unknown microphone permission status")
            completion(false)
        }
    }

    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord)
            try session.setActive(true)

            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            if let recorder = audioRecorder {
                print("Recorder created with ID:", ObjectIdentifier(recorder))
            } else {
                print("Failed to create the recorder")
            }
            audioRecorder?.delegate = self
            audioRecorder?.record()
            isRecording = true
            print("Recording started")
            print("Audio file path: \(audioFilename)")
        } catch {
            print("Failed to start recording: \(error.localizedDescription)")
        }
    }

        func stopRecording() {
            print("Entering stopRecording")
            guard let audioRecorder = audioRecorder else { return }
            print("Stopping recorder with ID:", ObjectIdentifier(audioRecorder))
            print("Recording duration: \(audioRecorder.currentTime)") // Check duration
            audioRecorder.stop()
            print("After stop(), isRecording:", audioRecorder.isRecording)
            isRecording = false
            print("Recording stopped")
            
            // Debugging:
            print("Recording completed? \(audioRecorder.isRecording)")
            print("File URL: \(audioRecorder.url)")
            print("File exists before transcription:", FileManager.default.fileExists(atPath: audioRecorder.url.path))
            print("Exiting stopRecording")
        }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("Entering audioRecorderDidFinishRecording")
        isRecording = false
        print("Recording finished: \(flag)")

        if flag {
            transcribeAudioAndProcess()
        } else {
            print("Recording failed")
            // Handle the failed recording scenario
        }
        print("Exiting audioRecorderDidFinishRecording")
    }
    
        func toggleRecording() {
            checkMicrophonePermission { granted in
                if granted {
                    if self.isRecording {
                        self.stopRecording()
                    } else {
                        self.startRecording()
                    }
                } else {
                    print("Microphone permission denied. Cannot record.")
                }
            }
        }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    // MARK: - API Interaction
    private func transcribeAudioAndProcess() {
        let audioFilePath = getDocumentsDirectory().appendingPathComponent("recording.m4a").path
        let fileURL = URL(fileURLWithPath: audioFilePath)

        // 1. File Size Check
        print("File size:", try? FileManager.default.attributesOfItem(atPath: fileURL.path)[.size])

        apiManager.transcribeAudio(fileURL: fileURL) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let transcription):
                    print("API Transcription: \(transcription)")

                    // CALLING CHAT GPT API
                    
                    self.gptApiManager.processInstruction(text: "Some initial text", transcription: transcription, completion: { result in
                        // ... handle the result of your Chat GPT API call ...
                    })
                    
                    // ENDS

                case .failure(let error):
                    // Consider using custom errors here:
                    if let networkError = error as? URLError {
                        print("Network Error: \(networkError.localizedDescription)")
                    } else {
                        // 2. Detailed API Error
                        print("API Error:", error)
                    }
                }
            }
        }
    }
}
