import Foundation
import Speech
import AVFoundation

class SpeechRecognizer: ObservableObject {
    @Published var recognizedText = ""
    @Published var isRecording = false
    @Published var isAuthorized = false
    
    private var audioEngine: AVAudioEngine?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "fr-FR"))
    
    init() {
        requestAuthorization()
    }
    
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    self.isAuthorized = true
                case .denied, .restricted, .notDetermined:
                    self.isAuthorized = false
                    print("Reconnaissance vocale non autorisée")
                @unknown default:
                    self.isAuthorized = false
                }
            }
        }
    }
    
    func startRecording() {
        // Vérifier si déjà en cours d'enregistrement
        if isRecording {
            stopRecording()
            return
        }
        
        // Réinitialiser le texte
        recognizedText = ""
        
        // Configuration de l'audio engine
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine,
              let speechRecognizer = speechRecognizer,
              speechRecognizer.isAvailable else {
            print("Reconnaissance vocale non disponible")
            return
        }
        
        do {
            // Configuration de la session audio
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            // Créer la requête de reconnaissance
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else {
                print("Impossible de créer la requête")
                return
            }
            
            recognitionRequest.shouldReportPartialResults = true
            
            // Configurer l'entrée audio
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                recognitionRequest.append(buffer)
            }
            
            // Démarrer le moteur audio
            audioEngine.prepare()
            try audioEngine.start()
            
            isRecording = true
            
            // Lancer la reconnaissance
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                guard let self = self else { return }
                
                if let result = result {
                    DispatchQueue.main.async {
                        self.recognizedText = result.bestTranscription.formattedString
                    }
                }
                
                if error != nil || (result?.isFinal ?? false) {
                    self.stopRecording()
                }
            }
            
        } catch {
            print("Erreur lors du démarrage de l'enregistrement: \(error)")
            stopRecording()
        }
    }
    
    func stopRecording() {
        isRecording = false
        
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
    }
}
