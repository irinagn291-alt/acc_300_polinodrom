import Foundation

/// Reveal role. Names the refusal when a second reveal or a same-day redraw
/// is asked for. The write itself lives on the fold.
enum RevealRefusal: Equatable, Sendable {
    case alreadyOpen
}
