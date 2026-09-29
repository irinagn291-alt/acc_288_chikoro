import SwiftUI

/// Settings sheet. Re-run onboarding, erase the board, and the contact link.
struct SettingsSheet: View {
    var store: BoardStore
    var onShowOnboarding: () -> Void
    @State private var confirmErase = false

    var body: some View {
        NavigationStack {
            Group {
                if let notice = store.loadNotice {
                    BoardNotice(store: store, title: "Settings unreadable.", detail: notice)
                } else if store.chart.counters.isEmpty && !store.chart.onboardingComplete {
                    empty
                } else {
                    form
                }
            }
            .sheetTitle("Settings")
            .background(BoardColor.background)
        }
        .modifier(SheetArrival())
        .confirmationDialog("Erase the board?", isPresented: $confirmErase, titleVisibility: .visible) {
            Button("Erase the board", role: .destructive) {
                Task { await store.resetAllData() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Counters and marks on this device are deleted.")
        }
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: BoardMetrics.unit * 2) {
            Text("Settings ready.")
                .font(BoardType.title)
                .foregroundStyle(BoardColor.ink)
            Text("Seat rows from onboarding, or erase later.")
                .font(BoardType.body)
                .foregroundStyle(BoardColor.muted)
            Spacer(minLength: 0)
            formActions
        }
        .padding(BoardMetrics.unit * 2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var form: some View {
        Form {
            Section {
                formActions
            }
            .listRowBackground(ChipSurface())
        }
        .indexList()
    }

    @ViewBuilder
    private var formActions: some View {
        Button("Show onboarding") { onShowOnboarding() }
            .font(BoardType.body)
            .frame(maxWidth: .infinity, minHeight: BoardMetrics.hit, alignment: .leading)
            .contentShape(Rectangle())
        Button("Erase the board") { confirmErase = true }
            .font(BoardType.body)
            .buttonStyle(DestructiveButtonStyle())
            .frame(maxWidth: .infinity, minHeight: BoardMetrics.hit)
        if let contact = URL(string: "https://soroban-board.pro/contact-us") {
            Link(destination: contact) {
                Text("Contact")
                    .font(BoardType.body)
                    .frame(maxWidth: .infinity, minHeight: BoardMetrics.hit, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Contact")
        }
    }
}
