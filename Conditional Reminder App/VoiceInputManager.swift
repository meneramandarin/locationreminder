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

    private override init() {
        super.init()
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
                audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
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
            guard let audioRecorder = audioRecorder else { return }
            audioRecorder.stop()
            isRecording = false
            print("Recording stopped")
            
            // Debugging:
            print("Recording completed? \(audioRecorder.isRecording)")
            print("File URL: \(audioRecorder.url)")
            print("File exists before transcription:", FileManager.default.fileExists(atPath: audioRecorder.url.path))

            DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
                    self.transcribeAudioAndProcess()
                }
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

            apiManager.transcribeAudio(fileURL: fileURL) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let transcription):
                        // Process transcription further if desired:
                        // self.apiManager.summarizeToBulletPoints...
                        print("API Transcription: \(transcription)")
                    case .failure(let error):
                        print("Error transcribing audio: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

