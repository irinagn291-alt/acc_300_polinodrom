import UIKit

/// Presentation seam. Views talk to this runtime, which is the only caller of DealStore.
@MainActor
final class PosterRuntime {
    static let shared = PosterRuntime()

    let store: DealStore
    private(set) var chart = DealChart()
    private(set) var recoveryNote: String?
    private(set) var lastRefusal: String?

    private init() {
        store = DealStore(defaults: .standard)
    }

    func boot() async {
        let now = Date()
        let calendar = Calendar.current
        await store.load(stock: StockBundle.load(), now: now, calendar: calendar)
        await store.installDemoSeedIfNeeded(now: now, calendar: calendar)
        await store.alignToToday(now: now, calendar: calendar)
        await refresh()
    }

    func noteDayChange() async {
        let now = Date()
        await store.alignToToday(now: now, calendar: .current)
        await refresh()
        NotificationCenter.default.post(name: Self.dayChange, object: nil)
    }

    func yearWall(now: Date = Date(), calendar: Calendar = .current) -> [Deal] {
        DealFold.yearWall(from: chart, now: now, calendar: calendar)
    }

    func dayOrdinal(now: Date = Date(), calendar: Calendar = .current) -> Int {
        Daykey.dayOrdinalInYear(for: now, calendar: calendar)
    }

    static let dayChange = Notification.Name("pfo.poster.day")

    func refresh() async {
        chart = await store.current()
        recoveryNote = await store.note()
    }

    func reveal() async {
        await perform(await store.reveal(now: Date(), calendar: .current))
    }

    func crease() async {
        await perform(await store.crease(now: Date(), calendar: .current), haptic: true)
    }

    func pass() async {
        await perform(await store.pass(now: Date(), calendar: .current))
    }

    func retract() async {
        await perform(await store.retract(now: Date(), calendar: .current))
    }

    func completeOnboarding() async {
        await store.setOnboardingComplete(true)
        await refresh()
    }

    func reopenOnboarding() async {
        await store.setOnboardingComplete(false)
        await refresh()
    }

    func resetAll() async {
        await store.resetAllData(now: Date(), calendar: .current)
        await refresh()
    }

    func exportText() -> String {
        let lines = chart.creases.map { mark in
            "\(AdmissionFormat.whole(mark.daykey)) \(mark.word). \(mark.action)"
        }
        if lines.isEmpty {
            return "No stubs creased yet."
        }
        return lines.joined(separator: "\n")
    }

    private func perform(_ result: Result<Deal, DealFold.Refusal>, haptic: Bool = false) async {
        switch result {
        case .success:
            lastRefusal = nil
            if haptic {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        case .failure(let refusal):
            lastRefusal = Self.copy(for: refusal)
        }
        await refresh()
    }

    private static func copy(for refusal: DealFold.Refusal) -> String {
        switch refusal {
        case .emptyStock:
            return "The bundled stock could not be read. Today stays sealed."
        case .revealRefused:
            return "Today is already open. A second reveal on this daykey is refused."
        case .creaseOnSealed:
            return "Reveal today's card, then drag the perforation."
        case .alreadyFiled:
            return "Today is already filed. Retract before midnight if that was a mistake."
        case .notToday:
            return "Only today's stub can change."
        case .nothingToRetract:
            return "Nothing on today is waiting to retract."
        }
    }
}
