import Foundation

/// Disk projection of `BoardChart`. UserDefaults holds one JSON blob per key.
/// The actor keeps that work off the main thread. A failed write leaves memory unchanged.
actor ChartVault {
    static let primaryKey = "srb.board.v1"
    static let backupKey = "srb.board.v1.bak"
    static let demoKey = "srb.demo.v1"

    private let defaults: UserDefaults

    init(suiteName: String?) {
        if let suiteName, let suite = UserDefaults(suiteName: suiteName) {
            defaults = suite
        } else {
            defaults = .standard
        }
    }

    func load() -> (chart: BoardChart, notice: String?) {
        let primary = defaults.data(forKey: Self.primaryKey)
        if let primary, let chart = Self.decode(primary) {
            return (chart, nil)
        }
        let backup = defaults.data(forKey: Self.backupKey)
        if let backup, let chart = Self.decode(backup) {
            defaults.set(backup, forKey: Self.primaryKey)
            return (chart, "Board restored from the backup.")
        }
        if primary != nil || backup != nil {
            return (.empty, "Board unreadable. Started a bare board.")
        }
        return (.empty, nil)
    }

    /// Copies the previous JSON to the backup key, then replaces the primary key.
    func replace(_ chart: BoardChart) {
        guard let data = Self.encode(chart) else { return }
        if let previous = defaults.data(forKey: Self.primaryKey) {
            defaults.set(previous, forKey: Self.backupKey)
        }
        defaults.set(data, forKey: Self.primaryKey)
    }

    func reset() {
        defaults.removeObject(forKey: Self.primaryKey)
        defaults.removeObject(forKey: Self.backupKey)
    }

    func demoAlreadySeeded() -> Bool {
        defaults.bool(forKey: Self.demoKey)
    }

    func markDemoSeeded() {
        defaults.set(true, forKey: Self.demoKey)
    }

    private static func encode(_ chart: BoardChart) -> Data? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .useDefaultKeys
        encoder.dateEncodingStrategy = .secondsSince1970
        do {
            return try encoder.encode(chart)
        } catch {
            return nil
        }
    }

    private static func decode(_ data: Data) -> BoardChart? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        decoder.dateDecodingStrategy = .secondsSince1970
        return try? decoder.decode(BoardChart.self, from: data)
    }
}

/// Seam between the lantern fold and storage. Views talk only to this type.
@MainActor
@Observable
final class BoardStore {
    private(set) var chart: BoardChart
    private(set) var loadNotice: String?
    private let vault: ChartVault
    private var saveTask: Task<Void, Never>?
    private var generation = 0
    var saveDelayNanoseconds: UInt64 = 400_000_000

    init(chart: BoardChart, notice: String?, vault: ChartVault) {
        self.chart = chart
        self.loadNotice = notice
        self.vault = vault
    }

    nonisolated static func open(suiteName: String? = nil) async -> BoardStore {
        let vault = ChartVault(suiteName: suiteName)
        let loaded = await vault.load()
        return await BoardStore(chart: loaded.chart, notice: loaded.notice, vault: vault)
    }

    func seat(name: String, id: UUID = UUID()) -> SeatOutcome {
        var next = chart
        let outcome = next.seat(name: name, id: id)
        commit(next, outcome: outcome)
        return outcome
    }

    func rename(id: UUID, to name: String) -> Bool {
        var next = chart
        let changed = next.rename(id: id, to: name)
        if changed { commit(next, changed: true) }
        return changed
    }

    func move(_ id: UUID, to index: Int) {
        var next = chart
        next.move(id, to: index)
        commit(next, changed: next != chart)
    }

    func archive(_ id: UUID) -> BoardFold {
        var next = chart
        let fold = next.archive(id)
        commit(next, changed: next != chart)
        return fold
    }

    func tick(counterID: UUID, now: Date = .now, calendar: Calendar = .current) -> TickOutcome {
        let dayKey = DayKey.make(from: now, calendar: calendar)
        var next = chart
        let outcome = next.tick(counterID: counterID, dayKey: dayKey, now: now)
        let persist: Bool
        switch outcome {
        case .bareRefused, .unknownRefused:
            persist = next != chart
        case .darkRefused, .accepted:
            persist = true
        }
        commit(next, changed: persist)
        return outcome
    }

    func undoLastAccepted(now: Date = .now, calendar: Calendar = .current) -> UndoOutcome {
        let dayKey = DayKey.make(from: now, calendar: calendar)
        var next = chart
        let outcome = next.undoLastAccepted(dayKey: dayKey, now: now)
        commit(next, changed: next != chart)
        return outcome
    }

    func clearLoadNotice() {
        loadNotice = nil
    }

    /// Debounce about 400ms after the last mark. A newer edit cancels the in-flight save.
    func scheduleSave() {
        generation += 1
        let token = generation
        saveTask?.cancel()
        let delay = saveDelayNanoseconds
        saveTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: delay)
            guard !Task.isCancelled else { return }
            await self?.flushNow(expected: token)
        }
    }

    /// scenePhase inactive or background, and any destructive action, flush immediately.
    func flushOnLeaveForeground() async {
        saveTask?.cancel()
        await flushNow(expected: nil)
    }

    func flushNow() async {
        saveTask?.cancel()
        await flushNow(expected: nil)
    }

    func resetAllData() async {
        saveTask?.cancel()
        generation += 1
        chart = .empty
        loadNotice = nil
        await vault.reset()
    }

    /// Runs once on Simulator behind srb.demo.v1. Never compiled onto a device launch path.
    func installSimulatorSeedIfNeeded(now: Date = .now, calendar: Calendar = .current) async {
        #if targetEnvironment(simulator)
        if await vault.demoAlreadySeeded() { return }
        guard chart == .empty else {
            await vault.markDemoSeeded()
            return
        }
        chart = BoardChart.demo(now: now, calendar: calendar)
        await flushNow()
        await vault.markDemoSeeded()
        #else
        _ = now
        _ = calendar
        #endif
    }

    /// Skip and finish both seat Cups, Pages, and Calls and light Cups so Tick can land.
    func completeOnboarding() {
        var next = chart
        let seeds: [(UUID, String)] = [
            (DemoBeads.cups, "Cups"),
            (DemoBeads.pages, "Pages"),
            (DemoBeads.calls, "Calls"),
        ]
        for (id, name) in seeds {
            if let index = next.counters.firstIndex(where: { $0.id == id }) {
                next.counters[index].isArchived = false
                next.counters[index].name = name
            } else if next.counters.contains(where: { $0.name == name && !$0.isArchived }) {
                continue
            } else {
                _ = next.seat(name: name, id: id)
            }
        }
        if next.activeIDs.contains(DemoBeads.cups) {
            next.litCounterID = DemoBeads.cups
        } else if let cups = next.activeCounters.first(where: { $0.name == "Cups" }) {
            next.litCounterID = cups.id
        }
        next.onboardingComplete = true
        commit(next, changed: true)
    }

    private func commit(_ next: BoardChart, outcome: SeatOutcome) {
        guard case .seated = outcome else { return }
        chart = next
        scheduleSave()
    }

    private func commit(_ next: BoardChart, changed: Bool) {
        guard changed else { return }
        chart = next
        scheduleSave()
    }

    private func flushNow(expected token: Int?) async {
        if let token, token != generation { return }
        while true {
            let stamp = generation
            let snapshot = chart
            await vault.replace(snapshot)
            if stamp == generation { return }
        }
    }
}
