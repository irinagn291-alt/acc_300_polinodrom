import Foundation

/// Reads `-ReviewScreen` once, after onboarding, and names the sheet to present.
@MainActor
enum ReviewHook {
    private static var didRead = false
    private static var value: String?

    static func screenOnce() -> String? {
        if !didRead {
            value = ReviewLaunch.screen
            didRead = true
        }
        return value
    }
}
