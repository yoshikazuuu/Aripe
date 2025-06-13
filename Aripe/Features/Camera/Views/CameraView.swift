import SwiftUI
import AVFoundation

struct CameraView: UIViewRepresentable {
    @ObservedObject var viewModel: CameraViewModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        viewModel.setupCamera(in: view)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Updates handled by ViewModel
    }
}

struct CameraContainerView: View {
    @StateObject private var viewModel = CameraViewModel()
    
    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            ZStack {
                CameraView(viewModel: viewModel)
                    .ignoresSafeArea()
                
                CameraOverlayView(viewModel: viewModel)
            }
            .navigationTitle("Scan")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: SummaryData.self) { summaryData in
                SummaryContainerView(predictionResult: summaryData.predictionResult)
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
} 