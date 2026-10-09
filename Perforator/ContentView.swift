import SwiftUI

/// Native root. Poster.storyboard stays the screen; this host only supplies the window.
struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        PosterRoot()
            .onChange(of: scenePhase) { _, phase in
                switch phase {
                case .active:
                    Task { await PosterRuntime.shared.noteDayChange() }
                case .inactive, .background:
                    Task { await PosterRuntime.shared.store.sceneBecameInactive() }
                @unknown default:
                    break
                }
            }
    }
}

private struct PosterRoot: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        UIStoryboard(name: "Poster", bundle: nil).instantiateInitialViewController()
            ?? UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

#Preview {
    ContentView()
}
