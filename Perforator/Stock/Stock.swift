import Foundation

/// Stock role. The Islands slot: the bundled impulse pool in fixed order.
/// A deal reads `pool[dayOrdinalInYear % count]` and the pool is not reshuffled.
struct Stock: Codable, Equatable, Sendable, Identifiable {
    var id: String
    var word: String
    var action: String
}

enum StockBundle {
    static func load(from bundle: Bundle = .main) -> [Stock] {
        guard let url = bundle.url(forResource: "stock", withExtension: "json") else {
            return []
        }
        guard let data = try? Data(contentsOf: url) else {
            return []
        }
        guard let decoded = try? JSONDecoder().decode([Stock].self, from: data) else {
            return []
        }
        return decoded
    }
}
