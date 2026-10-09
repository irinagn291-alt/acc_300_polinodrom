import UIKit

/// Type role. One Superclarendon scale for the poster and the sheets.
/// Display owns the word. Body carries the micro-action. Nothing else.
enum TypeScale {
    static func display() -> UIFont { face("Black", size: 64, textStyle: .largeTitle) }
    static func title() -> UIFont { face("Bold", size: 28, textStyle: .title1) }
    static func headline() -> UIFont { face("Bold", size: 22, textStyle: .title2) }
    static func body() -> UIFont { face("Regular", size: 17, textStyle: .body) }
    static func caption() -> UIFont { face("Regular", size: 14, textStyle: .caption1) }
    static func micro() -> UIFont { face("Regular", size: 12, textStyle: .caption2) }

    /// Poster word steps down inside the same six faces so AX sizes stay on one line.
    @MainActor
    static func posterWord() -> UIFont {
        let category = UIApplication.shared.preferredContentSizeCategory
        if category >= .accessibilityExtraLarge {
            return headline()
        }
        if category >= .extraExtraLarge {
            return title()
        }
        return display()
    }

    private static func face(_ weight: String, size: CGFloat, textStyle: UIFont.TextStyle) -> UIFont {
        let name = "\(DesignTokens.fontFamily)-\(weight)"
        let base = UIFont(name: name, size: size)
            ?? UIFont(descriptor: UIFontDescriptor(fontAttributes: [.family: DesignTokens.fontFamily]), size: size)
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: base)
    }
}
