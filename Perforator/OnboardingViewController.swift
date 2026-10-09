import UIKit

/// Onboarding role. Three short pages. Continue is full width. Skip writes the same completion flag.
final class OnboardingViewController: UIViewController {
    var onFinished: (() -> Void)?

    private let pages: [(String, String, String)] = [
        ("pfo_Onboarding1", "One card today", "The day deals a single stub from the bundled stock."),
        ("pfo_Onboarding2", "Reveal, then crease", "Open the card, then drag the perforation onto the year."),
        ("pfo_Onboarding3", "Pass without a streak", "Skip the day and the cell stays empty. No penalty.")
    ]
    private var index = 0
    private let art = UIImageView()
    private let headline = UILabel()
    private let line = UILabel()
    private let continueButton = AdmissionButton(title: "Continue", kind: .crease)
    private let skipButton = AdmissionButton(title: "Skip", kind: .quiet)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Chrome.background
        art.contentMode = .scaleAspectFit
        art.translatesAutoresizingMaskIntoConstraints = false
        headline.font = TypeScale.title()
        headline.textColor = Chrome.ink
        headline.numberOfLines = 2
        headline.adjustsFontForContentSizeCategory = true
        line.font = TypeScale.body()
        line.textColor = Chrome.muted
        line.numberOfLines = 0
        line.adjustsFontForContentSizeCategory = true
        let stack = UIStackView(arrangedSubviews: [art, headline, line])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = Chrome.space(2)
        stack.translatesAutoresizingMaskIntoConstraints = false
        let buttons = UIStackView(arrangedSubviews: [skipButton, continueButton])
        buttons.axis = .vertical
        buttons.spacing = Chrome.space(1)
        buttons.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        view.addSubview(buttons)
        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            art.heightAnchor.constraint(equalToConstant: Chrome.space(28)),
            art.widthAnchor.constraint(equalTo: stack.widthAnchor),
            stack.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: Chrome.space(3)),
            stack.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -Chrome.space(3)),
            stack.topAnchor.constraint(equalTo: safe.topAnchor, constant: Chrome.space(4)),
            buttons.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: Chrome.space(2)),
            buttons.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -Chrome.space(2)),
            buttons.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -Chrome.space(2))
        ])
        continueButton.addTarget(self, action: #selector(advance), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(skip), for: .touchUpInside)
        showPage()
    }

    private func showPage() {
        let page = pages[index]
        art.image = UIImage(named: page.0)
        headline.text = page.1
        line.text = page.2
        continueButton.accessibilityLabel = index == pages.count - 1 ? "Continue to today" : "Continue"
    }

    @objc private func advance() {
        if index + 1 < pages.count {
            index += 1
            showPage()
            return
        }
        finish()
    }

    @objc private func skip() {
        finish()
    }

    private func finish() {
        Task {
            await PosterRuntime.shared.completeOnboarding()
            onFinished?()
        }
    }
}
