import Foundation

/// Chart root. One Codable record: Islands (stock), Books (year), Sessions (live),
/// Runs (creases), Rhumbs (passes). schemaVersion starts at 1 and the decoder
/// switches on it. Views never touch this type. DealStore is the seam.
struct DealChart: Codable, Equatable, Sendable {
    static let currentSchema = 1

    var schemaVersion: Int
    var stock: [Stock]
    var year: [Deal]
    var live: Deal?
    var creases: [CreaseMark]
    var passes: [Pass]
    var onboardingComplete: Bool

    init(
        schemaVersion: Int = DealChart.currentSchema,
        stock: [Stock] = [],
        year: [Deal] = [],
        live: Deal? = nil,
        creases: [CreaseMark] = [],
        passes: [Pass] = [],
        onboardingComplete: Bool = false
    ) {
        self.schemaVersion = schemaVersion
        self.stock = stock
        self.year = year
        self.live = live
        self.creases = creases
        self.passes = passes
        self.onboardingComplete = onboardingComplete
    }

    enum CodingKeys: String, CodingKey {
        case schemaVersion
        case stock
        case year
        case live
        case creases
        case passes
        case onboardingComplete
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let version = try container.decode(Int.self, forKey: .schemaVersion)
        switch version {
        case 1:
            schemaVersion = version
            stock = try container.decodeIfPresent([Stock].self, forKey: .stock) ?? []
            year = try container.decodeIfPresent([Deal].self, forKey: .year) ?? []
            live = try container.decodeIfPresent(Deal.self, forKey: .live)
            creases = try container.decodeIfPresent([CreaseMark].self, forKey: .creases) ?? []
            passes = try container.decodeIfPresent([Pass].self, forKey: .passes) ?? []
            onboardingComplete = try container.decodeIfPresent(Bool.self, forKey: .onboardingComplete) ?? false
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion,
                in: container,
                debugDescription: "Unsupported chart schema \(version)."
            )
        }
    }

    func deal(for daykey: Int) -> Deal? {
        year.first { $0.daykey == daykey }
    }
}
