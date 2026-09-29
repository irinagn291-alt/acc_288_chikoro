import SwiftUI

/// Home. The lantern circuit stays on this screen. Library, Stats, History, and Settings are sheets.
struct BoardScreen: View {
    var store: BoardStore
    @Binding var sheet: BoardSheet?
    @State private var status = "Bead lit."
    @State private var hapticTick = 0
    @Environment(\.dynamicTypeSize) private var typeSize
    @ScaledMetric(relativeTo: .largeTitle) private var displayCap: CGFloat = 44

    private var active: [Counter] {
        store.chart.activeCounters
    }

    private var litID: UUID? {
        store.chart.phase.storedLitID
    }

    private var displayFont: Font {
        if typeSize >= .accessibility3 || displayCap > 64 {
            return BoardType.title
        }
        if displayCap > 52 {
            return BoardType.headline
        }
        return BoardType.display
    }

    var body: some View {
        TimelineView(.everyMinute) { context in
            let dayKey = DayKey.make(from: context.date, calendar: .current)
            Group {
                if store.loadNotice != nil {
                    BoardNotice(store: store, title: "Board unreadable.", detail: store.loadNotice ?? "")
                } else if active.isEmpty {
                    barePage
                } else {
                    populated(dayKey: dayKey)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BoardColor.background)
        .sensoryFeedback(.impact(weight: .medium), trigger: hapticTick)
    }

    private var barePage: some View {
        VStack(alignment: .leading, spacing: BoardMetrics.unit * 2) {
            chrome
            Image("srb_EmptyHome")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: BoardMetrics.rowHeight * 3)
                .clipped()
                .accessibilityHidden(true)
            Text("Board bare.")
                .font(BoardType.title)
                .foregroundStyle(BoardColor.ink)
                .lineLimit(2)
            Text(BoardCopy.bareDetail)
                .font(BoardType.body)
                .foregroundStyle(BoardColor.muted)
                .lineSpacing(BoardMetrics.unit)
                .lineLimit(3)
            Spacer(minLength: 0)
            Button(BoardCopy.addCounter) { sheet = .library }
                .buttonStyle(GlassButtonStyle())
                .frame(maxWidth: .infinity, minHeight: BoardMetrics.hit)
        }
        .padding(BoardMetrics.unit * 2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func populated(dayKey: Int) -> some View {
        VStack(alignment: .leading, spacing: BoardMetrics.unit * 2) {
            chrome
            if let lit = active.first(where: { $0.id == litID }) {
                displayPlate(lit.name)
            }
            index(dayKey: dayKey)
            measureStrip(dayKey: dayKey)
            undoBar
        }
        .padding(BoardMetrics.unit * 2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func displayPlate(_ name: String) -> some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: BoardMetrics.unit) {
                Text(name)
                    .font(displayFont)
                    .foregroundStyle(BoardColor.ink)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Rectangle()
                    .fill(BoardColor.muted)
                    .frame(height: BoardMetrics.hairline)
                Text("Counts today. Tick the lit seat.")
                    .font(BoardType.body)
                    .foregroundStyle(BoardColor.ink)
                    .lineSpacing(BoardMetrics.unit)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                Text(status)
                    .font(BoardType.caption)
                    .foregroundStyle(BoardColor.muted)
                    .lineLimit(3)
            }
            .padding(BoardMetrics.unit * 2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(BoardColor.surface)
            .layoutPriority(1)

            Image("srb_HeaderDecor")
                .resizable()
                .scaledToFit()
                .frame(width: BoardMetrics.beadColumn * 2, height: BoardMetrics.rowHeight * 2)
                .padding(BoardMetrics.unit)
                .frame(maxHeight: .infinity)
                .background {
                    Image("srb_CardBackdrop")
                        .resizable()
                        .scaledToFill()
                        .accessibilityHidden(true)
                }
                .clipped()
                .accessibilityHidden(true)
        }
        .fixedSize(horizontal: false, vertical: true)
        .clipShape(RoundedRectangle(cornerRadius: BoardMetrics.cardRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: BoardMetrics.cardRadius, style: .continuous)
                .strokeBorder(BoardColor.muted, lineWidth: BoardMetrics.hairline)
        }
    }

    private func index(dayKey: Int) -> some View {
        GeometryReader { geo in
            let count = CGFloat(max(active.count, 1))
            let rowHeight = max(BoardMetrics.rowHeight, geo.size.height / count)
            ScrollView {
                ZStack(alignment: .topLeading) {
                    BeadRod(count: active.count, litIndex: litRow, rowHeight: rowHeight)
                        .frame(width: BoardMetrics.beadColumn, height: rowHeight * CGFloat(active.count))
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                    VStack(spacing: 0) {
                        ForEach(active) { counter in
                            beadRow(counter, dayKey: dayKey, rowHeight: rowHeight)
                        }
                    }
                }
                .frame(minHeight: geo.size.height, alignment: .top)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var litRow: Int {
        active.firstIndex(where: { $0.id == litID }) ?? -1
    }

    private func beadRow(_ counter: Counter, dayKey: Int, rowHeight: CGFloat) -> some View {
        let lit = counter.id == litID
        let tally = store.chart.tally(for: counter.id, dayKey: dayKey)
        return Button {
            apply(store.tick(counterID: counter.id))
        } label: {
            HStack(spacing: 0) {
                Color.clear
                    .frame(width: BoardMetrics.beadColumn, height: rowHeight)
                HStack(spacing: BoardMetrics.unit) {
                    VStack(alignment: .leading, spacing: BoardMetrics.unit) {
                        Text(counter.name)
                            .font(BoardType.headline)
                            .foregroundStyle(lit ? BoardColor.accent : BoardColor.ink)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        Text(lit ? "Lit" : "Dark")
                            .font(BoardType.caption)
                            .foregroundStyle(lit ? BoardColor.ink : BoardColor.muted)
                            .padding(.horizontal, BoardMetrics.unit)
                            .background(
                                RoundedRectangle(cornerRadius: BoardMetrics.chipRadius, style: .continuous)
                                    .fill(lit ? BoardColor.accent.opacity(0.28) : BoardColor.surface)
                            )
                    }
                    Spacer(minLength: BoardMetrics.unit)
                    Text(BoardFormat.tally(tally))
                        .font(BoardType.body)
                        .monospacedDigit()
                        .foregroundStyle(BoardColor.ink)
                        .fixedSize(horizontal: true, vertical: false)
                        .layoutPriority(1)
                    if lit {
                        TickGlass(title: "Tick")
                    }
                }
                .padding(.horizontal, BoardMetrics.unit)
                .frame(maxWidth: .infinity, minHeight: rowHeight, alignment: .leading)
                .background(lit ? BoardColor.surface : BoardColor.background)
            }
            .frame(maxWidth: .infinity, minHeight: max(rowHeight, BoardMetrics.hit), alignment: .leading)
            .contentShape(Rectangle())
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(BoardColor.muted.opacity(0.45))
                    .frame(height: BoardMetrics.hairline)
            }
        }
        .buttonStyle(AnyButtonStyle(IndexPressStyle()))
        .accessibilityLabel(lit ? "Tick \(counter.name). Lit." : "\(counter.name). Dark.")
    }

    private func measureStrip(dayKey: Int) -> some View {
        let ticks = store.chart.tickMarks.filter { $0.dayKey == dayKey }.count
        let misses = store.chart.missMarks.filter { $0.dayKey == dayKey }.count
        return HStack(alignment: .firstTextBaseline, spacing: BoardMetrics.unit * 3) {
            indexFigure("Laps", store.chart.lapMarks.count, valueFont: BoardType.title)
            indexFigure("Ticks", ticks, valueFont: BoardType.body)
            indexFigure("Misses", misses, valueFont: BoardType.caption)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: BoardMetrics.hit, alignment: .leading)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(BoardColor.muted)
                .frame(height: BoardMetrics.hairline)
        }
    }

    private func indexFigure(_ title: String, _ value: Int, valueFont: Font) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: BoardMetrics.unit) {
            Text(title)
                .font(BoardType.caption)
                .foregroundStyle(BoardColor.muted)
                .lineLimit(1)
            Text(BoardFormat.tally(value))
                .font(valueFont)
                .monospacedDigit()
                .foregroundStyle(BoardColor.accent)
                .lineLimit(1)
        }
        .fixedSize(horizontal: true, vertical: false)
    }

    private var undoBar: some View {
        Button("Undo") {
            switch store.undoLastAccepted() {
            case .undone:
                status = "Bead lit."
                hapticTick += 1
            case .nothingToUndo:
                break
            }
        }
        .buttonStyle(IndexPressStyle())
        .disabled(!canUndo)
        .opacity(canUndo ? 1 : 0.45)
        .frame(maxWidth: .infinity, minHeight: BoardMetrics.hit)
        .contentShape(Rectangle())
        .accessibilityLabel("Undo last tick")
    }

    private var canUndo: Bool {
        let undone = Set(store.chart.undoMarks.map(\.tickID))
        return store.chart.tickMarks.contains { !undone.contains($0.id) }
    }

    private var chrome: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 0) {
                chromeButton("Library", "books.vertical", .library)
                chromeButton("Stats", "chart.bar", .stats)
                chromeButton("History", "clock", .history)
                chromeButton("Settings", "gearshape", .settings)
            }
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    chromeButton("Library", "books.vertical", .library)
                    chromeButton("Stats", "chart.bar", .stats)
                }
                HStack(spacing: 0) {
                    chromeButton("History", "clock", .history)
                    chromeButton("Settings", "gearshape", .settings)
                }
            }
        }
        .overlay(alignment: .bottom) {
            Rectangle().fill(BoardColor.muted.opacity(0.45)).frame(height: BoardMetrics.hairline)
        }
    }

    private func chromeButton(_ title: String, _ symbol: String, _ destination: BoardSheet) -> some View {
        Button {
            sheet = destination
        } label: {
            Label(title, systemImage: symbol)
                .font(BoardType.caption)
                .foregroundStyle(BoardColor.ink)
                .lineLimit(1)
                .frame(maxWidth: .infinity, minHeight: BoardMetrics.hit)
                .contentShape(Rectangle())
        }
        .buttonStyle(IndexPressStyle())
        .accessibilityLabel(title)
    }

    private func apply(_ outcome: TickOutcome) {
        switch outcome {
        case .accepted(_, let lap, _):
            status = lap == nil ? "Bead lit." : "Lap filed."
            hapticTick += 1
        case .darkRefused:
            status = "Tick refused. That bead is dark. Tick the lit seat."
        case .bareRefused, .unknownRefused:
            status = "Tick refused."
        }
    }
}

