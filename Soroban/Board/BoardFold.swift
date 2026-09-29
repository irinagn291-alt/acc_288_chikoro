import Foundation

/// Sum of the lantern fold. Bare has no lit bead. Lit is the stored phase.
/// Lapped names the tick that finished a circuit; the chart then stores Lit on the first counter.
enum BoardFold: Equatable, Sendable {
    case bare
    case lit(UUID)
    case lapped(UUID)

    var storedLitID: UUID? {
        switch self {
        case .bare:
            nil
        case .lit(let id), .lapped(let id):
            id
        }
    }
}

enum TickOutcome: Equatable, Sendable {
    case bareRefused
    case unknownRefused
    case darkRefused(MissMark)
    case accepted(TickMark, lap: LapMark?, fold: BoardFold)
}

enum UndoOutcome: Equatable, Sendable {
    case nothingToUndo
    case undone(UndoMark, fold: BoardFold)
}

enum SeatOutcome: Equatable, Sendable {
    case rejected
    case seated(Counter, fold: BoardFold)
}

/// Lantern-circuit fold over counters. Tick, miss, lap, undo, and day snap live here, not in a view.
extension BoardChart {
    var activeCounters: [Counter] {
        counters.filter { !$0.isArchived }
    }

    var activeIDs: [UUID] {
        activeCounters.map(\.id)
    }

    /// Stored phase. A completing tick reports `.lapped` from `tick`, then this returns `.lit` on the same id.
    var phase: BoardFold {
        if isBare { return .bare }
        guard let litCounterID, activeIDs.contains(litCounterID) else {
            guard let first = activeIDs.first else { return .bare }
            return .lit(first)
        }
        return .lit(litCounterID)
    }

    func tally(for counterID: UUID, dayKey: Int) -> Int {
        dayTallies.first { $0.counterID == counterID && $0.dayKey == dayKey }?.value ?? 0
    }

    /// value = max(0, value + delta). Never stores a negative tally.
    @discardableResult
    mutating func applyDelta(counterID: UUID, dayKey: Int, delta: Int) -> Int {
        let next = max(0, tally(for: counterID, dayKey: dayKey) + delta)
        if let index = dayTallies.firstIndex(where: { $0.counterID == counterID && $0.dayKey == dayKey }) {
            dayTallies[index].value = next
        } else if next != 0 || delta != 0 {
            dayTallies.append(DayTally(counterID: counterID, dayKey: dayKey, value: next))
        }
        return next
    }

