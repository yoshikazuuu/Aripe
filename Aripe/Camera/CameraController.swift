import Foundation

class CameraController: ObservableObject {
    var coordinator: CameraView.Coordinator?

    func toggleTorch() {
        coordinator?.toggleTorch()
    }

    func captureImage() {
        coordinator?.captureStillImage()
    }
}
