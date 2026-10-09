import Foundation

/// Deal role. Closed fold of Sealed, Revealed, Kept, and Passed for one daykey.
/// Identity is the daykey. The word and action are the stub dealt that day.
struct Deal: Codable, Equatable, Sendable, Identifiable {
    enum Phase: String, Codable, Equatable, Sendable {
        case sealed
        case revealed
        case kept
        case passed
    }

    var daykey: Int
    var phase: Phase
    var stubID: String
    var word: String
    var action: String

    var id: Int { daykey }

    var faceUp: Bool { phase != .sealed }
}
