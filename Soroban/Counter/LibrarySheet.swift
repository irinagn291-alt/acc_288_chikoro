import SwiftUI

/// Library sheet. Add, rename, reorder, and archive. Reorder keeps the same counter lit.
struct LibrarySheet: View {
    var store: BoardStore
    @State private var draft = ""
    @State private var renameDrafts: [UUID: String] = [:]
    @State private var refusal = ""
    @FocusState private var nameFocused: Bool

    private var active: [Counter] {
        store.chart.activeCounters
    }

    var body: some View {
        NavigationStack {
            Group {
                if let notice = store.loadNotice {
                    BoardNotice(store: store, title: "Library unreadable.", detail: notice)
                } else if active.isEmpty {
                    empty
                } else {
                    populated
                }
            }
            .sheetTitle("Library")
            .background(BoardColor.background)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button("Done") { nameFocused = false }
                        .frame(minHeight: BoardMetrics.hit)
                }
            }
        }
        .modifier(SheetArrival())
    }

    private var empty: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading, spacing: BoardMetrics.unit * 2) {
                    Image("srb_EmptyList")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: BoardMetrics.rowHeight * 2)
                        .clipped()
                        .accessibilityHidden(true)
                    Text("Library empty.")
                        .font(BoardType.title)
                        .foregroundStyle(BoardColor.ink)
                    Text(BoardCopy.libraryEmpty)
                        .font(BoardType.body)
                        .foregroundStyle(BoardColor.muted)
                    nameField
                    if !refusal.isEmpty {
                        Text(refusal)
                            .font(BoardType.caption)
                            .foregroundStyle(BoardColor.muted)
                    }
                    Spacer(minLength: 0)
                    Button("Add") { add() }
                        .buttonStyle(GlassButtonStyle())
                        .frame(maxWidth: .infinity, minHeight: BoardMetrics.hit)
                }
                .padding(BoardMetrics.unit * 2)
                .frame(maxWidth: .infinity, minHeight: geo.size.height, alignment: .topLeading)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    private var populated: some View {
        List {
            Section {
                nameField
                Button("Add") { add() }
                    .buttonStyle(GlassButtonStyle())
                    .frame(maxWidth: .infinity, minHeight: BoardMetrics.hit)
                    .listRowBackground(ChipSurface())
                if !refusal.isEmpty {
                    Text(refusal)
                        .font(BoardType.caption)
                        .foregroundStyle(BoardColor.muted)
                        .listRowBackground(ChipSurface())
                }
            }
            Section {
                ForEach(active) { counter in
                    VStack(alignment: .leading, spacing: BoardMetrics.unit) {
                        TextField("Name", text: binding(for: counter))
                            .font(BoardType.body)
                            .foregroundStyle(BoardColor.ink)
                            .submitLabel(.done)
                            .onSubmit { rename(counter) }
                        HStack(spacing: BoardMetrics.unit) {
                            Button("Rename") { rename(counter) }
                                .buttonStyle(GlassButtonStyle())
                                .frame(minHeight: BoardMetrics.hit)
                            Button("Archive") { _ = store.archive(counter.id) }
                                .buttonStyle(DestructiveButtonStyle())
                                .frame(minHeight: BoardMetrics.hit)
                                .accessibilityLabel("Archive \(counter.name)")
                        }
                    }
                    .padding(.vertical, BoardMetrics.unit)
                    .listRowBackground(ChipSurface())
                }
                .onMove(perform: move)
            }
        }
        .indexList()
        .environment(\.editMode, .constant(.active))
        .scrollDismissesKeyboard(.interactively)
    }

    private var nameField: some View {
        TextField("Row name", text: $draft)
            .font(BoardType.body)
            .foregroundStyle(BoardColor.ink)
            .textInputAutocapitalization(.words)
            .submitLabel(.done)
            .focused($nameFocused)
            .onSubmit { add() }
            .frame(minHeight: BoardMetrics.hit)
    }

    private func binding(for counter: Counter) -> Binding<String> {
        Binding(
            get: { renameDrafts[counter.id] ?? counter.name },
            set: { renameDrafts[counter.id] = $0 }
        )
    }

    private func add() {
        switch store.seat(name: draft) {
        case .seated:
            draft = ""
            refusal = ""
        case .rejected:
            refusal = "Name refused. Enter a name."
        }
    }

    private func rename(_ counter: Counter) {
        let next = (renameDrafts[counter.id] ?? counter.name)
        if store.rename(id: counter.id, to: next) {
            refusal = ""
        } else {
            refusal = "Name refused. Enter a name."
        }
    }

    private func move(from offsets: IndexSet, to destination: Int) {
        var ids = active.map(\.id)
        ids.move(fromOffsets: offsets, toOffset: destination)
        for (index, id) in ids.enumerated() {
            store.move(id, to: index)
        }
    }
}

/// Library destination. The sheet stays the surface; this name is the screen.
struct LibraryIndex: View {
    var store: BoardStore

    var body: some View {
        LibrarySheet(store: store)
    }
}
