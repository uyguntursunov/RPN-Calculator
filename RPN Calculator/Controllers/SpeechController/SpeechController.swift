//
//  SpeechController.swift
//  RPN Calculator
//
//  Created by Uygun Tursunov on 14/03/25.
//

import Foundation
import Speech

class SpeechController {
    private static let inputNodeBus: AVAudioNodeBus = 0
    
    /// The speech recogniser used by the controller to record the user's speech.
    private let speechRecogniser = SFSpeechRecognizer(locale: Locale(identifier: "ru-Ru"))!
    
    /// The current speech recognition request. Created when the user wants to begin speech recognition.
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    /// The current speech recognition task. Created when the user wants to begin speech recognition.
    private var recognitionTask: SFSpeechRecognitionTask?
    
    /// The audio engine used to record input from the microphone.
    private let audioEngine = AVAudioEngine()
    
    /// The delegate of the receiver.
    var delegate: SpeechControllerDelegate?
    
    /// Begins a new speech recording session.
    ///
    /// - Throws: Errors thrown by the creation of the speech recognition session
    func startRecording() throws {
        guard speechRecogniser.isAvailable else {
            // Speech recognition is unavailable, so do not attempt to start.
            return
        }
        if let recognitionTask = recognitionTask {
            // We have a recognition task still running, so cancel it before starting a new one.
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            SFSpeechRecognizer.requestAuthorization({ _ in })
            return
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSession.Category.record)
        try audioSession.setMode(AVAudioSession.Mode.measurement)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            throw SpeechControllerError.noAudioInput
        }
        
        recognitionTask = speechRecogniser.recognitionTask(with: recognitionRequest) { [unowned self] result, error in
            if let result = result {
                self.delegate?.speechController(self, didRecogniseText: result.bestTranscription.formattedString)
            }
            
            if result?.isFinal ?? (error != nil) {
                inputNode.removeTap(onBus: SpeechController.inputNodeBus)
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: SpeechController.inputNodeBus)
        inputNode.installTap(onBus: SpeechController.inputNodeBus, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    /// Ends the current speech recording session.
    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }
}

/// The protocol to conform to for delegates of `SpeechController`.
protocol SpeechControllerDelegate {
    
    /// The message sent when the user's speech has been transcribed. Will be called with partial results of the current recording session.
    ///
    /// - Parameters:
    ///   - speechController: The controller sending the message.
    ///   - text: The text transcribed from the user's speech.
    func speechController(_ speechController: SpeechController, didRecogniseText text: String)
}

/// The error types vended by `SpeechController` if it cannot create an audio recording session.
///
/// - noAudioInput: No audio input connection could be created.
enum SpeechControllerError: Error {
    case noAudioInput
}
