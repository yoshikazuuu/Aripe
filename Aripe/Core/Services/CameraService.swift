import Foundation
import AVFoundation
import UIKit
import Combine

protocol CameraServiceProtocol {
    func setupCamera(in view: UIView) async
    func startSession()
    func stopSession()
    func toggleTorch()
    func captureStillImage() async throws -> UIImage
}

class CameraService: NSObject, CameraServiceProtocol, ObservableObject {
    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var photoOutput = AVCapturePhotoOutput()
    private var lastSampleBuffer: CMSampleBuffer?
    private var captureCompletion: ((UIImage) -> Void)?
    
    // Publishers for reactive updates
    @Published var isSessionRunning = false
    @Published var isTorchOn = false
    @Published var currentFrame: CMSampleBuffer?
    
    func setupCamera(in view: UIView) async {
        await MainActor.run {
            session.sessionPreset = .photo
            
            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device),
                  session.canAddInput(input) else {
                print("❌ Camera input setup failed.")
                return
            }
            
            session.addInput(input)
            
            // Add video output for real-time processing
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
            }
            
            // Add photo output for capture
            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
            }
            
            let preview = AVCaptureVideoPreviewLayer(session: session)
            preview.videoGravity = .resizeAspectFill
            preview.frame = view.bounds
            view.layer.insertSublayer(preview, at: 0)
            self.previewLayer = preview
        }
    }
    
    func startSession() {
        Task {
            await withCheckedContinuation { continuation in
                DispatchQueue.global(qos: .userInitiated).async {
                    self.session.startRunning()
                    DispatchQueue.main.async {
                        self.isSessionRunning = true
                        continuation.resume()
                    }
                }
            }
        }
    }
    
    func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.stopRunning()
            DispatchQueue.main.async {
                self.isSessionRunning = false
            }
        }
    }
    
    func toggleTorch() {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else {
            print("⚠️ Torch not available.")
            return
        }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = (device.torchMode == .on) ? .off : .on
            isTorchOn = device.torchMode == .on
            device.unlockForConfiguration()
        } catch {
            print("❌ Torch control failed: \(error)")
        }
    }
    
    func captureStillImage() async throws -> UIImage {
        return try await withCheckedThrowingContinuation { continuation in
            captureCompletion = { image in
                continuation.resume(returning: image)
            }
            
            let settings = AVCapturePhotoSettings()
            photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
    
    func cropCenter(of image: UIImage, size: CGSize) -> UIImage {
        return image.cropped(to: size)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        lastSampleBuffer = sampleBuffer
        
        DispatchQueue.main.async {
            self.currentFrame = sampleBuffer
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil,
              let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("❌ Failed to capture photo: \(error?.localizedDescription ?? "Unknown error")")
            return
        }
        
        let croppedImage = cropCenter(of: image, size: CGSize(width: 250, height: 250))
        captureCompletion?(croppedImage)
        captureCompletion = nil
    }
} 