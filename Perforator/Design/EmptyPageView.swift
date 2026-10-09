import UIKit

/// Full-page empty or error plate. One cutout, one headline, one line, one bottom button.
final class EmptyPageView: UIView {
    let actionButton: AdmissionButton

    init(imageName: String, headline: String, line: String, actionTitle: String) {
        actionButton = AdmissionButton(title: actionTitle, kind: .crease)
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = Chrome.background

        let art = UIImageView(image: UIImage(named: imageName))
        art.contentMode = .scaleAspectFit
        art.translatesAutoresizingMaskIntoConstraints = false
        art.isAccessibilityElement = false

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = TypeScale.title()
        title.textColor = Chrome.ink
        title.numberOfLines = 2
        title.adjustsFontForContentSizeCategory = true
        title.text = headline

        let body = UILabel()
        body.translatesAutoresizingMaskIntoConstraints = false
        body.font = TypeScale.body()
        body.textColor = Chrome.muted
        body.numberOfLines = 0
        body.adjustsFontForContentSizeCategory = true
        body.text = line

        let stack = UIStackView(arrangedSubviews: [art, title, body])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = Chrome.space(2)
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        addSubview(actionButton)
        NSLayoutConstraint.activate([
            art.heightAnchor.constraint(equalToConstant: Chrome.space(16)),
            art.widthAnchor.constraint(equalToConstant: Chrome.space(16)),
            stack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: Chrome.space(3)),
            stack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -Chrome.space(3)),
            stack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Chrome.space(4)),
            actionButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: Chrome.space(2)),
            actionButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -Chrome.space(2)),
            actionButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -Chrome.space(2))
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        // Programmer error: empty pages are built in code, never from a nib.
        fatalError("Empty pages are built in code.")
    }
}
