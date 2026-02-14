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
        private let sampleHz: Double = 2.0
        
        private var lastDetectionTime: CFTimeInterval = 0
        private let detectionInterval: Double = 0.5
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
                config.computeUnits = .all
                let model = try best(configuration: config)
                let visionModel = try VNCoreMLModel(for: model.model)
                let request = VNCoreMLRequest(model: visionModel)
                request.imageCropAndScaleOption = .scaleFill
                self.visionRequest = request
            } catch {
                print("Erreur ML: \(error)")
            }
        }

        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            let now = frame.timestamp
            
            if !isProcessing && (now - lastDetectionTime >= detectionInterval) {
                lastDetectionTime = now
                runDetection(frame: frame)
            }

            guard now - lastSampleTime >= 1.0 / sampleHz else { return }
            lastSampleTime = now
            
            guard let arView = vm.arView else { return }
            let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
            if let result = arView.raycast(from: center, allowing: .estimatedPlane, alignment: .any).first {
                let d = distance(frame.camera.transform.columns.3, result.worldTransform.columns.3)
                handleCenterDistance(d)
            } else {
                handleNoHit()
            }
        }
        
        private func runDetection(frame: ARFrame) {
            guard let request = visionRequest else { return }
            isProcessing = true
            
            let pixelBuffer = frame.capturedImage
            let depthMap = frame.sceneDepth?.depthMap
            
            let intrinsics = frame.camera.intrinsics
            let imgSize = CGSize(width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                defer { self?.isProcessing = false }
                
                let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
                do {
                    try handler.perform([request])
                    self?.processDetections(request: request, depthMap: depthMap, intrinsics: intrinsics, imgSize: imgSize)
                } catch {
                    print("Vision error: \(error)")
                }
            }
        }
        
        struct YoloCandidate {
            let labelIndex: Int
            let score: Float
            let box: CGRect
        }

        private func processDetections(request: VNRequest, depthMap: CVPixelBuffer?, intrinsics: simd_float3x3, imgSize: CGSize) {
            guard let obs = request.results?.first as? VNCoreMLFeatureValueObservation,
                  let multiArray = obs.featureValue.multiArrayValue else { return }

            let boxesCount = multiArray.shape[2].intValue
            let labels = [
                "person", "car", "truck", "bus", "bicycle",
                "motorcycle", "traffic_light", "traffic_sign", "pole", "cone"
            ]
            
            var candidates: [YoloCandidate] = []
            
            let modelSize: Float = 416
            for i in 0..<boxesCount {
                var maxScore: Float = 0
                var maxClass = -1
                for c in 0..<10 {
                    let score = multiArray[[0, NSNumber(value: 4 + c), NSNumber(value: i)]].floatValue
                    if score > maxScore { maxScore = score; maxClass = c }
                }
                
                if maxScore > 0.4 {
                    var x = multiArray[[0, 0, NSNumber(value: i)]].floatValue
                    var y = multiArray[[0, 1, NSNumber(value: i)]].floatValue
                    var w = multiArray[[0, 2, NSNumber(value: i)]].floatValue
                    var h = multiArray[[0, 3, NSNumber(value: i)]].floatValue
                    
                    if max(x, y, w, h) > 2 {
                        x /= modelSize
                        y /= modelSize
                        w /= modelSize
                        h /= modelSize
                    }
                    
                    let rect = CGRect(x: Double(x - w/2), y: Double(y - h/2), width: Double(w), height: Double(h))
                    candidates.append(YoloCandidate(labelIndex: maxClass, score: maxScore, box: rect))
                }
            }
            
            let finalCandidates = nms(candidates, iouThreshold: 0.5)
            var finalItems: [DetectedItem] = []
            
            for cand in finalCandidates.prefix(5) {
                let label = labels[cand.labelIndex]
                
                let uModel = CGFloat(cand.box.midX)
                let vModel = CGFloat(cand.box.midY)
                
                var xyzText = "\n(Depth: n/a)"
                if let depthMap = depthMap {
                    let uv = mapModelToDepthUV(u: uModel, v: vModel, imgSize: imgSize)
                    let z = getAverageDepth(from: depthMap, u: uv.x, v: uv.y)
                    if z > 0.1 {
                        let u_px = Float(uv.x) * Float(imgSize.width)
                        let v_px = Float(uv.y) * Float(imgSize.height)
                        
                        let x_m = (u_px - intrinsics.columns.2.x) * z / intrinsics.columns.0.x
                        let y_m = (v_px - intrinsics.columns.2.y) * z / intrinsics.columns.1.y
                        
                        xyzText = String(format: "\nX: %.2fm  Y: %.2fm  Z: %.2fm", x_m, -y_m, z)
                    }
                }
                
                let scoreTxt = String(format: "%.0f%%", cand.score * 100)
                finalItems.append(DetectedItem(label: label, confidence: "\(scoreTxt)\(xyzText)"))
            }
            
            DispatchQueue.main.async {
                self.vm.detectedList = finalItems
            }
        }
        
        private func getAverageDepth(from depthMap: CVPixelBuffer, u: CGFloat, v: CGFloat) -> Float {
            CVPixelBufferLockBaseAddress(depthMap, .readOnly)
            defer { CVPixelBufferUnlockBaseAddress(depthMap, .readOnly) }
            
            let width = CVPixelBufferGetWidth(depthMap)
            let height = CVPixelBufferGetHeight(depthMap)
            let clampedU = max(0, min(1, u))
            let clampedV = max(0, min(1, v))
            let centerCol = Int(clampedU * CGFloat(width))
            let centerRow = Int(clampedV * CGFloat(height))
            
            var sum: Float = 0
            var count: Float = 0
            let margin = 2
            
            let base = CVPixelBufferGetBaseAddress(depthMap)!
            let bytesPR = CVPixelBufferGetBytesPerRow(depthMap)
            
            for r in (centerRow - margin)...(centerRow + margin) {
                for c in (centerCol - margin)...(centerCol + margin) {
                    if r >= 0 && r < height && c >= 0 && c < width {
                        let pixel = base.advanced(by: r * bytesPR + c * 4).assumingMemoryBound(to: Float32.self)
                        let val = pixel.pointee
                        if val > 0 {
                            sum += val
                            count += 1
                        }
                    }
                }
            }
            
            return count > 0 ? sum / count : 0
        }

        private func mapModelToDepthUV(u: CGFloat, v: CGFloat, imgSize: CGSize) -> CGPoint {
            let modelSize: CGFloat = 416
            let orientedSize = CGSize(width: imgSize.height, height: imgSize.width)
            
            let scale = max(modelSize / orientedSize.width, modelSize / orientedSize.height)
            let scaledW = orientedSize.width * scale
            let scaledH = orientedSize.height * scale
            let padX = (scaledW - modelSize) / 2
            let padY = (scaledH - modelSize) / 2
            
            let xScaled = u * modelSize
            let yScaled = v * modelSize
            let xOriented = (xScaled + padX) / scale
            let yOriented = (yScaled + padY) / scale
            
            let xOrientedN = xOriented / orientedSize.width
            let yOrientedN = yOriented / orientedSize.height
            
            let xOriginalN = yOrientedN
            let yOriginalN = 1.0 - xOrientedN
            
            return CGPoint(x: xOriginalN, y: yOriginalN)
        }
        
        private func nms(_ boxes: [YoloCandidate], iouThreshold: Float) -> [YoloCandidate] {
            var sorted = boxes.sorted { $0.score > $1.score }
            var selected: [YoloCandidate] = []
            while !sorted.isEmpty {
                let current = sorted.removeFirst()
                selected.append(current)
                sorted.removeAll { iou(boxA: current.box, boxB: $0.box) > iouThreshold }
            }
            return selected
        }
        
        private func iou(boxA: CGRect, boxB: CGRect) -> Float {
            let xA = max(boxA.minX, boxB.minX); let yA = max(boxA.minY, boxB.minY)
            let xB = min(boxA.maxX, boxB.maxX); let yB = min(boxA.maxY, boxB.maxY)
            let inter = max(0, xB - xA) * max(0, yB - yA)
            let union = boxA.width * boxA.height + boxB.width * boxB.height - inter
            return Float(inter / union)
        }

        private func distance(_ a: SIMD4<Float>, _ b: SIMD4<Float>) -> Float {
            return simd_distance(SIMD3(a.x, a.y, a.z), SIMD3(b.x, b.y, b.z))
        }

        private func handleCenterDistance(_ d: Float) {
            let clamped = max(0, min(d, vm.maxSense))
            vm.distanceText = String(format: "%.2f m", clamped)
            if d < vm.nearThreshold { updateStatus(.high, "DANGER", d) }
            else if d < vm.midThreshold { updateStatus(.medium, "Attention", d) }
            else if d <= vm.maxSense { updateStatus(.low, "Zone libre", d) }
            else { handleNoHit() }
        }
        
        private func updateStatus(_ level: WarningLevel, _ text: String, _ d: Float) {
            vm.statusText = text
            vm.warningLevel = level
            if vm.isAudioEnabled {
                if level == .high { vm.audio.setMode(.continuous(frequency: max(300, 1200 - (Double(d) * 300)))) }
                else if level == .medium { vm.audio.setMode(.beep(interval: max(0.15, min(1.2, Double(d) / 1.5)), frequency: max(300, 1200 - (Double(d) * 300)))) }
                else { vm.audio.setMode(.beep(interval: 1.0, frequency: 600)) }
            } else { vm.audio.setMode(.silent) }
            
            if level == .high && !vm.lastCrossedNear {
                vm.haptics.notificationOccurred(.warning)
                vm.lastCrossedNear = true
            } else if level != .high {
                vm.lastCrossedNear = false
            }
        }

        private func handleNoHit() {
            vm.distanceText = "—"
            vm.statusText = "Scan..."
            vm.warningLevel = .none
            vm.audio.setMode(.silent)
        }
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
                        ForEach(items, id: \.id) { item in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(item.label.capitalized)
                                        .bold()
                                    Spacer()
                                    let percentage = item.confidence.components(separatedBy: "\n").first ?? ""
                                    Text(percentage)
                                        .font(.caption)
                                        .padding(4)
                                        .background(Color.green.opacity(0.2))
                                        .cornerRadius(5)
                                }
                                
                                if item.confidence.contains("\n") {
                                    let details = item.confidence.components(separatedBy: "\n").dropFirst().joined(separator: "\n")
                                    
                                    let infoColor: Color = details.contains("X:") ? .secondary : .orange
                                    
                                    Text(details)
                                        .font(.system(.caption2, design: .monospaced))
                                        .foregroundStyle(infoColor)
                                }
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