    mutating func seat(name: String, id: UUID = UUID()) -> SeatOutcome {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .rejected }
        guard !counters.contains(where: { $0.id == id }) else { return .rejected }
        let counter = Counter(id: id, name: trimmed)
        let wasBare = activeIDs.isEmpty
        counters.append(counter)
        if wasBare {
            litCounterID = counter.id
        }
        return .seated(counter, fold: phase)
    }

    mutating func rename(id: UUID, to name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let index = counters.firstIndex(where: { $0.id == id }) else {
            return false
        }
        counters[index].name = trimmed
        return true
    }

    /// Library order changes. The lit counter id stays.
    mutating func move(_ id: UUID, to index: Int) {
        guard let from = counters.firstIndex(where: { $0.id == id }) else { return }
        let item = counters.remove(at: from)
        let dest = min(max(0, index), counters.count)
        counters.insert(item, at: dest)
    }

    /// Archiving the lit counter lights the next active counter, or folds Bare when none remain.
    @discardableResult
    mutating func archive(_ id: UUID) -> BoardFold {
        guard let index = counters.firstIndex(where: { $0.id == id }), !counters[index].isArchived else {
            return phase
        }
        counters[index].isArchived = true
        guard litCounterID == id else { return phase }
        let remainder = counters[(index + 1)...].first { !$0.isArchived }?.id ?? activeIDs.first
        litCounterID = remainder
        if litCounterID == nil {
            return .bare
        }
        return phase
    }

    /// A new calendar day starts today's tally at 0. Each closed non-zero tally is logged once as delta −old.
    mutating func closeElapsedDays(today: Int, now: Date) {
        let closable = dayTallies.filter { $0.dayKey < today && $0.value > 0 }
        for row in closable {
            let already = snapMarks.contains { $0.counterID == row.counterID && $0.dayKey == row.dayKey }
            if already { continue }
            snapMarks.append(
                SnapMark(counterID: row.counterID, dayKey: row.dayKey, delta: -row.value, createdAt: now)
            )
        }
    }

    mutating func tick(counterID: UUID, dayKey: Int, now: Date) -> TickOutcome {
        closeElapsedDays(today: dayKey, now: now)
        let active = activeIDs
        if active.isEmpty || litCounterID == nil {
            litCounterID = nil
            return .bareRefused
        }
        guard active.contains(counterID) else {
            return .unknownRefused
        }
        guard counterID == litCounterID else {
            let miss = MissMark(counterID: counterID, dayKey: dayKey, createdAt: now)
            missMarks.append(miss)
            return .darkRefused(miss)
        }
        applyDelta(counterID: counterID, dayKey: dayKey, delta: 1)
        let mark = TickMark(counterID: counterID, dayKey: dayKey, createdAt: now)
        tickMarks.append(mark)
        let step = Lantern(litCounterID: litCounterID).advanced(through: active)
        litCounterID = step.next
        if step.completedCircuit, let first = step.next {
            let lap = LapMark(tickID: mark.id, counterID: counterID, dayKey: dayKey, createdAt: now)
            lapMarks.append(lap)
            return .accepted(mark, lap: lap, fold: .lapped(first))
        }
        guard let next = step.next else {
            return .accepted(mark, lap: nil, fold: .bare)
        }
        return .accepted(mark, lap: nil, fold: .lit(next))
    }

    mutating func undoLastAccepted(dayKey today: Int, now: Date) -> UndoOutcome {
        closeElapsedDays(today: today, now: now)
        let undone = Set(undoMarks.map(\.tickID))
        guard let tick = tickMarks.last(where: { !undone.contains($0.id) }) else {
            return .nothingToUndo
        }
        applyDelta(counterID: tick.counterID, dayKey: tick.dayKey, delta: -1)
        let active = activeIDs
        if let litCounterID, active.contains(litCounterID) {
            self.litCounterID = Lantern(litCounterID: litCounterID).retreated(through: active)
        } else {
            litCounterID = tick.counterID
        }
        lapMarks.removeAll { $0.tickID == tick.id }
        let undo = UndoMark(tickID: tick.id, counterID: tick.counterID, dayKey: tick.dayKey, createdAt: now)
        undoMarks.append(undo)
        let fold: BoardFold = {
            guard let litCounterID else { return .bare }
            return .lit(litCounterID)
        }()
        return .undone(undo, fold: fold)
    }

    /// Every tap, lap, undo, and day snap, oldest first.
    func chronicle() -> [CountLog] {
        var rows: [CountLog] = []
        rows.reserveCapacity(tickMarks.count + missMarks.count + lapMarks.count + undoMarks.count + snapMarks.count)
        rows.append(contentsOf: tickMarks.map(CountLog.tick))
        rows.append(contentsOf: missMarks.map(CountLog.miss))
        rows.append(contentsOf: lapMarks.map(CountLog.lap))
        rows.append(contentsOf: undoMarks.map(CountLog.undo))
        rows.append(contentsOf: snapMarks.map(CountLog.snap))
        return rows.sorted { lhs, rhs in
            if lhs.createdAt != rhs.createdAt { return lhs.createdAt < rhs.createdAt }
            return lhs.id.uuidString < rhs.id.uuidString
        }
    }

    /// Simulator seed: Cups, Pages, Calls, Cups lit, one lap, marks on the previous day.
    static func demo(now: Date, calendar: Calendar) -> BoardChart {
        var chart = BoardChart.empty
        _ = chart.seat(name: "Cups", id: DemoBeads.cups)
        _ = chart.seat(name: "Pages", id: DemoBeads.pages)
        _ = chart.seat(name: "Calls", id: DemoBeads.calls)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now) ?? now
        let yesterdayKey = DayKey.make(from: yesterday, calendar: calendar)
        let beads = [DemoBeads.cups, DemoBeads.pages, DemoBeads.calls]
        for (offset, id) in beads.enumerated() {
            let stamp = yesterday.addingTimeInterval(Double(offset) * 60)
            _ = chart.tick(counterID: id, dayKey: yesterdayKey, now: stamp)
        }
        let todayKey = DayKey.make(from: now, calendar: calendar)
        chart.closeElapsedDays(today: todayKey, now: now)
        chart.onboardingComplete = true
        return chart
    }
}

enum DemoBeads {
    static let cups = uuid("10000000-0000-4000-8000-000000000001")
    static let pages = uuid("10000000-0000-4000-8000-000000000002")
    static let calls = uuid("10000000-0000-4000-8000-000000000003")

    private static func uuid(_ raw: String) -> UUID {
        UUID(uuidString: raw) ?? UUID(uuidString: "10000000-0000-4000-8000-000000000000") ?? UUID()
    }
}
