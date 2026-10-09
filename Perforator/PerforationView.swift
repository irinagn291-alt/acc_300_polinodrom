import UIKit

/// Crease control. A UIControl whose bounds are the hit target.
/// Dragging the capsule files Kept. Reveal and the RealityKit flip live beside it, not inside this draw.
@IBDesignable
final class PerforationView: UIControl {
    @IBInspectable var creaseFraction: CGFloat = 0 {
        didSet { applyFraction() }
    }

    @IBInspectable var faceUp: Bool = false {
        didSet { accessibilityValue = faceUp ? "Face up" : "Face down" }
    }

    var onCrease: (() -> Void)?

    private let fill = UIView()
    private let titleLabel = UILabel()
    private let face = UIImageView()
    private var didFire = false
    private var didBuild = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        common()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        common()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }

    private func common() {
        guard !didBuild else { return }
        didBuild = true
        isAccessibilityElement = true
        accessibilityLabel = "Crease the perforation"
        accessibilityTraits = .button
        backgroundColor = Chrome.surface
        layer.cornerRadius = Chrome.chipRadius
        clipsToBounds = true
        fill.backgroundColor = Chrome.accent
        fill.isUserInteractionEnabled = false
        addSubview(fill)
        face.image = UIImage(named: "pfo_ControlFace")
        face.contentMode = .scaleAspectFit
        face.isUserInteractionEnabled = false
        face.isAccessibilityElement = false
        addSubview(face)
        titleLabel.text = "Crease"
        titleLabel.font = TypeScale.headline()
        titleLabel.textColor = Chrome.ink
        titleLabel.isUserInteractionEnabled = false
        titleLabel.isAccessibilityElement = false
        titleLabel.adjustsFontForContentSizeCategory = true
        addSubview(titleLabel)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(dragged(_:)))
        addGestureRecognizer(pan)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let radius = Chrome.capsuleRadius(for: bounds.height)
        layer.cornerRadius = radius
        fill.layer.cornerRadius = radius
        let art = Chrome.space(4)
        face.frame = CGRect(
            x: Chrome.space(2),
            y: (bounds.height - art) / 2,
            width: art,
            height: art
        )
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint(x: bounds.midX, y: bounds.midY)
        applyFraction()
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

    private func applyFraction() {
        let clamped = min(1, max(0, creaseFraction))
        fill.frame = CGRect(x: 0, y: 0, width: bounds.width * clamped, height: bounds.height)
    }

    @objc private func dragged(_ pan: UIPanGestureRecognizer) {
        let width = max(bounds.width, 1)
        let travel = pan.translation(in: self).x / width
        switch pan.state {
        case .began:
            didFire = false
            creaseFraction = 0
        case .changed:
            creaseFraction = min(1, max(0, travel))
        case .ended, .cancelled:
            if travel > 0.72, !didFire {
                didFire = true
                onCrease?()
            }
            creaseFraction = 0
        default:
            break
        }
    }
}
