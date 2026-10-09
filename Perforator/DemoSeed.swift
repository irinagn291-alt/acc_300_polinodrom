import Foundation

/// Names the simulator seed. DealStore installs it once behind this key and never on a device.
enum DemoSeed {
    static let key = DealStore.demoKey
}
