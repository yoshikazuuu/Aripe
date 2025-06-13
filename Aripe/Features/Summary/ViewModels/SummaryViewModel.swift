import Foundation
import SwiftUI

@MainActor
class SummaryViewModel: ObservableObject {
    @Published var predictionResult: PredictionResult
    @Published var isSaving: Bool = false
    @Published var showingSaveSuccess: Bool = false
    @Published var errorMessage: String?
    
    init(predictionResult: PredictionResult) {
        self.predictionResult = predictionResult
    }
    
    var formattedDate: String {
        return DateFormatters.indonesianFormatter.string(from: predictionResult.timestamp)
    }
    
    var ripenessInfo: (title: String, description: String, color: Color) {
        let status = predictionResult.ripenessStatus
        let color = Color.forRipenessStatus(status)
        return (status.title, status.description, color)
    }
    
    func saveApple() {
        isSaving = true
        
        // Simulate saving operation
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            
            // Here you would typically save to Core Data, CloudKit, or local storage
            showingSaveSuccess = true
            isSaving = false
        }
    }
    
    func scanAgain() {
        // This will be handled by navigation
    }
    
    func clearError() {
        errorMessage = nil
    }
} 