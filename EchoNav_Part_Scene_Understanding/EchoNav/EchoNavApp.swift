import SwiftUI
import RealityKit
import ARKit
import AVFoundation
import Combine
import Vision
import CoreML

struct DetectedItem: Identifiable {
    let id = UUID()
    let label: String
    let confidence: String
}

@main
struct EchoNavApp: App {
    var body: some SwiftUI.Scene {
        WindowGroup {
            ProximityRootView()
        }
    }
}

struct ProximityRootView: View {
    @StateObject private var vm = ProximityViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(viewModel: vm)
                .ignoresSafeArea()
            
            VStack {
                HUDHeader(viewModel: vm)
                    .padding(.top, 40)
                    .padding(.horizontal)
                
                Spacer()
                
                DetectionListView(items: vm.detectedList)
                    .frame(height: 250)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .padding()
            }
        }
        .onAppear { vm.start() }
        .onDisappear { vm.stop() }
    }
}

final class ProximityViewModel: NSObject, ObservableObject {
    @Published var distanceText = "—"
    @Published var statusText = "Init..."
    @Published var isLiDARAvailable = false
    @Published var warningLevel: WarningLevel = .none
    @Published var detectedList: [DetectedItem] = []
    
    @Published var isAudioEnabled: Bool = true {
        didSet {
            if !isAudioEnabled { audio.setMode(.silent) }
        }
    }

    let nearThreshold: Float = 0.6
    let midThreshold: Float  = 1.2
    let maxSense: Float      = 4.0

    weak var arView: ARView?
    var audio = ProximityAudio()
    var haptics = UINotificationFeedbackGenerator()
    var lastCrossedNear = false

    func start() {
        guard ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) else { return }
        isLiDARAvailable = true
        statusText = "Scan..."
        haptics.prepare()
        audio.startEngine()
    }

    func stop() {
        audio.stopEngine()
        arView?.session.pause()
    }
}

struct ARViewContainer: UIViewRepresentable {
    let viewModel: ProximityViewModel

    func makeUIView(context: Context) -> ARView {
        let view = ARView(frame: .zero)
        viewModel.arView = view
        view.session.delegate = context.coordinator
        
        let config = ARWorldTrackingConfiguration()
        config.sceneReconstruction = .meshWithClassification
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            config.frameSemantics.insert(.sceneDepth)
        }
        view.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        return view
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(viewModel: viewModel) }

    final class Coordinator: NSObject, ARSessionDelegate {
        private let vm: ProximityViewModel
        private var lastSampleTime: CFTimeInterval = 0
        private let sampleHz: Double = 10
        
        private var lastDetectionTime: CFTimeInterval = 0
        private let detectionInterval: Double = 1.0
        private var visionRequest: VNCoreMLRequest?
        private var isProcessing = false

        init(viewModel: ProximityViewModel) {
            self.vm = viewModel
            super.init()
            setupVision()
        }

        private func setupVision() {
            do {
                let config = MLModelConfiguration()
                let model = try yolov8l(configuration: config)
                let visionModel = try VNCoreMLModel(for: model.model)
                
                let request = VNCoreMLRequest(model: visionModel) { [weak self] request, error in
                    self?.processDetections(for: request, error: error)
                }
                request.imageCropAndScaleOption = .scaleFill
                self.visionRequest = request
            } catch {
                print("ML Load Error: \(error)")
            }
        }

        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            let now = frame.timestamp
            
            if !isProcessing && (now - lastDetectionTime >= detectionInterval) {
                lastDetectionTime = now
                isProcessing = true
                runDetection(frame: frame)
            }

            guard now - lastSampleTime >= 1.0 / sampleHz else { return }
            lastSampleTime = now
            
            guard let arView = vm.arView else { return }
            let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
            let results = arView.raycast(from: center, allowing: .estimatedPlane, alignment: .any)
            
            if let result = results.first {
                let camT = frame.camera.transform.columns.3
                let resT = result.worldTransform.columns.3
                let d = simd_distance(SIMD3(camT.x, camT.y, camT.z), SIMD3(resT.x, resT.y, resT.z))
                handleDistance(d)
            } else {
                handleNoHit()
            }
        }
        
        private func runDetection(frame: ARFrame) {
            guard let request = visionRequest else {
                isProcessing = false
                return
            }
            let pixelBuffer = frame.capturedImage
            DispatchQueue.global(qos: .userInitiated).async {
                let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
                try? handler.perform([request])
            }
        }
        
        private func processDetections(for request: VNRequest, error: Error?) {
            defer { isProcessing = false }
            guard let results = request.results as? [VNRecognizedObjectObservation] else { return }
            
            let validDetections = results.filter { $0.confidence > 0.4 }
            
            DispatchQueue.main.async {
                self.vm.detectedList = validDetections.map { result in
                    let label = result.labels.first?.identifier ?? "?"
                    let conf = Int(result.confidence * 100)
                    return DetectedItem(label: label, confidence: "\(conf)%")
                }
            }
        }

        private func handleDistance(_ d: Float) {
            let clamped = max(0, min(d, vm.maxSense))
            vm.distanceText = String(format: "%.2f m", clamped)
            
            if d < vm.nearThreshold {
                updateStatus(.high, "DANGER", d)
            } else if d < vm.midThreshold {
                updateStatus(.medium, "Attention", d)
            } else if d <= vm.maxSense {
                updateStatus(.low, "Zone libre", d)
            } else {
                handleNoHit()
            }
        }
        
        private func updateStatus(_ level: WarningLevel, _ text: String, _ d: Float) {
            vm.statusText = text
            vm.warningLevel = level
            
            if vm.isAudioEnabled {
                if level == .high {
                    vm.audio.setMode(.continuous(frequency: mapFreq(d)))
                } else if level == .medium {
                    vm.audio.setMode(.beep(interval: mapInterval(d), frequency: mapFreq(d)))
                } else {
                    vm.audio.setMode(.beep(interval: 1.0, frequency: 600))
                }
            } else {
                vm.audio.setMode(.silent)
            }

            if level == .high {
                if !vm.lastCrossedNear {
                    vm.haptics.notificationOccurred(.warning)
                    vm.lastCrossedNear = true
                }
            } else {
                vm.lastCrossedNear = false
            }
        }

        private func handleNoHit() {
            vm.distanceText = "—"
            vm.statusText = "Scan..."
            vm.warningLevel = .none
            vm.audio.setMode(.silent)
        }
        
        private func mapInterval(_ d: Float) -> Double { max(0.15, min(1.2, Double(d) / 1.5)) }
        private func mapFreq(_ d: Float) -> Double { max(300, 1200 - (Double(d) * 300)) }
    }
}

