import SwiftUI
import AVFoundation
import Vision
import CoreML

struct CameraView: UIViewRepresentable {
    @Binding var prediction: String
    var controller: CameraController
    
    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(prediction: $prediction)
        controller.coordinator = coordinator
        return coordinator
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        context.coordinator.setupCamera(in: view)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        private let session = AVCaptureSession()
        private var previewLayer: AVCaptureVideoPreviewLayer?
        private var model: VNCoreMLModel?
        private var lastSampleBuffer: CMSampleBuffer?
        @Binding var prediction: String
        
        init(prediction: Binding<String>) {
            _prediction = prediction
            if let coreMLModel = try? AppleRipenessModel(configuration: MLModelConfiguration()).model,
               let visionModel = try? VNCoreMLModel(for: coreMLModel) {
                self.model = visionModel
            } else {
                self.model = nil
                print("❌ Failed to load CoreML model.")
            }
        }
        
        func setupCamera(in view: UIView) {
            session.sessionPreset = .photo
            
            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device),
                  session.canAddInput(input) else {
                print("❌ Camera input setup failed.")
                return
            }
            session.addInput(input)
            
            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
            
            let preview = AVCaptureVideoPreviewLayer(session: session)
            preview.videoGravity = .resizeAspectFill
            preview.frame = UIScreen.main.bounds
            DispatchQueue.main.async {
                view.layer.insertSublayer(preview, at: 0)
            }
            self.previewLayer = preview
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.session.startRunning()
            }
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            self.lastSampleBuffer = sampleBuffer
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
                  let model = model else {
                return
            }
            
            let request = VNCoreMLRequest(model: model) { request, error in
                guard error == nil,
                      let results = request.results as? [VNClassificationObservation],
                      let bestResult = results.first else {
                    return
                }
                
                DispatchQueue.main.async {
                    self.prediction = "\(bestResult.identifier) (\(Int(bestResult.confidence * 100))%)"
                }
            }
            
            request.imageCropAndScaleOption = .centerCrop
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
            do {
                try handler.perform([request])
            } catch {
                print("❌ Vision request failed: \(error)")
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
                device.unlockForConfiguration()
            } catch {
                print("❌ Torch control failed: \(error)")
            }
        }
        
        func captureStillImage(completion: @escaping (UIImage?, String, Double) -> Void) {
            guard let buffer = lastSampleBuffer,
                  let imageBuffer = CMSampleBufferGetImageBuffer(buffer),
                  let model = model else {
                completion(nil, "No frame or model", 0.0)
                return
            }
            
            let ciImage = CIImage(cvPixelBuffer: imageBuffer)
            let context = CIContext()
            guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
                completion(nil, "Failed to create image", 0.0)
                return
            }
            
            let orientation = exifOrientationFromDeviceOrientation()
            let fullImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: orientation)
            let croppedImage = cropCenter(of: fullImage, size: CGSize(width: 250, height: 250))
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            let request = VNCoreMLRequest(model: model) { request, error in
                guard error == nil,
                      let results = request.results as? [VNClassificationObservation],
                      let topResult = results.first else {
                    DispatchQueue.main.async {
                        completion(croppedImage, "Prediction failed", 0.0)
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    completion(croppedImage, topResult.identifier, Double(topResult.confidence))
                }
            }
            
            do {
                try handler.perform([request])
            } catch {
                print("❌ Error running ML request: \(error)")
                completion(croppedImage, "Prediction error", 0.0)
            }
        }
        func exifOrientationFromDeviceOrientation() -> UIImage.Orientation {
            switch UIDevice.current.orientation {
            case .portraitUpsideDown: return .left
            case .landscapeLeft:      return .upMirrored
            case .landscapeRight:     return .down
            case .portrait:           return .right
            default:                  return .right
            }
        }
        
        func cropCenter(of image: UIImage, size: CGSize) -> UIImage {
            let scale = image.scale
            let imageSize = image.size
            
            // Calculate crop rect in image coordinate space
            let originX = (imageSize.width - size.width) / 2
            let originY = (imageSize.height - size.height) / 2
            let cropRect = CGRect(x: originX * scale, y: originY * scale, width: size.width * scale, height: size.height * scale)
            
            guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
                print("❌ Failed to crop image.")
                return image
            }
            
            return UIImage(cgImage: cgImage, scale: scale, orientation: image.imageOrientation)
        }
    }
}
