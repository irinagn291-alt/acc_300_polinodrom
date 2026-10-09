import Foundation

/// Store role. The only seam between the deal fold and persistence.
/// Views talk to this actor. The in-memory chart is the source of truth.
/// UserDefaults holds one JSON document under `pfo.chart.v1`.
actor DealStore {
    static let chartKey = "pfo.chart.v1"
    static let backupKey = "pfo.chart.v1.bak"
    static let demoKey = "pfo.demo.v1"
    static let debounceNanoseconds: UInt64 = 400_000_000

    private let defaults: UserDefaults
    private var chart: DealChart
    private var pendingSave: Task<Void, Never>?
    private(set) var recoveryNote: String?

    init(defaults: UserDefaults) {
        self.defaults = defaults
        self.chart = DealChart()
    }

    init(suiteName: String) {
        self.defaults = UserDefaults(suiteName: suiteName) ?? UserDefaults(suiteName: "pfo.chart.fallback") ?? .standard
        self.chart = DealChart()
    }

    func load(stock: [Stock], now: Date, calendar: Calendar) {
        let loaded = Self.read(defaults: defaults, stock: stock, now: now, calendar: calendar)
        chart = loaded.chart
        recoveryNote = loaded.note
    }

    func reload(stock: [Stock], now: Date, calendar: Calendar) {
        load(stock: stock, now: now, calendar: calendar)
    }

    func current() -> DealChart {
        chart
    }

    func note() -> String? {
        recoveryNote
    }

    func overwriteChart(_ data: Data) {
        defaults.set(data, forKey: Self.chartKey)
    }

    func overwriteBackup(_ data: Data) {
        defaults.set(data, forKey: Self.backupKey)
    }

    func reveal(now: Date, calendar: Calendar) -> Result<Deal, DealFold.Refusal> {
        apply(DealFold.reveal(
            chart,
            daykey: Daykey.int(from: now, calendar: calendar),
            dayOrdinalInYear: Daykey.dayOrdinalInYear(for: now, calendar: calendar)
        ))
    }

    func crease(now: Date, calendar: Calendar) -> Result<Deal, DealFold.Refusal> {
        let daykey = Daykey.int(from: now, calendar: calendar)
        return apply(DealFold.crease(chart, daykey: daykey, today: daykey))
    }

    func pass(now: Date, calendar: Calendar) -> Result<Deal, DealFold.Refusal> {
        let daykey = Daykey.int(from: now, calendar: calendar)
        return apply(DealFold.pass(chart, daykey: daykey, today: daykey))
    }

    func retract(now: Date, calendar: Calendar) -> Result<Deal, DealFold.Refusal> {
        let daykey = Daykey.int(from: now, calendar: calendar)
        return apply(DealFold.retract(chart, daykey: daykey, today: daykey))
    }

    /// Simulator only. Reveals today and files earlier Kept and Passed cells once.
    func installDemoSeedIfNeeded(now: Date, calendar: Calendar) async {
        #if targetEnvironment(simulator)
        guard defaults.bool(forKey: Self.demoKey) == false else { return }
        chart = DealFold.demoChart(from: chart, now: now, calendar: calendar)
        defaults.set(true, forKey: Self.demoKey)
        await flush()
        #endif
    }

    /// If midnight passed while the chart was open, today becomes the live sealed deal.
    func alignToToday(now: Date, calendar: Calendar) {
        let today = Daykey.int(from: now, calendar: calendar)
        if let existing = chart.deal(for: today) {
            if chart.live?.daykey != today {
                chart.live = existing
                scheduleSave()
            }
            return
        }
        let ordinal = Daykey.dayOrdinalInYear(for: now, calendar: calendar)
        guard case .success(let deal) = DealFold.sealedDeal(
            daykey: today,
            stock: chart.stock,
            dayOrdinalInYear: ordinal
        ) else {
            return
        }
        chart.year.append(deal)
        chart.live = deal
        scheduleSave()
    }

    func flush() async {
        pendingSave?.cancel()
        pendingSave = nil
        await write(chart)
    }

    func resetAllData(now: Date, calendar: Calendar) async {
        pendingSave?.cancel()
        pendingSave = nil
        defaults.removeObject(forKey: Self.chartKey)
        defaults.removeObject(forKey: Self.backupKey)
        let stock = chart.stock
        let finishedOnboarding = chart.onboardingComplete
        chart = Self.sealedChart(stock: stock, now: now, calendar: calendar)
        chart.onboardingComplete = finishedOnboarding
        recoveryNote = nil
        await write(chart)
    }

    /// Scene resigned active or entered background. Writes survive a force-quit.
    func sceneBecameInactive() async {
        await flush()
    }

    func setOnboardingComplete(_ complete: Bool) async {
        chart.onboardingComplete = complete
        await flush()
    }

    private func apply(_ result: Result<DealChart, DealFold.Refusal>) -> Result<Deal, DealFold.Refusal> {
        switch result {
        case .failure(let refusal):
            return .failure(refusal)
        case .success(let next):
            chart = next
            guard let live = next.live else {
                return .failure(.emptyStock)
            }
            scheduleSave()
            return .success(live)
        }
    }

    private func scheduleSave() {
        pendingSave?.cancel()
        pendingSave = Task {
            do {
                try await Task.sleep(nanoseconds: Self.debounceNanoseconds)
            } catch {
                return
            }
            guard !Task.isCancelled else { return }
            await self.writePending()
        }
    }

    private func writePending() async {
        guard !Task.isCancelled else { return }
        await write(chart)
    }

    /// Encode away from any caller that is waiting, then replace the one key.
    /// The previous JSON is copied to the backup key first.
    private func write(_ snapshot: DealChart) async {
        let encoded: Data
        do {
            encoded = try Self.encode(snapshot)
        } catch {
            recoveryNote = "The chart could not be saved."
            return
        }
        if let previous = defaults.data(forKey: Self.chartKey), previous != encoded {
            defaults.set(previous, forKey: Self.backupKey)
        }
        defaults.set(encoded, forKey: Self.chartKey)
    }

    private static func encode(_ snapshot: DealChart) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(snapshot)
    }

    private static func read(
        defaults: UserDefaults,
        stock: [Stock],
        now: Date,
        calendar: Calendar
    ) -> (chart: DealChart, note: String?) {
        if let data = defaults.data(forKey: chartKey) {
            if let decoded = decode(data) {
                return (decoded, nil)
            }
            if let backup = defaults.data(forKey: backupKey), let decoded = decode(backup) {
                return (decoded, "The last chart was restored.")
            }
            return (
                sealedChart(stock: stock, now: now, calendar: calendar),
                "The chart could not be read. Today is sealed again."
            )
        }
        return (sealedChart(stock: stock, now: now, calendar: calendar), nil)
    }

    private static func decode(_ data: Data) -> DealChart? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        do {
            return try decoder.decode(DealChart.self, from: data)
        } catch {
            return nil
        }
    }

    private static func sealedChart(stock: [Stock], now: Date, calendar: Calendar) -> DealChart {
        var chart = DealChart(stock: stock)
        let daykey = Daykey.int(from: now, calendar: calendar)
        let ordinal = Daykey.dayOrdinalInYear(for: now, calendar: calendar)
        if case .success(let deal) = DealFold.sealedDeal(
            daykey: daykey,
            stock: stock,
            dayOrdinalInYear: ordinal
        ) {
            chart.live = deal
            chart.year = [deal]
        }
        return chart
    }
}