struct HUDHeader: View {
    @ObservedObject var viewModel: ProximityViewModel
    
    var body: some View {
        HStack(spacing: 15) {
            Text(viewModel.distanceText)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .monospacedDigit()
            
            VStack(alignment: .leading) {
                Text("LIDAR")
                    .font(.caption).bold().foregroundStyle(.secondary)
                StatusBadge(level: viewModel.warningLevel, text: viewModel.statusText)
            }
            
            Spacer()
            
            Toggle("", isOn: $viewModel.isAudioEnabled)
                .labelsHidden()
                .tint(.green)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 5)
    }
}

struct DetectionListView: View {
    let items: [DetectedItem]
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "eye.fill")
                Text("Objets détectés")
                    .font(.headline)
                Spacer()
                Text("\(items.count)")
                    .font(.caption)
                    .padding(5)
                    .background(Color.blue.opacity(0.2), in: Circle())
            }
            .padding(.bottom, 5)
            
            if items.isEmpty {
                Text("Aucun objet reconnu...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 20)
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(items) { item in
                            HStack {
                                Text(item.label.capitalized)
                                    .bold()
                                Spacer()
                                Text(item.confidence)
                                    .font(.caption)
                                    .padding(4)
                                    .background(Color.green.opacity(0.2))
                                    .cornerRadius(5)
                            }
                            .padding(10)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                }
            }
        }
        .padding()
    }
}

enum WarningLevel { case none, low, medium, high }

struct StatusBadge: View {
    let level: WarningLevel
    let text: String
    
    var body: some View {
        Text(text)
            .font(.subheadline.weight(.bold))
            .foregroundStyle(color)
    }
    
    private var color: Color {
        switch level {
        case .none: return .gray
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}

final class ProximityAudio {
    enum Mode { case silent, beep(interval: Double, frequency: Double), continuous(frequency: Double) }
    private let engine = AVAudioEngine()
    private var source: AVAudioSourceNode?
    private var timer: DispatchSourceTimer?
    private let sampleRate: Double = 44_100
    private var currentMode: Mode = .silent
    private var phase: Double = 0
    private var isBeeping = false
    private let beepDuration: Double = 0.08

    func startEngine() {
        guard !engine.isRunning else { return }
        let src = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self = self else { return 0 }
            let buffer = UnsafeMutableAudioBufferListPointer(audioBufferList).first!
            let ptr = buffer.mData!.assumingMemoryBound(to: Float.self)
            let frames = Int(frameCount)
            
            var freq: Double = 0
            var renderTone = false
            
            switch self.currentMode {
            case .silent: renderTone = false
            case .continuous(let f): freq = f; renderTone = true
            case .beep(_, let f): freq = f; renderTone = self.isBeeping
            }
            
            if renderTone && freq > 0 {
                let twoPi = 2 * Double.pi
                for n in 0..<frames {
                    ptr[n] = Float(sin(self.phase)) * 0.1
                    self.phase += twoPi * freq / self.sampleRate
                    if self.phase > twoPi { self.phase -= twoPi }
                }
            } else {
                for n in 0..<frames { ptr[n] = 0 }
            }
            return 0
        }
        self.source = src
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        engine.attach(src)
        engine.connect(src, to: engine.mainMixerNode, format: format)
        try? engine.start()
    }

    func stopEngine() {
        timer?.cancel(); timer = nil
        engine.stop()
    }

    func setMode(_ mode: Mode) {
        if case .beep(let interval, let f) = mode {
            startBeepTimer(interval: interval, frequency: f)
        } else {
            stopBeepTimer()
        }
        currentMode = mode
    }

    private func startBeepTimer(interval: Double, frequency: Double) {
        stopBeepTimer()
        currentMode = .beep(interval: interval, frequency: frequency)
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now(), repeating: interval)
        t.setEventHandler { [weak self] in
            guard let self = self else { return }
            self.phase = 0
            self.isBeeping = true
            DispatchQueue.global().asyncAfter(deadline: .now() + self.beepDuration) {
                self.isBeeping = false
            }
        }
        t.resume()
        timer = t
    }

    private func stopBeepTimer() {
        timer?.cancel(); timer = nil
        isBeeping = false
    }
}
