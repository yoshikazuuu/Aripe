import SwiftUI

struct MainView: View {
    @StateObject private var cameraController = CameraController()
    @State private var predictionText: String = "Waiting for prediction..."
    @State private var showPhotoPicker = false
    @State private var selectedImage: UIImage?

    var body: some View {
        ZStack(alignment: .bottom) {
            CameraView(prediction: $predictionText, controller: cameraController)
                .edgesIgnoringSafeArea(.all)

            CameraOverlayView(
                onCapture: {
                    cameraController.captureImage()
                },
                onToggleFlash: {
                    cameraController.toggleTorch()
                },
                onOpenGallery: {
                    showPhotoPicker = true
                }
            )

            Text(predictionText)
                .font(.title2)
                .bold()
                .padding()
                .background(Color.black.opacity(0.6))
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.bottom, 30)
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPickerView(selectedImage: $selectedImage)
        }
    }
}
