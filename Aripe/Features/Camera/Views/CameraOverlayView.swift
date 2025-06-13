import SwiftUI

struct CameraOverlayView: View {
    @ObservedObject var viewModel: CameraViewModel
    
    var body: some View {
        VStack {
            // Top overlay with prediction
            predictionOverlay
            
            Spacer()
            
            // Bottom controls
            controlsOverlay
        }
        .ignoresSafeArea()
    }
    
    private var predictionOverlay: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Real-time Prediction")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(viewModel.predictionText)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding(.top, 60)
        .padding(.horizontal, 20)
    }
    
    private var controlsOverlay: some View {
        HStack(spacing: 40) {
            // Gallery button (placeholder)
            Button(action: {
                // TODO: Implement photo picker integration
            }) {
                Image(systemName: "photo.on.rectangle")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(25)
            }
            
            // Capture button
            Button(action: {
                viewModel.captureImage()
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 70, height: 70)
                    
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 85, height: 85)
                    
                    if viewModel.isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                    }
                }
            }
            .disabled(viewModel.isProcessing)
            
            // Flash toggle button
            Button(action: {
                viewModel.toggleFlash()
            }) {
                Image(systemName: "flashlight.off.fill") // Will be dynamic in real implementation
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(25)
            }
        }
        .padding(.bottom, 40)
    }
} 