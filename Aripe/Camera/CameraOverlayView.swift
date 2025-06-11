import SwiftUI
import PhotosUI

struct CameraOverlayView: View {
    var onCapture: () -> Void
    var onToggleFlash: () -> Void
    var onOpenGallery: () -> Void
    
    @State private var isFlashOn = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.5)
                    .mask(
                        Rectangle()
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .frame(width: 250, height: 250)
                                    .blendMode(.destinationOut)
                            )
                            .compositingGroup()
                    )
                
                RoundedRectangle(cornerRadius: 16)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
                    .frame(width: 250, height: 250)
                    .foregroundColor(.white)
                
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            isFlashOn.toggle()
                            onToggleFlash()
                        }) {
                            Image(systemName: isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                                .foregroundColor(.white)
                                .padding()
                                .background(Circle().fill(Color.black.opacity(0.6)))
                        }
                        .padding()
                    }
                    Spacer()
                    
                    Text("Place the Apple in Focus")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding(.bottom, 8)
                    
                    Button(action: onCapture) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 80, height: 80)
                            .shadow(radius: 10)
                    }
                    .padding(.bottom, 16)
                    
                    Button(action: onOpenGallery) {
                        Image(systemName: "photo.on.rectangle")
                            .foregroundColor(.white)
                            .font(.system(size: 28))
                            .padding()
                            .background(Circle().fill(Color.black.opacity(0.6)))
                    }
                    .padding(.bottom, 20)
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}
