import SwiftUI

struct SummaryView: View {
    @ObservedObject var viewModel: SummaryViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                imageSection
                titleSection
                resultSection
                storageSection
                buttonSection
            }
            .padding(.bottom)
        }
        .navigationTitle("Hasil Scan")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Success", isPresented: $viewModel.showingSaveSuccess) {
            Button("OK") {
                viewModel.showingSaveSuccess = false
            }
        } message: {
            Text("Apple saved successfully!")
        }
    }
    
    private var imageSection: some View {
        Group {
            if let image = viewModel.predictionResult.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(16)
                    .padding(.horizontal)
            }
        }
    }
    
    private var titleSection: some View {
        VStack(spacing: 8) {
            Text("Apel Merah")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(viewModel.formattedDate)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
    
    private var resultSection: some View {
        PredictionResultCard(result: viewModel.predictionResult)
            .padding(.horizontal)
    }
    
    private var storageSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Lokasi Penyimpanan Ideal", systemImage: "thermometer")
                .font(.headline)
            
            Text("20–22°C")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            StorageInfoSection(
                title: "Estimasi ketahanan",
                content: "- Dalam Kulkas: tahan 7 hari\n- Suhu ruang: 2 hari lagi sebelum terlalu matang"
            )
        }
        .padding(.horizontal)
    }
    
    private var buttonSection: some View {
        HStack(spacing: 16) {
            Button("Scan Ulang") {
                viewModel.scanAgain()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.2))
            .foregroundColor(.black)
            .cornerRadius(12)
            
            LoadingButton(
                title: "Simpan Apel",
                isLoading: viewModel.isSaving,
                action: { viewModel.saveApple() },
                backgroundColor: .green
            )
        }
        .padding(.horizontal)
    }
}

struct SummaryContainerView: View {
    let predictionResult: PredictionResult
    
    var body: some View {
        SummaryView(viewModel: SummaryViewModel(predictionResult: predictionResult))
    }
}

struct StorageInfoSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text(content)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
} 