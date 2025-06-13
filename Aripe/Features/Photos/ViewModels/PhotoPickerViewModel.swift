import Foundation
import SwiftUI
import PhotosUI
import Combine

@MainActor
class PhotoPickerViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var photoPickerItem: PhotosPickerItem?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var predictionResult: PredictionResult?
    
    private let mlService: MLPredictionServiceProtocol
    
    init(mlService: MLPredictionServiceProtocol = MLPredictionService()) {
        self.mlService = mlService
        
        // Watch for photo picker changes
        $photoPickerItem
            .compactMap { $0 }
            .sink { [weak self] item in
                self?.loadImage(from: item)
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private func loadImage(from item: PhotosPickerItem) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                if let data = try await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                    await analyzeImage(uiImage)
                }
            } catch {
                errorMessage = "Failed to load image: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    private func analyzeImage(_ image: UIImage) async {
        do {
            let result = try await mlService.predict(from: image)
            predictionResult = result
        } catch {
            errorMessage = "Failed to analyze image: \(error.localizedDescription)"
        }
    }
    
    func analyzeCurrentImage() {
        guard let image = selectedImage else {
            errorMessage = "No image selected"
            return
        }
        
        isLoading = true
        Task {
            await analyzeImage(image)
            isLoading = false
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    func reset() {
        selectedImage = nil
        photoPickerItem = nil
        predictionResult = nil
        errorMessage = nil
        isLoading = false
    }
} 
