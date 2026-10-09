import UIKit
import RealityKit

/// The one custom-rendered surface. A non-AR ModelEntity of the stub flips face up with the deal.
final class DealCardHost: UIView {
    private let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
    private let entity = ModelEntity(
        mesh: .generateBox(size: 0.18),
        materials: [SimpleMaterial(color: UIColor(DesignTokens.ink), isMetallic: false)]
    )
    private var shownFaceUp = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        common()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        common()
    }

    private func common() {
        isUserInteractionEnabled = false
        clipsToBounds = false
        let backdrop = UIImageView(image: UIImage(named: "pfo_CardBackdrop"))
        backdrop.contentMode = .scaleAspectFill
        backdrop.clipsToBounds = true
        backdrop.isAccessibilityElement = false
        backdrop.layer.cornerRadius = Chrome.cardRadius
        backdrop.translatesAutoresizingMaskIntoConstraints = false
        backdrop.backgroundColor = Chrome.surface
        arView.translatesAutoresizingMaskIntoConstraints = false
        arView.isOpaque = false
        arView.environment.background = .color(.clear)
        addSubview(backdrop)
        let anchor = AnchorEntity(world: .zero)
        anchor.addChild(entity)
        arView.scene.addAnchor(anchor)
        arView.layer.cornerRadius = Chrome.cardRadius
        arView.clipsToBounds = true
        addSubview(arView)
        NSLayoutConstraint.activate([
            backdrop.leadingAnchor.constraint(equalTo: leadingAnchor),
            backdrop.trailingAnchor.constraint(equalTo: trailingAnchor),
            backdrop.topAnchor.constraint(equalTo: topAnchor),
            backdrop.bottomAnchor.constraint(equalTo: bottomAnchor),
            arView.leadingAnchor.constraint(equalTo: leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: trailingAnchor),
            arView.topAnchor.constraint(equalTo: topAnchor),
            arView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        applyFace(faceUp: false, animated: false)
    }

    func setFaceUp(_ faceUp: Bool) {
        guard faceUp != shownFaceUp else { return }
        applyFace(faceUp: faceUp, animated: true)
    }

    private func applyFace(faceUp: Bool, animated: Bool) {
        shownFaceUp = faceUp
        let angle: Float = faceUp ? 0 : .pi
        let transform = Transform(rotation: simd_quatf(angle: angle, axis: [1, 0, 0]))
        if UIAccessibility.isReduceMotionEnabled || !animated {
            entity.transform = transform
            alpha = 1
            return
        }
        entity.move(to: transform, relativeTo: entity.parent, duration: 0.35)
    }
}
