import UIKit

/// Year role. A grid of Kept, Passed, and Sealed cells. Each cell prints its word.
final class YearViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet private var collectionView: UICollectionView!

    private let runtime = PosterRuntime.shared
    private var deals: [Deal] = []
    private var laidWidth: CGFloat = 0
    private let emptyPage = EmptyPageView(
        imageName: "pfo_EmptyList",
        headline: "The year wall is clear",
        line: "Reveal today and the first cell files here.",
        actionTitle: "Crease"
    )
    private let errorPage = EmptyPageView(
        imageName: "pfo_EmptyList",
        headline: "The year could not be read",
        line: "The chart on this device did not open. Today can still be creased.",
        actionTitle: "Crease"
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Chrome.background
        title = "Year"
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = Chrome.background
        collectionView.register(YearCell.self, forCellWithReuseIdentifier: YearCell.reuse)
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: Chrome.space(14), height: Chrome.space(10))
        layout.minimumInteritemSpacing = Chrome.space(1)
        layout.minimumLineSpacing = Chrome.space(1)
        layout.sectionInset = UIEdgeInsets(
            top: Chrome.space(2),
            left: Chrome.space(2),
            bottom: Chrome.space(2),
            right: Chrome.space(2)
        )
        collectionView.collectionViewLayout = layout
        emptyPage.actionButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        errorPage.actionButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        view.addSubview(emptyPage)
        view.addSubview(errorPage)
        NSLayoutConstraint.activate([
            emptyPage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyPage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyPage.topAnchor.constraint(equalTo: view.topAnchor),
            emptyPage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            errorPage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorPage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorPage.topAnchor.constraint(equalTo: view.topAnchor),
            errorPage.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        navigationItem.rightBarButtonItem = Chrome.closeItem(target: self, action: #selector(close))
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let width = collectionView.bounds.width
        guard width > 0, abs(width - laidWidth) > 1 else { return }
        laidWidth = width
        let inset = Chrome.space(2)
        let gap = Chrome.space(1)
        let itemWidth = floor(width - inset * 2)
        layout.itemSize = CGSize(width: itemWidth, height: Chrome.space(10))
        layout.minimumInteritemSpacing = gap
        layout.minimumLineSpacing = gap
        layout.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        layout.invalidateLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        deals = runtime.yearWall()
        let failed = runtime.recoveryNote != nil
        errorPage.isHidden = !failed
        emptyPage.isHidden = failed || !deals.isEmpty
        collectionView.isHidden = failed || deals.isEmpty
        collectionView.reloadData()
    }

    @objc private func close() { dismiss(animated: true) }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        deals.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: YearCell.reuse, for: indexPath)
        if let cell = cell as? YearCell {
            let deal = deals[indexPath.item]
            cell.fill(deal)
            cell.onTap = { [weak self] in
                self?.open(deal)
            }
        }
        return cell
    }

    private func open(_ deal: Deal) {
        let message: String
        switch deal.phase {
        case .kept:
            message = "\(deal.word). \(deal.action)"
        case .passed:
            message = "Passed. The cell stays empty."
        case .revealed:
            message = "\(deal.word). Drag the perforation on today to crease it."
        case .sealed:
            message = "Sealed. This day has not been opened."
        }
        let alert = UIAlertController(title: "\(dayTitle(deal.daykey)), \(phaseTitle(deal))", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(alert, animated: true)
    }

    private func dayTitle(_ daykey: Int) -> String {
        let month = (daykey / 100) % 100
        let day = daykey % 100
        let names = Calendar.current.monthSymbols
        let name = (month >= 1 && month <= names.count) ? names[month - 1] : ""
        if name.isEmpty {
            return AdmissionFormat.whole(daykey)
        }
        return "\(name) \(AdmissionFormat.whole(day))"
    }

    private func phaseTitle(_ deal: Deal) -> String {
        switch deal.phase {
        case .kept: return "Kept"
        case .passed: return "Passed"
        case .revealed: return "Revealed"
        case .sealed: return "Sealed"
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard !UIAccessibility.isReduceMotionEnabled else {
            cell.alpha = 1
            return
        }
        cell.alpha = 0
        UIView.animate(withDuration: 0.2, delay: Chrome.staggerDelay(index: indexPath.item)) {
            cell.alpha = 1
        }
    }
}

final class YearCell: UICollectionViewCell {
    static let reuse = "year-cell"
    var onTap: (() -> Void)?
    private let day = UILabel()
    private let key = UILabel()
    private let status = UILabel()
    private let button = UIButton(type: .custom)

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = Chrome.surface
        contentView.layer.cornerRadius = Chrome.cardRadius
        contentView.clipsToBounds = true

        day.font = TypeScale.body()
        day.textColor = Chrome.ink
        day.numberOfLines = 1
        day.lineBreakMode = .byTruncatingTail
        day.adjustsFontForContentSizeCategory = true
        day.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        key.font = TypeScale.caption()
        key.textColor = Chrome.muted
        key.numberOfLines = 1
        key.lineBreakMode = .byTruncatingTail
        key.adjustsFontForContentSizeCategory = true

        status.font = TypeScale.headline()
        status.textColor = Chrome.ink
        status.numberOfLines = 1
        status.lineBreakMode = .byClipping
        status.adjustsFontForContentSizeCategory = true
        status.setContentCompressionResistancePriority(.required, for: .horizontal)
        status.setContentHuggingPriority(.required, for: .horizontal)

        let titles = UIStackView(arrangedSubviews: [day, key])
        titles.axis = .vertical
        titles.spacing = Chrome.space(1)
        titles.alignment = .leading
        titles.isUserInteractionEnabled = false

        let row = UIStackView(arrangedSubviews: [titles, status])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = Chrome.space(2)
        row.isUserInteractionEnabled = false
        row.translatesAutoresizingMaskIntoConstraints = false

        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        contentView.addSubview(button)
        contentView.addSubview(row)
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            button.topAnchor.constraint(equalTo: contentView.topAnchor),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Chrome.space(2)),
            row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Chrome.space(2)),
            row.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: Chrome.hit)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        // Programmer error: year cells are registered in code.
        fatalError("Year cells are registered in code.")
    }

    func fill(_ deal: Deal) {
        let month = (deal.daykey / 100) % 100
        let dayNumber = deal.daykey % 100
        let names = Calendar.current.monthSymbols
        let name = (month >= 1 && month <= names.count) ? names[month - 1] : ""
        day.text = name.isEmpty ? AdmissionFormat.whole(deal.daykey) : "\(name) \(AdmissionFormat.whole(dayNumber))"
        key.text = AdmissionFormat.whole(deal.daykey)
        switch deal.phase {
        case .kept:
            status.text = "Kept"
            contentView.backgroundColor = Chrome.surface
        case .passed:
            status.text = "Passed"
            contentView.backgroundColor = Chrome.background
        case .sealed:
            status.text = "Sealed"
            contentView.backgroundColor = Chrome.surface
        case .revealed:
            status.text = "Revealed"
            contentView.backgroundColor = Chrome.surface
        }
        let label = "\(day.text ?? ""), \(status.text ?? "")"
        button.accessibilityLabel = label
        accessibilityLabel = label
    }

    @objc private func tapped() {
        onTap?()
    }
}
