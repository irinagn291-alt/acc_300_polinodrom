import Foundation

/// Fold role. Pure transitions for the Deal ADT. The year is this same fold
/// keyed by daykey. Reveal writes Revealed from pool[dayOrdinalInYear % count].
/// Crease writes a CreaseMark and files Kept. Pass files Passed. A second
/// Reveal on the same daykey is refused. Wrap is modulo, only after the pool cycles.
enum DealFold {
    enum Refusal: Equatable, Error, Sendable {
        case emptyStock
        case revealRefused
        case creaseOnSealed
        case alreadyFiled
        case notToday
        case nothingToRetract
    }

    static func stockIndex(dayOrdinalInYear: Int, count: Int) -> Int? {
        guard count > 0 else { return nil }
        let remainder = dayOrdinalInYear % count
        return remainder >= 0 ? remainder : remainder + count
    }

    static func stub(in stock: [Stock], dayOrdinalInYear: Int) -> Stock? {
        guard let index = stockIndex(dayOrdinalInYear: dayOrdinalInYear, count: stock.count) else {
            return nil
        }
        return stock[index]
    }

    static func sealedDeal(daykey: Int, stock: [Stock], dayOrdinalInYear: Int) -> Result<Deal, Refusal> {
        guard let stub = stub(in: stock, dayOrdinalInYear: dayOrdinalInYear) else {
            return .failure(.emptyStock)
        }
        return .success(
            Deal(
                daykey: daykey,
                phase: .sealed,
                stubID: stub.id,
                word: stub.word,
                action: stub.action
            )
        )
    }

    static func reveal(_ chart: DealChart, daykey: Int, dayOrdinalInYear: Int) -> Result<DealChart, Refusal> {
        var next = chart
        if let existing = next.deal(for: daykey) {
            guard existing.phase == .sealed else { return .failure(.revealRefused) }
        }
        guard let stub = stub(in: next.stock, dayOrdinalInYear: dayOrdinalInYear) else {
            return .failure(.emptyStock)
        }
        let deal = Deal(
            daykey: daykey,
            phase: .revealed,
            stubID: stub.id,
            word: stub.word,
            action: stub.action
        )
        next = filing(deal, into: next)
        return .success(next)
    }

    static func crease(_ chart: DealChart, daykey: Int, today: Int) -> Result<DealChart, Refusal> {
        guard daykey == today else { return .failure(.notToday) }
        guard let existing = chart.deal(for: daykey) else { return .failure(.creaseOnSealed) }
        guard existing.phase != .sealed else { return .failure(.creaseOnSealed) }
        guard existing.phase == .revealed else { return .failure(.alreadyFiled) }
        var next = chart
        var kept = existing
        kept.phase = .kept
        let mark = CreaseMark(
            id: "crease-\(daykey)",
            daykey: daykey,
            stubID: kept.stubID,
            word: kept.word,
            action: kept.action
        )
        next.creases.removeAll { $0.daykey == daykey }
        next.creases.append(mark)
        next = filing(kept, into: next)
        return .success(next)
    }

    static func pass(_ chart: DealChart, daykey: Int, today: Int) -> Result<DealChart, Refusal> {
        guard daykey == today else { return .failure(.notToday) }
        guard let existing = chart.deal(for: daykey) else { return .failure(.alreadyFiled) }
        switch existing.phase {
        case .kept, .passed:
            return .failure(.alreadyFiled)
        case .sealed, .revealed:
            break
        }
        var next = chart
        var filed = existing
        filed.phase = .passed
        next.passes.removeAll { $0.daykey == daykey }
        next.passes.append(Pass(id: "pass-\(daykey)", daykey: daykey))
        next = filing(filed, into: next)
        return .success(next)
    }

