import Foundation

/// Pass role. The Rhumbs slot. A skip for one daykey. The year cell stays
/// empty of a stub. No streak counter is stored.
struct Pass: Codable, Equatable, Sendable, Identifiable {
    var id: String
    var daykey: Int
}
