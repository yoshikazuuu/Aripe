import Foundation
import Vision
import CoreML
import UIKit

protocol MLPredictionServiceProtocol {
    func predict(from pixelBuffer: CVPixelBuffer) async throws -> PredictionResult
    func predict(from image: UIImage) async throws -> PredictionResult
}

class MLPredictionService: MLPredictionServiceProtocol {
    private let model: VNCoreMLModel?
    
    init() {
        if let coreMLModel = try? AppleRipenessModel(configuration: MLModelConfiguration()).model,
           let visionModel = try? VNCoreMLModel(for: coreMLModel) {
            self.model = visionModel
        } else {
            self.model = nil
            print("❌ Failed to load CoreML model.")
        }
    }
    
    func predict(from pixelBuffer: CVPixelBuffer) async throws -> PredictionResult {
        guard let model = model else {
            throw MLPredictionError.modelNotLoaded
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNCoreMLRequest(model: model) { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let results = request.results as? [VNClassificationObservation],
                      let bestResult = results.first else {
                    continuation.resume(throwing: MLPredictionError.noResults)
                    return
                }
                
                let result = PredictionResult(
                    image: nil,
                    label: bestResult.identifier,
                    confidence: Double(bestResult.confidence)
                )
                continuation.resume(returning: result)
            }
            
            request.imageCropAndScaleOption = .centerCrop
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    func predict(from image: UIImage) async throws -> PredictionResult {
        guard let model = model,
              let cgImage = image.cgImage else {
            throw MLPredictionError.invalidImage
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNCoreMLRequest(model: model) { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let results = request.results as? [VNClassificationObservation],
                      let bestResult = results.first else {
                    continuation.resume(throwing: MLPredictionError.noResults)
                    return
                }
                
                let result = PredictionResult(
                    image: image,
                    label: bestResult.identifier,
                    confidence: Double(bestResult.confidence)
                )
                continuation.resume(returning: result)
            }
            
            request.imageCropAndScaleOption = .centerCrop
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

enum MLPredictionError: LocalizedError {
    case modelNotLoaded
    case invalidImage
    case noResults
    
    var errorDescription: String? {
        switch self {
        case .modelNotLoaded:
            return "ML model failed to load"
        case .invalidImage:
            return "Invalid image provided"
        case .noResults:
            return "No prediction results available"
        }
    }
} 