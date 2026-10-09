import XCTest
@testable import Perforator

final class PerforatorTests: XCTestCase {
    private let stock: [Stock] = [
        Stock(id: "walk-out", word: "Walk", action: "Step outside for ten minutes."),
        Stock(id: "water-glass", word: "Water", action: "Drink one full glass of water."),
        Stock(id: "one-page", word: "Page", action: "Read one page already on the shelf.")
    ]

    func testLeafMatchesPoolAtDayOrdinalInYear() {
        let ordinal = 10
        let index = ordinal % stock.count
        let leaf = DealFold.stub(in: stock, dayOrdinalInYear: ordinal)
        XCTAssertEqual(leaf?.id, stock[index].id)
        XCTAssertEqual(
            DealFold.stockIndex(dayOrdinalInYear: ordinal, count: stock.count),
            DealFold.stockIndex(dayOrdinalInYear: ordinal + stock.count, count: stock.count)
        )
    }

    func testCreaseOnEmptyOrSealedIsRefused() {
        var chart = DealChart(stock: stock)
        let today = 20260927
        XCTAssertEqual(DealFold.crease(chart, daykey: today, today: today), .failure(.creaseOnSealed))
        chart = DealChart(
            stock: stock,
            year: [Deal(daykey: today, phase: .sealed, stubID: "walk-out", word: "Walk", action: "Step outside.")],
            live: Deal(daykey: today, phase: .sealed, stubID: "walk-out", word: "Walk", action: "Step outside.")
        )
        XCTAssertEqual(DealFold.crease(chart, daykey: today, today: today), .failure(.creaseOnSealed))
    }

    func testCreaseAfterRevealFilesMark() {
        let today = 20260927
        let ordinal = 2
        let sealed = DealFold.sealedDeal(daykey: today, stock: stock, dayOrdinalInYear: ordinal)
        guard case .success(let deal) = sealed else {
            XCTFail("stock missing")
            return
        }
        var chart = DealChart(stock: stock, year: [deal], live: deal)
        guard case .success(let revealed) = DealFold.reveal(chart, daykey: today, dayOrdinalInYear: ordinal) else {
            XCTFail("reveal")
            return
        }
        guard case .success(let creased) = DealFold.crease(revealed, daykey: today, today: today) else {
            XCTFail("crease")
            return
        }
        XCTAssertEqual(creased.live?.phase, .kept)
        XCTAssertEqual(creased.creases.count, 1)
        XCTAssertEqual(creased.creases.first?.action, stock[ordinal % stock.count].action)
        chart = creased
        XCTAssertEqual(DealFold.crease(chart, daykey: today, today: today), .failure(.alreadyFiled))
    }

    func testSecondRevealOnSameDaykeyIsRefusedAndPoolWraps() {
        let today = 20260927
        let ordinal = 1
        let deal = Deal(
            daykey: today,
            phase: .revealed,
            stubID: stock[1].id,
            word: stock[1].word,
            action: stock[1].action
        )
        let chart = DealChart(stock: stock, year: [deal], live: deal)
        XCTAssertEqual(DealFold.reveal(chart, daykey: today, dayOrdinalInYear: ordinal), .failure(.revealRefused))
        XCTAssertEqual(DealFold.stockIndex(dayOrdinalInYear: stock.count, count: stock.count), 0)
        XCTAssertEqual(DealFold.stub(in: stock, dayOrdinalInYear: stock.count)?.id, stock[0].id)
    }

    func testSameDayRetractReturnsRevealed() {
        let today = 20260927
        let deal = Deal(daykey: today, phase: .kept, stubID: "walk-out", word: "Walk", action: "Step outside.")
        let mark = CreaseMark(id: "crease-20260927", daykey: today, stubID: "walk-out", word: "Walk", action: "Step outside.")
        let chart = DealChart(stock: stock, year: [deal], live: deal, creases: [mark])
        guard case .success(let peeled) = DealFold.retract(chart, daykey: today, today: today) else {
            XCTFail("retract")
            return
        }
        XCTAssertEqual(peeled.live?.phase, .revealed)
        XCTAssertTrue(peeled.creases.isEmpty)
        XCTAssertEqual(DealFold.retract(peeled, daykey: today, today: 20260928), .failure(.notToday))
    }

