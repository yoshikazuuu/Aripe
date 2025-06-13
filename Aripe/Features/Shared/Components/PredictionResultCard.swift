import SwiftUI

struct PredictionResultCard: View {
    let result: PredictionResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                Text(result.formattedConfidence)
                    .font(.title)
                    .bold()
                    .foregroundColor(Color.forRipenessStatus(result.ripenessStatus))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.ripenessStatus.title)
                        .font(.headline)
                        .foregroundColor(Color.forRipenessStatus(result.ripenessStatus))
                    Text(result.ripenessStatus.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color.forRipenessStatus(result.ripenessStatus).opacity(0.1))
        .cornerRadius(12)
    }
} 