enum BoardSheet: String, Identifiable {
    case library
    case stats
    case history
    case settings

    var id: String { rawValue }
}

/// Type-erased button style so the lit row and a dark row can differ.
struct AnyButtonStyle: ButtonStyle {
    private let apply: (Configuration) -> AnyView

    init<S: ButtonStyle>(_ style: S) {
        apply = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        apply(configuration)
    }
}

struct BoardNotice: View {
    var store: BoardStore
    var title: String
    var detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: BoardMetrics.unit * 2) {
            Text(title)
                .font(BoardType.title)
                .foregroundStyle(BoardColor.ink)
                .lineLimit(3)
            Text(detail)
                .font(BoardType.body)
                .foregroundStyle(BoardColor.muted)
                .lineLimit(6)
            Spacer(minLength: 0)
            Button("Retry") { store.clearLoadNotice() }
                .buttonStyle(GlassButtonStyle())
                .frame(maxWidth: .infinity, minHeight: BoardMetrics.hit)
        }
        .padding(BoardMetrics.unit * 2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(BoardColor.background)
    }
}

/// Named readout so the live driver can open the first seated row.
struct CupsIndex: View {
    var store: BoardStore

    var body: some View {
        SeatReadout(store: store, id: DemoBeads.cups)
    }
}

/// Named readout so the live driver can open the second seated row.
struct PagesIndex: View {
    var store: BoardStore

    var body: some View {
        SeatReadout(store: store, id: DemoBeads.pages)
    }
}

struct SeatReadout: View {
    var store: BoardStore
    var id: UUID

    var body: some View {
        let name = store.chart.counters.first { $0.id == id }?.name ?? "Row"
        let dayKey = DayKey.make(from: .now, calendar: .current)
        VStack(alignment: .leading, spacing: BoardMetrics.unit * 2) {
            Text(name)
                .font(BoardType.display)
                .foregroundStyle(BoardColor.ink)
                .lineLimit(1)
            Text(BoardFormat.tally(store.chart.tally(for: id, dayKey: dayKey)))
                .font(BoardType.title)
                .monospacedDigit()
                .foregroundStyle(BoardColor.accent)
            Spacer(minLength: 0)
        }
        .padding(BoardMetrics.unit * 2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(BoardColor.background)
    }
}
