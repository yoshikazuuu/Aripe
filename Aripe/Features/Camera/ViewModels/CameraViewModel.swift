import Foundation
import SwiftUI
import Combine
import AVFoundation

@MainActor
class CameraViewModel: ObservableObject {
    @Published var predictionText: String = "Waiting for prediction..."
    @Published var isProcessing: Bool = false
    @Published var errorMessage: String?
    @Published var navigationPath = NavigationPath()
    
    private let cameraService: CameraServiceProtocol
    private let mlService: MLPredictionServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
        cameraService: CameraServiceProtocol = CameraService(),
        mlService: MLPredictionServiceProtocol = MLPredictionService()
    ) {
        self.cameraService = cameraService
        self.mlService = mlService
        setupBindings()
    }
    
    private func setupBindings() {
        if let cameraService = cameraService as? CameraService {
            cameraService.$currentFrame
                .compactMap { $0 }
                .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
                .sink { [weak self] sampleBuffer in
                    self?.processCameraFrame(sampleBuffer)
                }
                .store(in: &cancellables)
        }
    }
    
    func setupCamera(in view: UIView) {
        Task {
            await cameraService.setupCamera(in: view)
            cameraService.startSession()
        }
    }
    
    func toggleFlash() {
        cameraService.toggleTorch()
    }
    
    func captureImage() {
        isProcessing = true
        
        Task {
            do {
                let capturedImage = try await cameraService.captureStillImage()
                let result = try await mlService.predict(from: capturedImage)
                
                // Navigate to summary with result
                let summaryData = SummaryData(predictionResult: result)
                navigationPath.append(summaryData)
                
            } catch {
                errorMessage = error.localizedDescription
            }
            isProcessing = false
        }
    }
    
    private func processCameraFrame(_ sampleBuffer: CMSampleBuffer) {
        guard !isProcessing,
              let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        Task {
            do {
                let result = try await mlService.predict(from: pixelBuffer)
                predictionText = "\(result.label) (\(result.formattedConfidence))"
            } catch {
                predictionText = "Prediction failed"
            }
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    deinit {
        cameraService.stopSession()
    }
}

// MARK: - Navigation Data
struct SummaryData: Hashable {
    let predictionResult: PredictionResult
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(predictionResult.id)
    }
    
    static func == (lhs: SummaryData, rhs: SummaryData) -> Bool {
        lhs.predictionResult.id == rhs.predictionResult.id
    }
} 