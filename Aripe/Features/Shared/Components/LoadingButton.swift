import SwiftUI

struct LoadingButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void
    var backgroundColor: Color = .blue
    var foregroundColor: Color = .white
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
                        .scaleEffect(0.8)
                }
                Text(title)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(12)
        }
        .disabled(isLoading || isDisabled)
        .opacity(isLoading || isDisabled ? 0.6 : 1.0)
    }
} 