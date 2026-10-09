import UIKit

/// Chrome role. Colour, space, radius, and elevation each have one accessor.
/// Cards use the card radius. Chips use the chip radius. Primary actions are capsules.
enum Chrome {
    static let unit: CGFloat = 8
    static let cardRadius: CGFloat = 4
    static let chipRadius: CGFloat = 2
    static let pressScale: CGFloat = 0.97
    static let staggerStep: TimeInterval = 0.05
    static let staggerCap: TimeInterval = 0.36
    static let hit: CGFloat = 44

    static var background: UIColor { UIColor(DesignTokens.bg) }
    static var surface: UIColor { UIColor(DesignTokens.surface) }
    static var ink: UIColor { UIColor(DesignTokens.ink) }
    static var accent: UIColor { UIColor(DesignTokens.accent) }
    static var muted: UIColor { UIColor(DesignTokens.muted) }

    static func space(_ steps: CGFloat) -> CGFloat { unit * steps }

    /// Primary control is a filled capsule. Cards and chips stay on the two radii.
    static func capsuleRadius(for height: CGFloat) -> CGFloat { height / 2 }

    static let motion: TimeInterval = 0.24

    @MainActor
    static func applyShadow(to view: UIView) {
        view.layer.shadowColor = ink.cgColor
        view.layer.shadowOpacity = 0.12
        view.layer.shadowRadius = space(1)
        view.layer.shadowOffset = CGSize(width: 0, height: space(1))
        view.layer.masksToBounds = false
    }

    /// 50ms steps. The last item still finishes inside the 360ms cap.
    static func staggerDelay(index: Int) -> TimeInterval {
        let latestStart = max(0, staggerCap - motion)
        return min(latestStart, staggerStep * Double(index))
    }

    @MainActor
    static func closeItem(target: Any?, action: Selector) -> UIBarButtonItem {
        let button = AdmissionIconButton(symbol: "xmark", label: "Close")
        button.addTarget(target, action: action, for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }

    @MainActor
    static func navigationAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = background
        appearance.shadowColor = muted
        appearance.titleTextAttributes = [
            .font: TypeScale.headline(),
            .foregroundColor: ink
        ]
        appearance.largeTitleTextAttributes = [
            .font: TypeScale.title(),
            .foregroundColor: ink
        ]
        return appearance
    }
}

/// Filled capsule for the live verb. Retract uses a destructive configuration.
final class AdmissionButton: UIButton {
    enum Kind {
        case crease
        case quiet
        case retract
    }

    private let kind: Kind

    init(title: String, kind: Kind) {
        self.kind = kind
        super.init(frame: .zero)
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.title = title
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = TypeScale.headline()
            return outgoing
        }
        config.contentInsets = NSDirectionalEdgeInsets(
            top: Chrome.space(1),
            leading: Chrome.space(2),
            bottom: Chrome.space(1),
            trailing: Chrome.space(2)
        )
        switch kind {
        case .crease:
            config.cornerStyle = .capsule
            config.baseBackgroundColor = Chrome.accent
            config.baseForegroundColor = Chrome.background
        case .quiet:
            config.cornerStyle = .fixed
            config.background.cornerRadius = Chrome.chipRadius
            config.baseBackgroundColor = Chrome.surface
            config.baseForegroundColor = Chrome.ink
        case .retract:
            config.cornerStyle = .fixed
            config.background.cornerRadius = Chrome.chipRadius
            config.title = title
            config.baseBackgroundColor = Chrome.ink
            config.baseForegroundColor = Chrome.background
            self.role = .destructive
        }
        configuration = config
        accessibilityLabel = title
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(greaterThanOrEqualToConstant: Chrome.hit).isActive = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        self.kind = .crease
        super.init(coder: coder)
    }

    override var isHighlighted: Bool {
        didSet {
            let scale = isHighlighted ? Chrome.pressScale : 1
            transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }

    override var isEnabled: Bool {
        didSet { alpha = isEnabled ? 1 : 0.4 }
    }
}

/// Sheet destinations. A compact icon hit, not a row of equal cards.
final class AdmissionIconButton: UIButton {
    init(symbol: String, label: String) {
        super.init(frame: .zero)
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .fixed
        config.background.cornerRadius = Chrome.chipRadius
        config.image = UIImage(systemName: symbol)
        config.baseBackgroundColor = Chrome.surface
        config.baseForegroundColor = Chrome.ink
        config.contentInsets = NSDirectionalEdgeInsets(
            top: Chrome.space(1),
            leading: Chrome.space(1),
            bottom: Chrome.space(1),
            trailing: Chrome.space(1)
        )
        configuration = config
        accessibilityLabel = label
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(greaterThanOrEqualToConstant: Chrome.hit),
            heightAnchor.constraint(greaterThanOrEqualToConstant: Chrome.hit)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        // Programmer error: icon buttons are built in code.
        fatalError("Icon buttons are built in code.")
    }

    override var isHighlighted: Bool {
        didSet {
            let scale = isHighlighted ? Chrome.pressScale : 1
            transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }

    override var isEnabled: Bool {
        didSet { alpha = isEnabled ? 1 : 0.4 }
    }
}
