import SwiftUI

/// History sheet. Scrub prior daykeys and list that day's marks.
struct HistorySheet: View {
    var store: BoardStore
    @State private var index = 0
    @State private var hapticTick = 0

    private var keys: [Int] {
        let logged = store.chart.chronicle().map(\.dayKey)
        let tallies = store.chart.dayTallies.map(\.dayKey)
        let today = DayKey.make(from: .now, calendar: .current)
        return Array(Set(logged + tallies + [today])).sorted(by: >)
    }

    var body: some View {
        NavigationStack {
            Group {
                if let notice = store.loadNotice {
                    BoardNotice(store: store, title: "History unreadable.", detail: notice)
                } else if store.chart.chronicle().isEmpty {
                    empty
                } else {
                    populated
                }
            }
            .sheetTitle("History")
            .background(BoardColor.background)
            .sensoryFeedback(.impact(weight: .medium), trigger: hapticTick)
        }
        .modifier(SheetArrival())
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: BoardMetrics.unit * 2) {
            Image("srb_EmptyList")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: BoardMetrics.rowHeight * 2)
                .clipped()
                .accessibilityHidden(true)
            Text("History empty.")
                .font(BoardType.title)
                .foregroundStyle(BoardColor.ink)
            Text("Marks for each day land here.")
                .font(BoardType.body)
                .foregroundStyle(BoardColor.muted)
            Spacer(minLength: 0)
            Button(store.chart.activeCounters.isEmpty ? BoardCopy.addCounter : "Tick the lit seat") {
                commitLit()
            }
            .buttonStyle(GlassButtonStyle())
            .frame(maxWidth: .infinity, minHeight: BoardMetrics.hit)
        }
        .padding(BoardMetrics.unit * 2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var populated: some View {
        let key = keys[min(index, max(keys.count - 1, 0))]
        let rows = store.chart.chronicle().filter { $0.dayKey == key }
        return VStack(alignment: .leading, spacing: BoardMetrics.unit * 2) {
            dayScrubber(key: key)
            if rows.isEmpty {
                emptyDay(key: key)
            } else {
                markPage(rows)
            }
        }
        .padding(BoardMetrics.unit * 2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(BoardColor.background)
    }

    private func dayScrubber(key: Int) -> some View {
        VStack(alignment: .leading, spacing: BoardMetrics.unit) {
            VStack(alignment: .leading, spacing: 0) {
                Text(BoardFormat.dayNumber(key))
                    .font(BoardType.title)
                    .foregroundStyle(BoardColor.accent)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(BoardFormat.monthYear(key))
                    .font(BoardType.headline)
                    .foregroundStyle(BoardColor.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(BoardMetrics.unit * 2)
            .frame(maxWidth: .infinity, minHeight: BoardMetrics.hit, alignment: .leading)
            .modifier(HairlinePlate())
            HStack(spacing: BoardMetrics.unit) {
                dayStep("Earlier", enabled: canStepEarlier, action: stepEarlier)
                dayStep("Later", enabled: canStepLater, action: stepLater)
            }
        }
    }

    private func dayStep(_ title: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .buttonStyle(IndexPressStyle())
            .font(BoardType.body)
            .foregroundStyle(BoardColor.ink)
            .frame(maxWidth: .infinity, minHeight: BoardMetrics.hit)
            .contentShape(Rectangle())
            .modifier(HairlinePlate())
            .disabled(!enabled)
            .opacity(enabled ? 1 : 0.45)
    }

    private func markPage(_ rows: [CountLog]) -> some View {
        GeometryReader { geo in
            let rowHeight = max(BoardMetrics.rowHeight, geo.size.height / CGFloat(rows.count))
            VStack(spacing: BoardMetrics.unit) {
                ForEach(rows) { row in
                    Text(line(row))
                        .font(BoardType.headline)
                        .foregroundStyle(BoardColor.ink)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, minHeight: rowHeight, alignment: .leading)
                        .padding(.horizontal, BoardMetrics.unit * 2)
                        .modifier(HairlinePlate())
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func emptyDay(key: Int) -> some View {
        let seats = store.chart.activeCounters
        return VStack(alignment: .leading, spacing: BoardMetrics.unit * 2) {
            Text("This day's marks")
                .font(BoardType.title)
                .foregroundStyle(BoardColor.ink)
                .lineLimit(2)
            Text("No marks on this day.")
                .font(BoardType.body)
                .foregroundStyle(BoardColor.ink)
                .lineLimit(2)
            Text(canStepEarlier
                 ? "Tap Earlier to open the day that has ticks."
                 : "Tick the lit seat to file the first mark.")
                .font(BoardType.body)
                .foregroundStyle(BoardColor.muted)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            if seats.isEmpty {
                Text(BoardCopy.addThenTick)
                    .font(BoardType.body)
                    .foregroundStyle(BoardColor.ink)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(BoardMetrics.unit * 2)
                    .modifier(HairlinePlate())
            } else {
                GeometryReader { geo in
                    let rowHeight = max(BoardMetrics.hit, geo.size.height / CGFloat(seats.count))
                    VStack(spacing: BoardMetrics.unit) {
                        ForEach(seats) { counter in
                            HStack {
                                Text(counter.name)
                                    .font(BoardType.headline)
                                    .foregroundStyle(BoardColor.ink)
                                    .lineLimit(1)
                                Spacer(minLength: BoardMetrics.unit)
                                Text("0")
                                    .font(BoardType.headline)
                                    .monospacedDigit()
                                    .foregroundStyle(BoardColor.accent)
                            }
                            .padding(.horizontal, BoardMetrics.unit * 2)
                            .frame(maxWidth: .infinity, minHeight: rowHeight, alignment: .leading)
                            .modifier(HairlinePlate())
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            Button(canStepEarlier ? "Earlier" : "Tick the lit seat") {
                if canStepEarlier {
                    stepEarlier()
                } else {
                    commitLit()
                }
            }
            .buttonStyle(GlassButtonStyle())
            .frame(maxWidth: .infinity, minHeight: BoardMetrics.hit)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var canStepEarlier: Bool {
        index < keys.count - 1
    }

    private var canStepLater: Bool {
        index > 0
    }

    private func stepEarlier() {
        index = min(index + 1, max(keys.count - 1, 0))
    }

    private func stepLater() {
        index = max(index - 1, 0)
    }

    private func line(_ row: CountLog) -> String {
        let name = store.chart.counters.first { $0.id == row.counterID }?.name ?? "Row"
        switch row {
        case .tick:
            return "Tick \(name)."
        case .miss:
            return "Miss \(name)."
        case .lap:
            return "Lap filed."
        case .undo:
            return "Undo \(name)."
        case .snap:
            return "Day closed \(name)."
        }
    }

    private func commitLit() {
        if store.chart.activeCounters.isEmpty {
            _ = store.seat(name: "Cups")
        }
        guard let id = store.chart.phase.storedLitID else { return }
        if case .accepted = store.tick(counterID: id) {
            hapticTick += 1
        }
    }
}

/// History destination. Prior day marks, not a second home.
struct HistoryIndex: View {
    var store: BoardStore

    var body: some View {
        HistorySheet(store: store)
    }
}

extension CountLog {
    var dayKey: Int {
        switch self {
        case .tick(let mark): mark.dayKey
        case .miss(let mark): mark.dayKey
        case .lap(let mark): mark.dayKey
        case .undo(let mark): mark.dayKey
        case .snap(let mark): mark.dayKey
        }
    }

    var counterID: UUID {
        switch self {
        case .tick(let mark): mark.counterID
        case .miss(let mark): mark.counterID
        case .lap(let mark): mark.counterID
        case .undo(let mark): mark.counterID
        case .snap(let mark): mark.counterID
        }
    }
}
