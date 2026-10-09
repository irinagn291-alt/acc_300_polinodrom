import UIKit

/// Poster role. Today's deal never leaves this controller.
/// Reveal and crease fuse here. Collection, Year, and Settings arrive as sheets.
final class PosterViewController: UIViewController {
    @IBOutlet private var perforationView: PerforationView?

    private let runtime = PosterRuntime.shared
    private let headerDecor = UIImageView()
    private let wordLabel = UILabel()
    private let actionLabel = UILabel()
    private let jobLabel = UILabel()
    private let ordinalCaption = UILabel()
    private let ordinalValue = UILabel()
    private let countCaption = UILabel()
    private let countValue = UILabel()
    private let phaseValue = UILabel()
    private let daykeyValue = UILabel()
    private let cardHost = DealCardHost()
    private let statStrip = UIView()
    private let twistArt = UIImageView()
    private let successMark = UIImageView()
    private let spinner = UIActivityIndicatorView(style: .medium)
    private let collectionButton = AdmissionIconButton(symbol: "square.stack", label: "Collection")
    private let yearButton = AdmissionIconButton(symbol: "square.grid.3x3", label: "Year")
    private let settingsButton = AdmissionIconButton(symbol: "gearshape", label: "Settings")
    private let revealButton = AdmissionButton(title: "Reveal", kind: .quiet)
    private let passButton = AdmissionButton(title: "Pass", kind: .quiet)
    private let retractButton = AdmissionButton(title: "Retract", kind: .retract)
    private let emptyPage = EmptyPageView(
        imageName: "pfo_EmptyHome",
        headline: "Today's card is waiting",
        line: "Drag the perforation after you reveal it.",
        actionTitle: "Crease"
    )
    private let errorPage = EmptyPageView(
        imageName: "pfo_EmptyHome",
        headline: "Today's stub did not open",
        line: "The chart on this device could not be read. Try again.",
        actionTitle: "Try again"
    )
    private var didHookReview = false
    private var booted = false
    private var loading = false
    private var inFlight = false
    private var didEnter = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Chrome.background
        perforationView?.onCrease = { [weak self] in self?.commitCrease() }
        buildChrome()
        revealButton.addTarget(self, action: #selector(commitReveal), for: .touchUpInside)
        passButton.addTarget(self, action: #selector(commitPass), for: .touchUpInside)
        retractButton.addTarget(self, action: #selector(commitRetract), for: .touchUpInside)
        emptyPage.actionButton.addTarget(self, action: #selector(commitEmptyCrease), for: .touchUpInside)
        errorPage.actionButton.addTarget(self, action: #selector(retryBoot), for: .touchUpInside)
        collectionButton.addTarget(self, action: #selector(openCollection), for: .touchUpInside)
        yearButton.addTarget(self, action: #selector(openYear), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        revealButton.accessibilityLabel = "Reveal today's card"
        passButton.accessibilityLabel = "Pass today"
        retractButton.accessibilityLabel = "Retract today"
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(redraw),
            name: PosterRuntime.dayChange,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(significantTimeChange),
            name: UIApplication.significantTimeChangeNotification,
            object: nil
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !booted else {
            render()
            presentOnboardingIfNeeded()
            return
        }
        booted = true
        loading = true
        render()
        Task {
            try? await Task.sleep(nanoseconds: 150_000_000)
            if loading {
                spinner.startAnimating()
            }
        }
        Task {
            await runtime.boot()
            loading = false
            spinner.stopAnimating()
            render()
            presentOnboardingIfNeeded()
        }
    }

    private func buildChrome() {
        headerDecor.image = UIImage(named: "pfo_HeaderDecor")
        headerDecor.contentMode = .scaleAspectFill
        headerDecor.clipsToBounds = true
        headerDecor.layer.cornerRadius = Chrome.cardRadius
        headerDecor.isAccessibilityElement = false
        headerDecor.backgroundColor = Chrome.surface
        headerDecor.translatesAutoresizingMaskIntoConstraints = false

        wordLabel.font = TypeScale.posterWord()
        wordLabel.textColor = Chrome.ink
        wordLabel.numberOfLines = 1
        wordLabel.lineBreakMode = .byClipping
        wordLabel.adjustsFontSizeToFitWidth = true
        wordLabel.minimumScaleFactor = 0.35
        wordLabel.baselineAdjustment = .alignCenters
        wordLabel.adjustsFontForContentSizeCategory = true
        wordLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        wordLabel.setContentHuggingPriority(.required, for: .vertical)

        jobLabel.font = TypeScale.body()
        jobLabel.textColor = Chrome.ink
        jobLabel.numberOfLines = 0
        jobLabel.lineBreakMode = .byWordWrapping
        jobLabel.adjustsFontForContentSizeCategory = true
        jobLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        actionLabel.font = TypeScale.body()
        actionLabel.textColor = Chrome.ink
        actionLabel.numberOfLines = 0
        actionLabel.adjustsFontForContentSizeCategory = true

        ordinalCaption.font = TypeScale.micro()
        ordinalCaption.textColor = Chrome.muted
        ordinalCaption.text = "Day"
        ordinalCaption.adjustsFontForContentSizeCategory = true
        ordinalValue.font = TypeScale.headline()
        ordinalValue.textColor = Chrome.ink
        ordinalValue.adjustsFontForContentSizeCategory = true
        ordinalValue.setContentCompressionResistancePriority(.required, for: .horizontal)

        let ordinalColumn = UIStackView(arrangedSubviews: [ordinalCaption, ordinalValue])
        ordinalColumn.axis = .vertical
        ordinalColumn.alignment = .leading
        ordinalColumn.spacing = Chrome.space(1)
        let typeRow = UIStackView(arrangedSubviews: [wordLabel, ordinalColumn, jobLabel, actionLabel])
        typeRow.axis = .vertical
        typeRow.alignment = .fill
        typeRow.spacing = Chrome.space(1)

        cardHost.translatesAutoresizingMaskIntoConstraints = false
        Chrome.applyShadow(to: cardHost)
        cardHost.layer.cornerRadius = Chrome.cardRadius
        cardHost.setContentHuggingPriority(.defaultLow, for: .vertical)

        twistArt.image = UIImage(named: "pfo_TwistHero")
        twistArt.contentMode = .scaleAspectFit
        twistArt.clipsToBounds = true
        twistArt.layer.cornerRadius = Chrome.chipRadius
        twistArt.isAccessibilityElement = false
        twistArt.backgroundColor = Chrome.surface
        twistArt.translatesAutoresizingMaskIntoConstraints = false

        countCaption.font = TypeScale.micro()
        countCaption.textColor = Chrome.muted
        countCaption.text = "Creased"
        countCaption.adjustsFontForContentSizeCategory = true
        countValue.font = TypeScale.headline()
        countValue.textColor = Chrome.accent
        countValue.adjustsFontForContentSizeCategory = true
        phaseValue.font = TypeScale.body()
        phaseValue.textColor = Chrome.ink
        phaseValue.adjustsFontForContentSizeCategory = true
        daykeyValue.font = TypeScale.micro()
        daykeyValue.textColor = Chrome.muted
        daykeyValue.adjustsFontForContentSizeCategory = true
        let countColumn = UIStackView(arrangedSubviews: [countCaption, countValue])
        countColumn.axis = .vertical
        countColumn.spacing = Chrome.space(1)
        let phaseColumn = UIStackView(arrangedSubviews: [phaseValue, daykeyValue])
        phaseColumn.axis = .vertical
        phaseColumn.spacing = Chrome.space(1)
        let statRow = UIStackView(arrangedSubviews: [twistArt, countColumn, phaseColumn])
        statRow.axis = .horizontal
        statRow.alignment = .center
        statRow.spacing = Chrome.space(2)
        statRow.translatesAutoresizingMaskIntoConstraints = false
        statStrip.backgroundColor = Chrome.surface
        statStrip.layer.cornerRadius = Chrome.cardRadius
        statStrip.translatesAutoresizingMaskIntoConstraints = false
        Chrome.applyShadow(to: statStrip)
        statStrip.addSubview(statRow)

        successMark.image = UIImage(named: "pfo_SuccessMark")
        successMark.contentMode = .scaleAspectFit
        successMark.isAccessibilityElement = false
        successMark.alpha = 0
        successMark.translatesAutoresizingMaskIntoConstraints = false

        spinner.color = Chrome.ink
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false

        let sheets = UIStackView(arrangedSubviews: [collectionButton, yearButton, settingsButton])
        sheets.axis = .horizontal
        sheets.spacing = Chrome.space(1)
        sheets.alignment = .center
        let verbs = UIStackView(arrangedSubviews: [revealButton, passButton, retractButton])
        verbs.axis = .horizontal
        verbs.spacing = Chrome.space(1)
        verbs.distribution = .fillEqually
        let column = UIStackView(arrangedSubviews: [typeRow, cardHost, statStrip, verbs])
        column.axis = .vertical
        column.alignment = .fill
        column.spacing = Chrome.space(2)
        column.translatesAutoresizingMaskIntoConstraints = false
        typeRow.setContentHuggingPriority(.required, for: .vertical)
        statStrip.setContentHuggingPriority(.required, for: .vertical)
        verbs.setContentHuggingPriority(.required, for: .vertical)
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        scroll.keyboardDismissMode = .onDrag
        scroll.addSubview(column)
        sheets.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerDecor)
        view.addSubview(sheets)
        view.addSubview(scroll)
        view.addSubview(successMark)
        view.addSubview(spinner)
        view.addSubview(emptyPage)
        view.addSubview(errorPage)
        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            headerDecor.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: Chrome.space(2)),
            headerDecor.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -Chrome.space(2)),
            headerDecor.topAnchor.constraint(equalTo: safe.topAnchor, constant: Chrome.space(1)),
            headerDecor.heightAnchor.constraint(equalToConstant: Chrome.space(8)),
            sheets.topAnchor.constraint(equalTo: headerDecor.bottomAnchor, constant: Chrome.space(1)),
            sheets.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -Chrome.space(2)),
            scroll.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: Chrome.space(2)),
            scroll.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -Chrome.space(2)),
            scroll.topAnchor.constraint(equalTo: sheets.bottomAnchor, constant: Chrome.space(2)),
            column.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            column.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            column.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            column.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            column.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor),
            column.heightAnchor.constraint(greaterThanOrEqualTo: scroll.frameLayoutGuide.heightAnchor),
            cardHost.heightAnchor.constraint(greaterThanOrEqualToConstant: Chrome.space(22)),
            twistArt.widthAnchor.constraint(equalToConstant: Chrome.space(8)),
            twistArt.heightAnchor.constraint(equalToConstant: Chrome.space(8)),
            statRow.leadingAnchor.constraint(equalTo: statStrip.leadingAnchor, constant: Chrome.space(2)),
            statRow.trailingAnchor.constraint(equalTo: statStrip.trailingAnchor, constant: -Chrome.space(2)),
            statRow.topAnchor.constraint(equalTo: statStrip.topAnchor, constant: Chrome.space(1)),
            statRow.bottomAnchor.constraint(equalTo: statStrip.bottomAnchor, constant: -Chrome.space(1)),
            statStrip.heightAnchor.constraint(greaterThanOrEqualToConstant: Chrome.hit),
            successMark.centerXAnchor.constraint(equalTo: cardHost.centerXAnchor),
            successMark.centerYAnchor.constraint(equalTo: cardHost.centerYAnchor),
            successMark.widthAnchor.constraint(equalToConstant: Chrome.space(8)),
            successMark.heightAnchor.constraint(equalToConstant: Chrome.space(8)),
            spinner.centerXAnchor.constraint(equalTo: cardHost.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: cardHost.centerYAnchor),
            emptyPage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyPage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyPage.topAnchor.constraint(equalTo: sheets.bottomAnchor),
            emptyPage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            errorPage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorPage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorPage.topAnchor.constraint(equalTo: view.topAnchor),
            errorPage.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        if let perforationView {
            scroll.bottomAnchor.constraint(equalTo: perforationView.topAnchor, constant: -Chrome.space(2)).isActive = true
            view.bringSubviewToFront(perforationView)
        } else {
            scroll.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -Chrome.space(2)).isActive = true
        }
        view.bringSubviewToFront(sheets)
        view.bringSubviewToFront(successMark)
    }

    private func render() {
        let chart = runtime.chart
        let deal = chart.live
        let faceUp = deal?.faceUp ?? false
        let phase = deal?.phase
        if loading {
            wordLabel.text = "Today"
            actionLabel.text = "Opening today's stub."
            jobLabel.text = "One card, then crease the perforation."
        } else {
            wordLabel.text = deal?.word ?? "Sealed"
            actionLabel.text = faceUp ? deal?.action : "The micro-action stays shut until you reveal it."
            jobLabel.text = jobCopy(for: phase)
        }
        ordinalValue.text = AdmissionFormat.whole(runtime.dayOrdinal())
        countValue.text = AdmissionFormat.whole(chart.creases.count)
        phaseValue.text = phaseWord(phase)
        daykeyValue.text = deal.map { AdmissionFormat.whole($0.daykey) }
        perforationView?.faceUp = faceUp
        cardHost.setFaceUp(faceUp)
        let failed = runtime.recoveryNote != nil
        errorPage.isHidden = !failed
        let waiting = !loading && !failed && (phase == nil || phase == .sealed)
        emptyPage.isHidden = !waiting
        applyEnabled(phase: phase)
        if waiting {
            view.bringSubviewToFront(emptyPage)
            view.bringSubviewToFront(collectionButton.superview ?? emptyPage)
        }
        if failed {
            view.bringSubviewToFront(errorPage)
        }
        if let perforationView, emptyPage.isHidden, errorPage.isHidden {
            view.bringSubviewToFront(perforationView)
        }
        staggerIn()
        if chart.onboardingComplete, !loading {
            openReviewIfNeeded()
        }
    }

    private func jobCopy(for phase: Deal.Phase?) -> String {
        switch phase {
        case .revealed:
            return "Drag the perforation to crease today's stub."
        case .kept:
            return "Today is filed on the year wall."
        case .passed:
            return "Today stays empty. No streak, no penalty."
        case .sealed, .none:
            return "Reveal the card, then drag the perforation."
        }
    }

    private func phaseWord(_ phase: Deal.Phase?) -> String {
        switch phase {
        case .kept: return "Kept"
        case .passed: return "Passed"
        case .revealed: return "Revealed"
        case .sealed, .none: return "Sealed"
        }
    }

    private func applyEnabled(phase: Deal.Phase?) {
        let busy = inFlight || loading
        revealButton.isEnabled = !busy && phase == .sealed
        passButton.isEnabled = !busy && (phase == .sealed || phase == .revealed)
        retractButton.isEnabled = !busy && (phase == .kept || phase == .passed)
        perforationView?.isEnabled = !busy && phase == .revealed
        emptyPage.actionButton.isEnabled = !busy
        errorPage.actionButton.isEnabled = !busy
    }

    private func staggerIn() {
        let views: [UIView] = [wordLabel, actionLabel, ordinalValue, cardHost, statStrip]
        if didEnter {
            views.forEach { $0.alpha = 1 }
            return
        }
        didEnter = true
        if UIAccessibility.isReduceMotionEnabled {
            views.forEach { $0.alpha = 1 }
            return
        }
        for (index, item) in views.enumerated() {
            item.alpha = 0
            UIView.animate(
                withDuration: Chrome.motion,
                delay: Chrome.staggerDelay(index: index),
                options: [.curveEaseOut]
            ) {
                item.alpha = 1
            }
        }
    }

    private func presentOnboardingIfNeeded() {
        guard !runtime.chart.onboardingComplete, presentedViewController == nil else { return }
        let board = UIStoryboard(name: "Onboarding", bundle: nil)
        guard let onboarding = board.instantiateInitialViewController() as? OnboardingViewController else { return }
        onboarding.modalPresentationStyle = .fullScreen
        onboarding.onFinished = { [weak self] in
            self?.dismiss(animated: true) {
                self?.render()
            }
        }
        present(onboarding, animated: true)
    }

    private func openReviewIfNeeded() {
        guard !didHookReview else { return }
        didHookReview = true
        switch ReviewHook.screenOnce() {
        case "log":
            openCollection()
        case "goals":
            openYear()
        case "settings":
            openSettings()
        case "kept":
            openKept()
        case "passed":
            openPassed()
        default:
            break
        }
    }

    @objc private func redraw() {
        render()
    }

    @objc private func significantTimeChange() {
        Task {
            await runtime.noteDayChange()
        }
    }

    @objc private func retryBoot() {
        guard !inFlight else { return }
        loading = true
        render()
        Task {
            await runtime.boot()
            loading = false
            spinner.stopAnimating()
            render()
        }
    }

    @objc private func commitReveal() {
        guard !inFlight else { return }
        inFlight = true
        applyEnabled(phase: runtime.chart.live?.phase)
        Task {
            await runtime.reveal()
            inFlight = false
            render()
        }
    }

    @objc private func commitEmptyCrease() {
        if runtime.chart.live?.phase == .revealed {
            commitCrease()
        } else {
            commitReveal()
        }
    }

    private func commitCrease() {
        guard !inFlight else { return }
        inFlight = true
        applyEnabled(phase: runtime.chart.live?.phase)
        Task {
            await runtime.crease()
            let kept = runtime.lastRefusal == nil && runtime.chart.live?.phase == .kept
            inFlight = false
            render()
            if kept {
                flashSuccess()
            }
        }
    }

    private func flashSuccess() {
        successMark.alpha = 0
        UIAccessibility.post(notification: .announcement, argument: "Creased")
        UIView.animate(withDuration: Chrome.motion, animations: {
            self.successMark.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: Chrome.motion, delay: Chrome.motion, options: [.curveEaseOut]) {
                self.successMark.alpha = 0
            }
        })
    }

    @objc private func commitPass() {
        guard !inFlight else { return }
        inFlight = true
        applyEnabled(phase: runtime.chart.live?.phase)
        Task {
            await runtime.pass()
            inFlight = false
            render()
        }
    }

    @objc private func commitRetract() {
        guard !inFlight else { return }
        inFlight = true
        applyEnabled(phase: runtime.chart.live?.phase)
        Task {
            await runtime.retract()
            inFlight = false
            render()
        }
    }

    @objc private func openCollection() {
        presentSheet("Collection")
    }

    @objc private func openYear() {
        presentSheet("Year")
    }

    @objc private func openSettings() {
        presentSheet("Settings")
    }

    private func openKept() {
        presentController(KeptViewController())
    }

    private func openPassed() {
        presentController(PassedViewController())
    }

    private func presentSheet(_ name: String) {
        let board = UIStoryboard(name: name, bundle: nil)
        guard let controller = board.instantiateInitialViewController() else { return }
        presentController(controller)
    }

    private func presentController(_ controller: UIViewController) {
        let navigation = UINavigationController(rootViewController: controller)
        navigation.modalPresentationStyle = .pageSheet
        if presentedViewController == nil {
            present(navigation, animated: true)
        }
    }
}