    /// Peels today's CreaseMark or Pass and returns Revealed. Other days stay filed.
    static func retract(_ chart: DealChart, daykey: Int, today: Int) -> Result<DealChart, Refusal> {
        guard daykey == today else { return .failure(.notToday) }
        guard let existing = chart.deal(for: daykey) else { return .failure(.nothingToRetract) }
        guard existing.phase == .kept || existing.phase == .passed else {
            return .failure(.nothingToRetract)
        }
        var next = chart
        var open = existing
        open.phase = .revealed
        next.creases.removeAll { $0.daykey == daykey }
        next.passes.removeAll { $0.daykey == daykey }
        next = filing(open, into: next)
        return .success(next)
    }

    /// Reconstructs a used year for the simulator seed. Past days are already filed.
    /// Today stays Revealed so the opening crease is still available.
    static func demoChart(from chart: DealChart, now: Date, calendar: Calendar) -> DealChart {
        var next = chart
        next.onboardingComplete = true
        let today = Daykey.int(from: now, calendar: calendar)
        for offset in 1...8 {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: calendar.startOfDay(for: now)) else {
                continue
            }
            let daykey = Daykey.int(from: date, calendar: calendar)
            let ordinal = Daykey.dayOrdinalInYear(for: date, calendar: calendar)
            guard case .success(let sealed) = sealedDeal(
                daykey: daykey,
                stock: next.stock,
                dayOrdinalInYear: ordinal
            ) else {
                continue
            }
            if offset % 2 == 0 {
                var kept = sealed
                kept.phase = .kept
                next.creases.removeAll { $0.daykey == daykey }
                next.creases.append(
                    CreaseMark(
                        id: "crease-\(daykey)",
                        daykey: daykey,
                        stubID: kept.stubID,
                        word: kept.word,
                        action: kept.action
                    )
                )
                next = filing(kept, into: next)
            } else {
                var passed = sealed
                passed.phase = .passed
                next.passes.removeAll { $0.daykey == daykey }
                next.passes.append(Pass(id: "pass-\(daykey)", daykey: daykey))
                next = filing(passed, into: next)
            }
        }
        let ordinal = Daykey.dayOrdinalInYear(for: now, calendar: calendar)
        if case .success(let revealed) = reveal(next, daykey: today, dayOrdinalInYear: ordinal) {
            next = revealed
        }
        return next
    }

    /// Running year for the wall. Filed days keep their phase. Unfiled days read Sealed
    /// and do not print the stub, so a future card is not shown early.
    static func yearWall(from chart: DealChart, now: Date, calendar: Calendar) -> [Deal] {
        let dayStart = calendar.startOfDay(for: now)
        let parts = calendar.dateComponents([.year], from: dayStart)
        guard let yearStart = calendar.date(from: parts),
              let dayCount = calendar.range(of: .day, in: .year, for: dayStart)
        else {
            return chart.year
        }
        var byKey: [Int: Deal] = [:]
        for deal in chart.year {
            byKey[deal.daykey] = deal
        }
        var wall: [Deal] = []
        wall.reserveCapacity(dayCount.count)
        for offset in 0..<dayCount.count {
            guard let date = calendar.date(byAdding: .day, value: offset, to: yearStart) else { continue }
            let daykey = Daykey.int(from: date, calendar: calendar)
            if let filed = byKey[daykey] {
                wall.append(filed)
                continue
            }
            let ordinal = Daykey.dayOrdinalInYear(for: date, calendar: calendar)
            guard case .success(var sealed) = sealedDeal(
                daykey: daykey,
                stock: chart.stock,
                dayOrdinalInYear: ordinal
            ) else {
                continue
            }
            sealed.word = "Sealed"
            sealed.action = ""
            wall.append(sealed)
        }
        return wall
    }

    private static func filing(_ deal: Deal, into chart: DealChart) -> DealChart {
        var next = chart
        if let index = next.year.firstIndex(where: { $0.daykey == deal.daykey }) {
            next.year[index] = deal
        } else {
            next.year.append(deal)
        }
        next.live = deal
        return next
    }
}
