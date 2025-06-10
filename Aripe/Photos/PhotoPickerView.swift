import SwiftUI
import PhotosUI

struct PhotoPickerView: View {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss

    @State private var photoPickerItem: PhotosPickerItem? = nil

    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
                    .padding()
            } else {
                Text("No image selected")
                    .foregroundColor(.secondary)
                    .padding()
            }

            PhotosPicker(
                selection: $photoPickerItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Text("Choose Image")
                    .padding()
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button("Close") {
                dismiss()
            }
            .padding(.top, 20)
        }
        .onChange(of: photoPickerItem) {
            loadImage(from: photoPickerItem)
        }
        .padding()
    }

    private func loadImage(from item: PhotosPickerItem?) {
        guard let item = item else { return }
        Task {
            do {
                if let data = try await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                }
            } catch {
                print("❌ Failed to load image: \(error)")
            }
        }
    }
}
