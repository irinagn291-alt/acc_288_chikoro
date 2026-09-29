import SwiftUI

/// Three pages. Continue sits full width at the bottom. Skip and finish seat Cups, Pages, and Calls.
struct OnboardingFlow: View {
    var store: BoardStore
    var onFinished: () -> Void
    @State private var page = 0

    private let pages: [(title: String, line: String, art: String)] = [
        ("One tap order.", "Several everyday counts share one board. You tick the lit bead.", "srb_Onboarding1"),
        ("Tick the lit bead.", "That tap adds one for today and moves the light to the next bead.", "srb_Onboarding2"),
        ("A full circuit files a lap.", "A dark bead is refused. The light stays until you tick the lit one.", "srb_Onboarding3"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: BoardMetrics.unit * 2) {
            HStack {
                Spacer()
                Button("Skip") { finish() }
                    .font(BoardType.body)
                    .foregroundStyle(BoardColor.ink)
                    .frame(minHeight: BoardMetrics.hit)
                    .contentShape(Rectangle())
            }
            pageBody(pages[page])
            Text(BoardFormat.tally(page + 1))
                .font(BoardType.micro)
                .foregroundStyle(BoardColor.muted)
                .accessibilityLabel("Page \(page + 1)")
            Button(page == pages.count - 1 ? "Finish" : "Continue") {
                if page == pages.count - 1 {
                    finish()
                } else {
                    page += 1
                }
            }
            .buttonStyle(GlassButtonStyle())
            .frame(maxWidth: .infinity, minHeight: BoardMetrics.hit)
        }
        .padding(BoardMetrics.unit * 2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(BoardColor.background)
    }

    private func pageBody(_ page: (title: String, line: String, art: String)) -> some View {
        VStack(alignment: .leading, spacing: BoardMetrics.unit * 2) {
            Image(page.art)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: BoardMetrics.rowHeight * 4)
                .clipped()
                .accessibilityHidden(true)
            Text(page.title)
                .font(BoardType.title)
                .foregroundStyle(BoardColor.ink)
                .lineLimit(3)
            Text(page.line)
                .font(BoardType.body)
                .foregroundStyle(BoardColor.muted)
                .lineLimit(6)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func finish() {
        store.completeOnboarding()
        onFinished()
    }
}
