import Foundation

/// Shown counts and daykeys go through one number formatter. Stored daykeys stay Int.
enum AdmissionFormat {
    static func whole(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? String(value)
    }
}
