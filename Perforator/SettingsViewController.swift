import UIKit

/// Settings role. Export, contact, onboarding again, and a confirmed erase.
final class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet private var tableView: UITableView!

    private let runtime = PosterRuntime.shared
    private let rows = ["Export collection", "Contact", "Run onboarding again", "Erase the collection"]
    private var status = ""
    private let emptyPage = EmptyPageView(
        imageName: "pfo_EmptyList",
        headline: "Nothing to export yet",
        line: "Crease a stub and the collection can leave this device as a file.",
        actionTitle: "Crease"
    )
    private let errorLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Chrome.background
        title = "Settings"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = Chrome.background
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "row")
        tableView.rowHeight = Chrome.hit + Chrome.space(1)
        errorLabel.font = TypeScale.body()
        errorLabel.textColor = Chrome.ink
        errorLabel.numberOfLines = 0
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyPage.actionButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        view.addSubview(emptyPage)
        view.addSubview(errorLabel)
        NSLayoutConstraint.activate([
            emptyPage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyPage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyPage.topAnchor.constraint(equalTo: view.topAnchor),
            emptyPage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Chrome.space(2)),
            errorLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Chrome.space(2)),
            errorLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Chrome.space(2))
        ])
        navigationItem.rightBarButtonItem = Chrome.closeItem(target: self, action: #selector(close))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let count = runtime.chart.creases.count
        status = count == 0 ? "" : "\(AdmissionFormat.whole(count)) creased stubs on this device."
        let failed = runtime.recoveryNote != nil && count == 0
        emptyPage.isHidden = true
        tableView.isHidden = false
        errorLabel.isHidden = !failed && status.isEmpty
        errorLabel.text = failed ? "The chart could not be read. Try again from the poster." : status
        view.bringSubviewToFront(tableView)
        if failed || !status.isEmpty {
            view.bringSubviewToFront(errorLabel)
        }
        tableView.reloadData()
    }

    @objc private func close() { dismiss(animated: true) }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rows.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "row", for: indexPath)
        var content = UIListContentConfiguration.cell()
        content.text = rows[indexPath.row]
        content.textProperties.font = TypeScale.headline()
        content.textProperties.color = Chrome.ink
        let symbols = ["square.and.arrow.up", "link", "arrow.counterclockwise", "trash"]
        content.image = UIImage(systemName: symbols[indexPath.row])
        content.imageProperties.tintColor = indexPath.row == 3 ? Chrome.ink : Chrome.muted
        cell.contentConfiguration = content
        cell.accessibilityLabel = rows[indexPath.row]
        cell.backgroundColor = Chrome.surface
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            exportCollection()
        case 1:
            guard let url = URL(string: "https://perforator-deal.pro/contact-us") else { return }
            UIApplication.shared.open(url)
        case 2:
            Task {
                await runtime.reopenOnboarding()
                dismiss(animated: true)
            }
        default:
            confirmErase()
        }
    }

    private func exportCollection() {
        let text = runtime.exportText()
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("collection.txt")
        do {
            try text.write(to: url, atomically: true, encoding: .utf8)
            errorLabel.text = status
            let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            present(activity, animated: true)
        } catch {
            errorLabel.text = "The collection file could not be written. It is still on this device."
        }
    }

    private func confirmErase() {
        let alert = UIAlertController(
            title: "Erase the collection?",
            message: "Creased stubs on this device are deleted.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Keep", style: .cancel))
        alert.addAction(UIAlertAction(title: "Erase", style: .destructive) { [weak self] _ in
            Task { await self?.runtime.resetAll() }
        })
        present(alert, animated: true)
    }
}
