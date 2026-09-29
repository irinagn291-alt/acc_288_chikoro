import SwiftUI

/// Reads the review key once, after onboarding is done. The bead board never leaves.
struct BoardRoot: View {
    var store: BoardStore
    @State private var sheet: BoardSheet?
    @State private var forceOnboarding = false
    @State private var didReadReview = false
    @Environment(\.scenePhase) private var scenePhase

    private var showingOnboarding: Bool {
        forceOnboarding || !store.chart.onboardingComplete
    }

    var body: some View {
        Group {
            if showingOnboarding {
                OnboardingFlow(store: store) {
                    forceOnboarding = false
                }
            } else {
                BoardScreen(store: store, sheet: $sheet)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BoardColor.background.ignoresSafeArea())
        .environment(\.font, BoardType.body)
        .sheet(item: $sheet) { item in
            sheetBody(item)
                .presentationDetents([.large])
                .presentationCornerRadius(BoardMetrics.cardRadius)
                .presentationBackground(BoardColor.background)
        }
        .onAppear(perform: readReviewIfReady)
        .onChange(of: store.chart.onboardingComplete) { _, done in
            if done {
                forceOnboarding = false
                readReviewIfReady()
            }
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase != .active else { return }
            Task { await store.flushOnLeaveForeground() }
        }
    }

    @ViewBuilder
    private func sheetBody(_ item: BoardSheet) -> some View {
        switch item {
        case .library:
            LibrarySheet(store: store)
        case .stats:
            StatsSheet(store: store)
        case .history:
            HistorySheet(store: store)
        case .settings:
            SettingsSheet(store: store) {
                sheet = nil
                forceOnboarding = true
            }
        }
    }

    private func readReviewIfReady() {
        guard store.chart.onboardingComplete, !didReadReview, !forceOnboarding else { return }
        didReadReview = true
        switch ReviewLaunch.screen {
        case "log":
            sheet = .history
        case "goals":
            sheet = .stats
        case "library":
            sheet = .library
        case "settings":
            sheet = .settings
        default:
            sheet = nil
        }
    }
}
