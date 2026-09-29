import SwiftUI

struct ContentView: View {
    @State private var store: BoardStore?
    @State private var showWait = false

    var body: some View {
        Group {
            if let store {
                BoardRoot(store: store)
            } else if showWait {
                ProgressView()
                    .tint(BoardColor.ink)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                BoardColor.background
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BoardColor.background.ignoresSafeArea())
        .task {
            guard store == nil else { return }
            let gate = Task {
                try? await Task.sleep(nanoseconds: 150_000_000)
                showWait = true
            }
            let opened = await BoardStore.open()
            await opened.installSimulatorSeedIfNeeded()
            gate.cancel()
            store = opened
        }
    }
}

#Preview {
    ContentView()
}
