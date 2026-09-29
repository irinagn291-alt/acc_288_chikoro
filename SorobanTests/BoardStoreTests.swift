import XCTest
@testable import Soroban

@MainActor
final class BoardStoreTests: XCTestCase {
    private func suite() -> (UserDefaults, String) {
        let name = "soroban.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name) ?? .standard
        defaults.removePersistentDomain(forName: name)
        return (defaults, name)
    }

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }

    func testRoundTripReload() async {
        let (_, name) = suite()
        let store = await BoardStore.open(suiteName: name)
        _ = store.seat(name: "Cups", id: DemoBeads.cups)
        _ = store.tick(counterID: DemoBeads.cups, now: Date(timeIntervalSince1970: 1_758_000_000), calendar: calendar)
        await store.flushNow()
        let reloaded = await BoardStore.open(suiteName: name)
        XCTAssertEqual(reloaded.chart.counters.map(\.name), ["Cups"])
        XCTAssertEqual(reloaded.chart.tickMarks.count, 1)
        XCTAssertEqual(reloaded.chart.schemaVersion, 1)
        XCTAssertNil(reloaded.loadNotice)
    }

    func testCorruptPrimaryRestoresBackupThenEmpty() async {
        let (defaults, name) = suite()
        let store = await BoardStore.open(suiteName: name)
        _ = store.seat(name: "Cups", id: DemoBeads.cups)
        await store.flushNow()
        _ = store.seat(name: "Pages", id: DemoBeads.pages)
        await store.flushNow()
        defaults.set(Data("not-json".utf8), forKey: ChartVault.primaryKey)
        let restored = await BoardStore.open(suiteName: name)
        XCTAssertEqual(restored.chart.counters.map(\.name), ["Cups"])
        XCTAssertEqual(restored.loadNotice, "Board restored from the backup.")

        defaults.set(Data("also-bad".utf8), forKey: ChartVault.primaryKey)
        defaults.set(Data("backup-bad".utf8), forKey: ChartVault.backupKey)
        let bare = await BoardStore.open(suiteName: name)
        XCTAssertEqual(bare.chart, .empty)
        XCTAssertEqual(bare.loadNotice, "Board unreadable. Started a bare board.")
    }

    func testResetDeletesBothKeys() async {
        let (defaults, name) = suite()
        let store = await BoardStore.open(suiteName: name)
        _ = store.seat(name: "Cups")
        await store.flushNow()
        await store.resetAllData()
        XCTAssertNil(defaults.data(forKey: ChartVault.primaryKey))
        XCTAssertNil(defaults.data(forKey: ChartVault.backupKey))
        XCTAssertEqual(store.chart, .empty)
        let reloaded = await BoardStore.open(suiteName: name)
        XCTAssertEqual(reloaded.chart, .empty)
        XCTAssertNil(reloaded.loadNotice)
    }

    func testSchemaSwitchRejectsUnknownVersion() throws {
        let chart = BoardChart.demo(now: Date(timeIntervalSince1970: 1_758_000_000), calendar: calendar)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        var object = try JSONSerialization.jsonObject(with: try encoder.encode(chart)) as? [String: Any]
        XCTAssertNotNil(object)
        object?["schemaVersion"] = 9
        let data = try JSONSerialization.data(withJSONObject: object ?? [:])
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        decoder.dateDecodingStrategy = .secondsSince1970
        XCTAssertThrowsError(try decoder.decode(BoardChart.self, from: data))
    }

    func testSimulatorSeedRunsOnce() async {
        let (defaults, name) = suite()
        let store = await BoardStore.open(suiteName: name)
        let now = Date(timeIntervalSince1970: 1_758_000_000)
        await store.installSimulatorSeedIfNeeded(now: now, calendar: calendar)
        #if targetEnvironment(simulator)
        XCTAssertEqual(store.chart.litCounterID, DemoBeads.cups)
        XCTAssertTrue(store.chart.onboardingComplete)
        XCTAssertTrue(defaults.bool(forKey: ChartVault.demoKey))
        let lapCount = store.chart.lapMarks.count
        await store.installSimulatorSeedIfNeeded(now: now, calendar: calendar)
        XCTAssertEqual(store.chart.lapMarks.count, lapCount)
        XCTAssertEqual(store.chart.litCounterID, DemoBeads.cups)
        #else
        XCTAssertEqual(store.chart, .empty)
        #endif
    }

    func testLeaveForegroundFlushesWithoutWaiting() async {
        let (_, name) = suite()
        let store = await BoardStore.open(suiteName: name)
        store.saveDelayNanoseconds = 5_000_000_000
        _ = store.seat(name: "Calls", id: DemoBeads.calls)
        await store.flushOnLeaveForeground()
        let reloaded = await BoardStore.open(suiteName: name)
        XCTAssertEqual(reloaded.chart.counters.map(\.name), ["Calls"])
    }
}
