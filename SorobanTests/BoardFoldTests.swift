import XCTest
@testable import Soroban

final class BoardFoldTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }

    private func now() -> Date {
        Date(timeIntervalSince1970: 1_758_000_000)
    }

    /// value = max(0, value+δ). Every tap logged. Auto-reset snaps to 0 when the period elapses (log −old).
    /// The concept text says Watch, which collides with a desk. OLS and COSC are named here and do not drive this board.
    func testFamilyInvariantClampLogAndDaySnap() {
        var chart = BoardChart.empty
        _ = chart.seat(name: "Cups")
        let counter = chart.counters[0].id
        let today = DayKey.make(from: now(), calendar: calendar)
        let yesterday = DayKey.make(
            from: calendar.date(byAdding: .day, value: -1, to: now()) ?? now(),
            calendar: calendar
        )
        _ = chart.applyDelta(counterID: counter, dayKey: yesterday, delta: 4)
        XCTAssertEqual(chart.applyDelta(counterID: counter, dayKey: yesterday, delta: -10), 0)
        chart.dayTallies = [DayTally(counterID: counter, dayKey: yesterday, value: 4)]
        _ = chart.tick(counterID: counter, dayKey: today, now: now())
        XCTAssertEqual(chart.tally(for: counter, dayKey: today), 1)
        XCTAssertEqual(chart.tally(for: counter, dayKey: yesterday), 4)
        let snap = chart.snapMarks.first { $0.dayKey == yesterday }
        XCTAssertEqual(snap?.delta, -4)
        XCTAssertTrue(chart.chronicle().contains { row in
            if case .tick = row { return true }
            return false
        })
    }

    func testBareTickWritesNoMark() {
        var chart = BoardChart.empty
        let outcome = chart.tick(counterID: UUID(), dayKey: 20260926, now: now())
        XCTAssertEqual(outcome, .bareRefused)
        XCTAssertTrue(chart.tickMarks.isEmpty)
        XCTAssertTrue(chart.missMarks.isEmpty)
        XCTAssertEqual(chart.phase, .bare)
    }

    func testPopulatedTickAdvancesLantern() {
        var chart = seatedTrio()
        let outcome = chart.tick(counterID: DemoBeads.cups, dayKey: 20260926, now: now())
        guard case .accepted(let mark, let lap, let fold) = outcome else {
            return XCTFail("Expected an accepted tick")
        }
        XCTAssertNil(lap)
        XCTAssertEqual(fold, .lit(DemoBeads.pages))
        XCTAssertEqual(mark.counterID, DemoBeads.cups)
        XCTAssertEqual(chart.tally(for: DemoBeads.cups, dayKey: 20260926), 1)
        XCTAssertEqual(chart.litCounterID, DemoBeads.pages)
    }

    func testDarkBeadWritesMissAndKeepsLantern() {
        var chart = seatedTrio()
        _ = chart.tick(counterID: DemoBeads.cups, dayKey: 20260926, now: now())
        let miss = chart.tick(counterID: DemoBeads.cups, dayKey: 20260926, now: now().addingTimeInterval(1))
        guard case .darkRefused = miss else {
            return XCTFail("Expected a dark refusal")
        }
        XCTAssertEqual(chart.missMarks.count, 1)
        XCTAssertEqual(chart.tally(for: DemoBeads.cups, dayKey: 20260926), 1)
        XCTAssertEqual(chart.litCounterID, DemoBeads.pages)
        XCTAssertTrue(chart.chronicle().contains { row in
            if case .miss = row { return true }
            return false
        })
    }

    func testFullCircuitWritesLapAndStaysLitOnFirst() {
        var chart = seatedTrio()
        _ = chart.tick(counterID: DemoBeads.cups, dayKey: 20260926, now: now())
        _ = chart.tick(counterID: DemoBeads.pages, dayKey: 20260926, now: now().addingTimeInterval(1))
        let closing = chart.tick(counterID: DemoBeads.calls, dayKey: 20260926, now: now().addingTimeInterval(2))
        guard case .accepted(_, let lap, let fold) = closing else {
            return XCTFail("Expected the closing tick")
        }
        XCTAssertNotNil(lap)
        XCTAssertEqual(fold, .lapped(DemoBeads.cups))
        XCTAssertEqual(chart.phase, .lit(DemoBeads.cups))
        XCTAssertEqual(chart.lapMarks.count, 1)
        XCTAssertEqual(chart.tally(for: DemoBeads.calls, dayKey: 20260926), 1)
    }

    func testUndoStepsLanternBackAndDropsLap() {
        var chart = seatedTrio()
        _ = chart.tick(counterID: DemoBeads.cups, dayKey: 20260926, now: now())
        _ = chart.tick(counterID: DemoBeads.pages, dayKey: 20260926, now: now().addingTimeInterval(1))
        _ = chart.tick(counterID: DemoBeads.calls, dayKey: 20260926, now: now().addingTimeInterval(2))
        let undone = chart.undoLastAccepted(dayKey: 20260926, now: now().addingTimeInterval(3))
        guard case .undone = undone else {
            return XCTFail("Expected undo")
        }
        XCTAssertTrue(chart.lapMarks.isEmpty)
        XCTAssertEqual(chart.litCounterID, DemoBeads.calls)
        XCTAssertEqual(chart.tally(for: DemoBeads.calls, dayKey: 20260926), 0)
        XCTAssertEqual(chart.undoMarks.count, 1)
        XCTAssertEqual(chart.tickMarks.count, 3)
    }

    func testEmptyNameIsRejected() {
        var chart = BoardChart.empty
        XCTAssertEqual(chart.seat(name: "   "), .rejected)
        XCTAssertTrue(chart.counters.isEmpty)
    }

    func testArchiveLitFoldsToNextThenBare() {
        var chart = seatedTrio()
        XCTAssertEqual(chart.archive(DemoBeads.cups), .lit(DemoBeads.pages))
        XCTAssertEqual(chart.litCounterID, DemoBeads.pages)
        _ = chart.archive(DemoBeads.pages)
        _ = chart.archive(DemoBeads.calls)
        XCTAssertEqual(chart.phase, .bare)
        let outcome = chart.tick(counterID: DemoBeads.cups, dayKey: 20260926, now: now())
        XCTAssertEqual(outcome, .bareRefused)
    }

    func testReorderKeepsLitCounter() {
        var chart = seatedTrio()
        chart.move(DemoBeads.calls, to: 0)
        XCTAssertEqual(chart.litCounterID, DemoBeads.cups)
        XCTAssertEqual(chart.counters.map(\.id), [DemoBeads.calls, DemoBeads.cups, DemoBeads.pages])
    }

    func testDemoSeedLightsCupsWithOneLap() {
        let chart = BoardChart.demo(now: now(), calendar: calendar)
        XCTAssertEqual(chart.litCounterID, DemoBeads.cups)
        XCTAssertEqual(chart.counters.map(\.name), ["Cups", "Pages", "Calls"])
        XCTAssertEqual(chart.lapMarks.count, 1)
        XCTAssertTrue(chart.onboardingComplete)
        XCTAssertGreaterThanOrEqual(chart.tickMarks.count, 3)
        XCTAssertEqual(chart.snapMarks.count, 3)
        let today = DayKey.make(from: now(), calendar: calendar)
        XCTAssertEqual(chart.tally(for: DemoBeads.cups, dayKey: today), 0)
    }

    private func seatedTrio() -> BoardChart {
        var chart = BoardChart.empty
        _ = chart.seat(name: "Cups", id: DemoBeads.cups)
        _ = chart.seat(name: "Pages", id: DemoBeads.pages)
        _ = chart.seat(name: "Calls", id: DemoBeads.calls)
        return chart
    }
}
