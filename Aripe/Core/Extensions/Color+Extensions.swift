import SwiftUI

extension Color {
    // MARK: - App Theme Colors
    static let ripeness = RipenessColors()
    static let appTheme = AppThemeColors()
    
    struct RipenessColors {
        let unripe = Color.orange
        let ripe = Color.green
        let rotten = Color.red
        let unknown = Color.gray
    }
    
    struct AppThemeColors {
        let primary = Color.blue
        let secondary = Color.gray
        let background = Color(.systemBackground)
        let surface = Color(.secondarySystemBackground)
        let accent = Color.green
    }
    
    // MARK: - Custom Colors
    static func forRipenessStatus(_ status: RipenessStatus) -> Color {
        switch status {
        case .unripe: return .ripeness.unripe
        case .ripe: return .ripeness.ripe
        case .rotten: return .ripeness.rotten
        case .unknown: return .ripeness.unknown
        }
    }
} 