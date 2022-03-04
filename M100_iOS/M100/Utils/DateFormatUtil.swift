import Foundation

final class DateFormatUtil {
    
    static func dateFormat(milSecond: Double) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(milSecond)))
    }
}
