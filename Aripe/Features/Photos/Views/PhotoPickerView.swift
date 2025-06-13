import SwiftUI
import PhotosUI

struct PhotoPickerView: View {
    @StateObject private var viewModel = PhotoPickerViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                imageSection
                controlsSection
                
                Spacer()
            }
            .padding()
            .navigationTitle("Photo Analysis")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var imageSection: some View {
        Group {
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .overlay(
                        Text("No image selected")
                            .foregroundColor(.secondary)
                    )
                    .cornerRadius(12)
            }
        }
    }
    
    private var controlsSection: some View {
        VStack(spacing: 16) {
            PhotosPicker(
                selection: $viewModel.photoPickerItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Text("Choose Image")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Button("Close") {
                dismiss()
            }
            .padding(.top, 20)
        }
    }
} 