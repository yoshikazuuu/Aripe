import Foundation
import UIKit

struct PredictionResult {
    let id = UUID()
    let image: UIImage?
    let label: String
    let confidence: Double
    let timestamp: Date
    
    init(image: UIImage?, label: String, confidence: Double, timestamp: Date = Date()) {
        self.image = image
        self.label = label
        self.confidence = confidence
        self.timestamp = timestamp
    }
    
    var formattedConfidence: String {
        return "\(Int(confidence * 100))%"
    }
    
    var ripenessStatus: RipenessStatus {
        return RipenessStatus(from: label)
    }
}

enum RipenessStatus: CaseIterable {
    case unripe
    case ripe
    case rotten
    case unknown
    
    init(from label: String) {
        switch label.lowercased() {
        case "unripe":
            self = .unripe
        case "ripe":
            self = .ripe
        case "rotten":
            self = .rotten
        default:
            self = .unknown
        }
    }
    
    var title: String {
        switch self {
        case .unripe:
            return "Belum Matang"
        case .ripe:
            return "Matang"
        case .rotten:
            return "Busuk"
        case .unknown:
            return "Tidak Dikenal"
        }
    }
    
    var description: String {
        switch self {
        case .unripe:
            return "Apel masih keras dan belum manis"
        case .ripe:
            return "Siap dikonsumsi, rasa manis maksimal"
        case .rotten:
            return "Apel sudah tidak layak dikonsumsi"
        case .unknown:
            return "Tidak bisa mendeteksi kondisi apel"
        }
    }
    
    var color: String {
        switch self {
        case .unripe:
            return "orange"
        case .ripe:
            return "green"
        case .rotten:
            return "red"
        case .unknown:
            return "gray"
        }
    }
} 