    func testYearIsAFoldOfDeals() {
        let kept = Deal(daykey: 20260926, phase: .kept, stubID: "a", word: "Walk", action: "Go.")
        let passed = Deal(daykey: 20260927, phase: .passed, stubID: "b", word: "Water", action: "Drink.")
        let chart = DealChart(stock: stock, year: [kept, passed])
        XCTAssertEqual(chart.deal(for: 20260926)?.phase, .kept)
        XCTAssertEqual(chart.deal(for: 20260927)?.phase, .passed)
        XCTAssertNil(chart.deal(for: 20260101))
    }

    func testPersistenceRoundTripAndCorruptBackup() async {
        let name = "pfo.tests.\(UUID().uuidString)"
        let calendar = Calendar(identifier: .gregorian)
        let now = Date(timeIntervalSince1970: 1_758_931_200)
        let store = DealStore(suiteName: name)
        await store.load(stock: stock, now: now, calendar: calendar)
        let revealed = await store.reveal(now: now, calendar: calendar)
        guard case .success = revealed else {
            XCTFail("reveal")
            return
        }
        await store.flush()
        let creased = await store.crease(now: now, calendar: calendar)
        guard case .success(let deal) = creased else {
            XCTFail("crease")
            return
        }
        await store.flush()

        let reloaded = DealStore(suiteName: name)
        await reloaded.load(stock: stock, now: now, calendar: calendar)
        let snapshot = await reloaded.current()
        XCTAssertEqual(snapshot.creases.first?.daykey, deal.daykey)
        XCTAssertEqual(snapshot.live?.phase, .kept)
        XCTAssertEqual(snapshot.schemaVersion, 1)

        await store.overwriteChart(Data("not-json".utf8))
        await store.reload(stock: stock, now: now, calendar: calendar)
        let restored = await store.current()
        let restoredNote = await store.note()
        XCTAssertEqual(restored.live?.phase, .revealed)
        XCTAssertNotNil(restoredNote)

        await store.overwriteChart(Data("still-bad".utf8))
        await store.overwriteBackup(Data("also-bad".utf8))
        await store.reload(stock: stock, now: now, calendar: calendar)
        let sealedChart = await store.current()
        XCTAssertEqual(sealedChart.live?.phase, .sealed)

        await store.resetAllData(now: now, calendar: calendar)
        await store.reload(stock: stock, now: now, calendar: calendar)
        let resetChart = await store.current()
        XCTAssertTrue(resetChart.creases.isEmpty)
    }

    func testReviewLaunchParsesArguments() {
        XCTAssertEqual(ReviewLaunch.screen(in: ["Perforator", "-ReviewScreen", "today"]), "today")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Perforator", "-ReviewScreen", "log"]), "log")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Perforator", "-ReviewScreen", "goals"]), "goals")
        XCTAssertNil(ReviewLaunch.screen(in: ["Perforator"]))
        XCTAssertNil(ReviewLaunch.screen(in: ["Perforator", "-ReviewScreen"]))
    }

    func testPassLeavesNoCreaseAndDebouncedSaveCancels() async {
        let name = "pfo.tests.pass.\(UUID().uuidString)"
        let calendar = Calendar(identifier: .gregorian)
        let now = Date(timeIntervalSince1970: 1_758_931_200)
        let store = DealStore(suiteName: name)
        await store.load(stock: stock, now: now, calendar: calendar)
        _ = await store.reveal(now: now, calendar: calendar)
        guard case .success(let passed) = await store.pass(now: now, calendar: calendar) else {
            XCTFail("pass")
            return
        }
        XCTAssertEqual(passed.phase, .passed)
        let afterPass = await store.current()
        XCTAssertTrue(afterPass.creases.isEmpty)
        XCTAssertEqual(afterPass.passes.count, 1)
        await store.flush()
        let filed = await store.current()
        XCTAssertEqual(filed.passes.count, 1)
    }
}
