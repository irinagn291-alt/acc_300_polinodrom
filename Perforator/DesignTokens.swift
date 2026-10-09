import SwiftUI

/// SPEC section 7. The only place these hex values live — reach colours
/// and the font family through here. Keep this file and its values.
enum DesignTokens {
    /// #FCFCFC
    static let bg = Color(red: 0.988235, green: 0.988235, blue: 0.988235)
    static let bgHex = "#FCFCFC"
    /// #F5F5F5
    static let surface = Color(red: 0.960784, green: 0.960784, blue: 0.960784)
    static let surfaceHex = "#F5F5F5"
    /// #121212
    static let ink = Color(red: 0.070588, green: 0.070588, blue: 0.070588)
    static let inkHex = "#121212"
    /// #2753B9
    static let accent = Color(red: 0.152941, green: 0.325490, blue: 0.725490)
    static let accentHex = "#2753B9"
    /// #575757
    static let muted = Color(red: 0.341176, green: 0.341176, blue: 0.341176)
    static let mutedHex = "#575757"
    static let fontFamily = "Superclarendon"
}
