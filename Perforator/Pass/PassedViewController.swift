import UIKit

/// Passed days only. The cell stays empty: no stub word, no streak.
final class PassedViewController: UIViewController, UITableViewDataSource {
    private let runtime = PosterRuntime.shared
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var passes: [Pass] = []
    private let countLabel = UILabel()
    private let emptyPage = EmptyPageView(
        imageName: "pfo_EmptyList",
        headline: "No days passed",
        line: "Pass leaves the year cell empty, with no penalty.",
        actionTitle: "Crease"
    )
    private let errorPage = EmptyPageView(
        imageName: "pfo_EmptyList",
        headline: "Passed days could not be read",
        line: "The chart on this device did not open. Try again.",
        actionTitle: "Try again"
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Chrome.background
        title = "Passed"
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.backgroundColor = Chrome.background
        tableView.separatorStyle = .none
        tableView.rowHeight = Chrome.hit + Chrome.space(1)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "passed")
        countLabel.font = TypeScale.title()
        countLabel.textColor = Chrome.ink
        countLabel.adjustsFontForContentSizeCategory = true
        let caption = UILabel()
        caption.font = TypeScale.caption()
        caption.textColor = Chrome.muted
        caption.text = "Empty days"
        caption.adjustsFontForContentSizeCategory = true
        let header = UIStackView(arrangedSubviews: [countLabel, caption])
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
        passes = runtime.chart.passes.sorted { $0.daykey > $1.daykey }
        countLabel.text = AdmissionFormat.whole(passes.count)
        let failed = runtime.recoveryNote != nil && passes.isEmpty
        errorPage.isHidden = !failed
        emptyPage.isHidden = failed || !passes.isEmpty
        tableView.isHidden = passes.isEmpty
        tableView.reloadData()
    }

    @objc private func close() { dismiss(animated: true) }

    @objc private func retry() {
        Task {
            await runtime.boot()
            reload()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { passes.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "passed", for: indexPath)
        let pass = passes[indexPath.row]
        var content = UIListContentConfiguration.subtitleCell()
        content.text = "Passed"
        content.secondaryText = AdmissionFormat.whole(pass.daykey)
        content.textProperties.font = TypeScale.headline()
        content.secondaryTextProperties.font = TypeScale.body()
        content.textProperties.color = Chrome.ink
        content.secondaryTextProperties.color = Chrome.muted
        cell.contentConfiguration = content
        cell.selectionStyle = .none
        cell.backgroundColor = Chrome.background
        return cell
    }
}
