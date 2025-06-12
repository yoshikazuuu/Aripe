import SwiftUI

struct SummaryView: View {
    let image: UIImage?
    let prediction: String
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Prediction Summary")
                .font(.title)
                .bold()

            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                    )
            } else {
                Text("No image available")
            }

            Text("Result: \(prediction)")
                .font(.headline)
                .padding()

            Button("Back to Camera") {
                onClose()
            }
            .padding()
            .background(Color.blue.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
