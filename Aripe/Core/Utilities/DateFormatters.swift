import Foundation

struct DateFormatters {
    static let indonesianFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM yyyy – HH.mm"
        formatter.locale = Locale(identifier: "id_ID")
        return formatter
    }()
    
    static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "id_ID")
        return formatter
    }()
} 