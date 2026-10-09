import Foundation

/// CreaseMark role. The Runs slot. One mark per creased daykey, holding the
/// action text that Collection counts. Not a streak and not a computed total.
struct CreaseMark: Codable, Equatable, Sendable, Identifiable {
    var id: String
    var daykey: Int
    var stubID: String
    var word: String
    var action: String
}
