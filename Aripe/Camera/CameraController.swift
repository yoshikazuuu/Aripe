import Foundation
import UIKit

class CameraController: ObservableObject {
    var coordinator: CameraView.Coordinator?

    func toggleTorch() {
        coordinator?.toggleTorch()
    }

    func captureImage(completion: @escaping (UIImage?, String) -> Void) {
        coordinator?.captureStillImage(completion: completion)
    }
}
