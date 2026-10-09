import UIKit

/// Collection role. Counts CreaseMarks. Stock table cells, no second custom surface.
final class CollectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet private var tableView: UITableView!

    private let runtime = PosterRuntime.shared
    private var marks: [CreaseMark] = []
    private let emptyPage = EmptyPageView(
        imageName: "pfo_EmptyList",
        headline: "No stubs creased yet",
        line: "Crease today's stub and it files here.",
        actionTitle: "Crease"
    )
    private let errorPage = EmptyPageView(
        imageName: "pfo_EmptyList",
        headline: "The collection could not be read",
        line: "The last chart on this device did not open. You can crease today again.",
        actionTitle: "Try again"
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Chrome.background
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = Chrome.background
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Chrome.space(12)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "stub")
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
        let count = UILabel()
        count.tag = 7
        count.font = TypeScale.title()
        count.textColor = Chrome.accent
        count.adjustsFontForContentSizeCategory = true
        let caption = UILabel()
        caption.font = TypeScale.caption()
        caption.textColor = Chrome.muted
        caption.text = "Creased stubs on this device"
        caption.adjustsFontForContentSizeCategory = true
        let header = UIStackView(arrangedSubviews: [count, caption])
        header.axis = .vertical
        header.alignment = .leading
        header.spacing = Chrome.space(1)
        header.isLayoutMarginsRelativeArrangement = true
        header.layoutMargins = UIEdgeInsets(
            top: Chrome.space(2),
            left: Chrome.space(2),
            bottom: Chrome.space(2),
            right: Chrome.space(2)
        )
        header.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: Chrome.space(14))
        tableView.tableHeaderView = header
        errorPage.actionButton.removeTarget(self, action: #selector(close), for: .touchUpInside)
        errorPage.actionButton.addTarget(self, action: #selector(retry), for: .touchUpInside)
    }

    @objc private func retry() {
        Task {
            await runtime.boot()
            viewWillAppear(false)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        marks = runtime.chart.creases.sorted { $0.daykey > $1.daykey }
        if let count = tableView.tableHeaderView?.viewWithTag(7) as? UILabel {
            count.text = AdmissionFormat.whole(marks.count)
        }
        let failed = runtime.recoveryNote != nil && marks.isEmpty
        errorPage.isHidden = !failed
        emptyPage.isHidden = failed || !marks.isEmpty
        tableView.isHidden = marks.isEmpty
        tableView.reloadData()
        title = "Collection \(AdmissionFormat.whole(marks.count))"
    }

    @objc private func close() {
        dismiss(animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        marks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stub", for: indexPath)
        let mark = marks[indexPath.row]
        var content = UIListContentConfiguration.subtitleCell()
        content.text = mark.word
        content.secondaryText = "\(AdmissionFormat.whole(mark.daykey)). \(mark.action)"
        content.textProperties.font = TypeScale.headline()
        content.secondaryTextProperties.font = TypeScale.body()
        content.textProperties.color = Chrome.ink
        content.secondaryTextProperties.color = Chrome.muted
        cell.contentConfiguration = content
        cell.backgroundColor = Chrome.surface
        var background = UIBackgroundConfiguration.listPlainCell()
        background.backgroundColor = Chrome.surface
        background.cornerRadius = Chrome.cardRadius
        cell.backgroundConfiguration = background
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !UIAccessibility.isReduceMotionEnabled else {
            cell.alpha = 1
            return
        }
        cell.alpha = 0
        UIView.animate(withDuration: 0.2, delay: Chrome.staggerDelay(index: indexPath.row)) {
            cell.alpha = 1
        }
    }
}
