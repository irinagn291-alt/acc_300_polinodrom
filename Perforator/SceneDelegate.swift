import UIKit

/// Scene role. Keeps the poster window and flushes the chart when the scene resigns.
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func sceneDidEnterBackground(_ scene: UIScene) {
        Task {
            await PosterRuntime.shared.store.sceneBecameInactive()
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        Task {
            await PosterRuntime.shared.noteDayChange()
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        Task {
            await PosterRuntime.shared.store.sceneBecameInactive()
        }
    }
}
