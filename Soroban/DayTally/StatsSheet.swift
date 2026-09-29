import SwiftUI

/// Totals index. TickMarks, LapMarks, and each counter by daykey. Not a goal program.
struct StatsSheet: View {
    var store: BoardStore
    @Environment(\.dismiss) private var dismiss
    @State private var hapticTick = 0
    @State private var openDay: Int?

    var body: some View {
        NavigationStack {
            Group {
                if let notice = store.loadNotice {
                    BoardNotice(store: store, title: "Stats unreadable.", detail: notice)
                } else if store.chart.tickMarks.isEmpty && store.chart.lapMarks.isEmpty && store.chart.dayTallies.isEmpty {
                    empty
                } else if let day = openDay {
                    dayPage(day)
                } else {
                    populated
                }
            }
            .sheetTitle("Stats")
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
            Text("Stats empty.")
                .font(BoardType.title)
                .foregroundStyle(BoardColor.ink)
            Text("Tick the lit seat. Totals land here.")
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
        VStack(alignment: .leading, spacing: BoardMetrics.unit * 2) {
            Text("Seat counts")
                .font(BoardType.title)
                .foregroundStyle(BoardColor.ink)
                .lineLimit(2)
            Text("Open a day, or tick the lit seat.")
                .font(BoardType.body)
                .foregroundStyle(BoardColor.ink)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 0) {
                measure("Ticks", store.chart.tickMarks.count)
                Rectangle()
                    .fill(BoardColor.muted)
                    .frame(width: BoardMetrics.hairline)
                measure("Laps", store.chart.lapMarks.count)
            }
            .frame(maxWidth: .infinity, minHeight: BoardMetrics.hit)
            .modifier(HairlinePlate())

            ForEach(store.chart.counters) { counter in
                seatButton(counter)
            }

            Button("Tick the lit seat") {
                dismiss()
            }
            .buttonStyle(GlassButtonStyle())
            .frame(maxWidth: .infinity, minHeight: BoardMetrics.hit)
            .accessibilityHint("Returns to the lit seat.")
        }
        .padding(BoardMetrics.unit * 2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(BoardColor.background)
    }

    private func seatButton(_ counter: Counter) -> some View {
        let rows = store.chart.dayTallies
            .filter { $0.counterID == counter.id }
            .sorted { $0.dayKey > $1.dayKey }
        let latest = rows.first
        let day = latest?.dayKey
        let value = latest?.value ?? 0
        let lit = store.chart.phase.storedLitID == counter.id
        return Button {
            if let day {
                openDay = day
            }
        } label: {
            VStack(alignment: .leading, spacing: BoardMetrics.unit) {
                HStack(alignment: .firstTextBaseline) {
                    Text(counter.name)
                        .font(BoardType.headline)
                        .foregroundStyle(BoardColor.ink)
                        .lineLimit(1)
                    Spacer(minLength: BoardMetrics.unit)
                    Text(BoardFormat.tally(value))
                        .font(BoardType.headline)
                        .monospacedDigit()
                        .foregroundStyle(BoardColor.accent)
                        .lineLimit(1)
                }
                Text(lit ? "Lit seat" : "Dark seat")
                    .font(BoardType.caption)
                    .foregroundStyle(lit ? BoardColor.ink : BoardColor.muted)
                    .lineLimit(1)
                Text(openCaption(day))
                    .font(BoardType.body)
                    .foregroundStyle(BoardColor.ink)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(BoardMetrics.unit * 2)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(IndexPressStyle())
        .disabled(day == nil)
        .modifier(HairlinePlate())
        .accessibilityLabel("\(counter.name), \(BoardFormat.tally(value)). Open this day.")
    }

    private func dayPage(_ day: Int) -> some View {
        let rows = store.chart.dayTallies.filter { $0.dayKey == day }
        let marks = store.chart.chronicle().filter { $0.dayKey == day }
        return VStack(alignment: .leading, spacing: BoardMetrics.unit * 2) {
            Text(BoardFormat.dayLabel(day))
                .font(BoardType.title)
                .foregroundStyle(BoardColor.ink)
                .lineLimit(2)
            Text("Seat counts for this day.")
                .font(BoardType.body)
                .foregroundStyle(BoardColor.ink)
                .lineLimit(2)

            ForEach(store.chart.counters) { counter in
                let value = rows.first { $0.counterID == counter.id }?.value ?? 0
                HStack {
                    Text(counter.name)
                        .font(BoardType.headline)
                        .foregroundStyle(BoardColor.ink)
                        .lineLimit(1)
                    Spacer(minLength: BoardMetrics.unit)
                    Text(BoardFormat.tally(value))
                        .font(BoardType.headline)
                        .monospacedDigit()
                        .foregroundStyle(BoardColor.accent)
                        .lineLimit(1)
                }
                .padding(BoardMetrics.unit * 2)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .modifier(HairlinePlate())
            }

            if !marks.isEmpty {
                Text(marks.map(markLine).joined(separator: "\n"))
                    .font(BoardType.body)
                    .foregroundStyle(BoardColor.ink)
                    .lineLimit(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(BoardMetrics.unit * 2)
                    .modifier(HairlinePlate())
            }

            Button("Seat counts") { openDay = nil }
                .buttonStyle(IndexPressStyle())
                .frame(maxWidth: .infinity, minHeight: BoardMetrics.hit)
                .contentShape(Rectangle())

            Button("Tick the lit seat") { dismiss() }
                .buttonStyle(GlassButtonStyle())
                .frame(maxWidth: .infinity, minHeight: BoardMetrics.hit)
        }
        .padding(BoardMetrics.unit * 2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(BoardColor.background)
    }

    private func openCaption(_ day: Int?) -> String {
        guard let day else { return "No day yet" }
        return "Open \(BoardFormat.dayLabel(day))"
    }

    private func measure(_ title: String, _ value: Int) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(BoardType.caption)
                .foregroundStyle(BoardColor.muted)
                .lineLimit(1)
            Text(BoardFormat.tally(value))
                .font(BoardType.headline)
                .monospacedDigit()
                .foregroundStyle(BoardColor.accent)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, BoardMetrics.unit * 2)
        .padding(.vertical, BoardMetrics.unit)
    }

    private func markLine(_ row: CountLog) -> String {
        let name = store.chart.counters.first { $0.id == row.counterID }?.name ?? "Seat"
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

/// Stats destination. Totals index, not a goal program.
struct StatsIndex: View {
    var store: BoardStore

    var body: some View {
        StatsSheet(store: store)
    }
}
