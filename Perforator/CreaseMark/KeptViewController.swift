import UIKit

/// Kept stubs only. A count poster, then the creased words. Not the full collection sheet.
final class KeptViewController: UIViewController, UITableViewDataSource {
    private let runtime = PosterRuntime.shared
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var marks: [CreaseMark] = []
    private let countLabel = UILabel()
    private let emptyPage = EmptyPageView(
        imageName: "pfo_EmptyList",
        headline: "No stubs creased yet",
        line: "Crease today's stub and it files here.",
        actionTitle: "Crease"
    )
    private let errorPage = EmptyPageView(
        imageName: "pfo_EmptyList",
        headline: "Kept stubs could not be read",
        line: "The chart on this device did not open. Try again.",
        actionTitle: "Try again"
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Chrome.background
        title = "Kept"
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.backgroundColor = Chrome.background
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Chrome.space(10)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "kept")
        countLabel.font = TypeScale.title()
        countLabel.textColor = Chrome.accent
        countLabel.adjustsFontForContentSizeCategory = true
        let caption = UILabel()
        caption.font = TypeScale.caption()
        caption.textColor = Chrome.muted
        caption.text = "Creased stubs"
        caption.adjustsFontForContentSizeCategory = true
        let header = UIStackView(arrangedSubviews: [countLabel, caption])
        header.axis = .vertical
        header.alignment = .leading
        header.spacing = Chrome.space(1)
        header.layoutMargins = UIEdgeInsets(
            top: Chrome.space(2),
            left: Chrome.space(2),
            bottom: Chrome.space(2),
            right: Chrome.space(2)
        )
        header.isLayoutMarginsRelativeArrangement = true
        header.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: Chrome.space(18))
        tableView.tableHeaderView = header
        view.addSubview(tableView)
        emptyPage.actionButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        errorPage.actionButton.addTarget(self, action: #selector(retry), for: .touchUpInside)
        view.addSubview(emptyPage)
        view.addSubview(errorPage)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }

    private func reload() {
        marks = runtime.chart.creases.sorted { $0.daykey > $1.daykey }
        countLabel.text = AdmissionFormat.whole(marks.count)
        let failed = runtime.recoveryNote != nil && marks.isEmpty
        errorPage.isHidden = !failed
        emptyPage.isHidden = failed || !marks.isEmpty
        tableView.isHidden = marks.isEmpty
        tableView.reloadData()
    }

    @objc private func close() { dismiss(animated: true) }

    @objc private func retry() {
        Task {
            await runtime.boot()
            reload()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { marks.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "kept", for: indexPath)
        let mark = marks[indexPath.row]
        var content = UIListContentConfiguration.subtitleCell()
        content.text = mark.word
        content.secondaryText = mark.action
        content.textProperties.font = TypeScale.title()
        content.secondaryTextProperties.font = TypeScale.body()
        content.textProperties.color = Chrome.ink
        content.secondaryTextProperties.color = Chrome.muted
        content.textProperties.numberOfLines = 1
        cell.contentConfiguration = content
        cell.selectionStyle = .none
        cell.backgroundColor = Chrome.background
        return cell
    }
}
