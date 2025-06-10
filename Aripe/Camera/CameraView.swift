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

            session.startRunning()
        }

        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
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

        func captureStillImage() {
            print("📸 Capture still image called (you can implement image saving here)")
            // You could add logic here to extract and store a UIImage from the last frame.
        }
    }
}
