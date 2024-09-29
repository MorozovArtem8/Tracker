//  Created by Artem Morozov on 26.07.2024.

import UIKit

class StatisticViewController: UIViewController {
    
    private lazy var tableView = UITableView()
    private lazy var emptyTrackerImage: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var emptyTrackerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private let color = Colors()
    private let viewModel: StatisticViewModel = StatisticViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
        displayStubForEmptyView(displayStub: viewModel.cellData.isEmpty)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.reloadAllData()
        tableView.reloadData()
        displayStubForEmptyView(displayStub: viewModel.cellData.isEmpty)
    }
    
    private func displayStubForEmptyView(displayStub: Bool) {
        emptyTrackerImage.image = displayStub ? UIImage(named: "emptyStatistic") : nil
        emptyTrackerLabel.isHidden = !displayStub
    }
}

extension StatisticViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.cellData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StatisticTableViewCell.reuseIdentifier, for: indexPath)
        
        guard let creatingHabitTableViewCell = cell as? StatisticTableViewCell else {return UITableViewCell()}
        creatingHabitTableViewCell.configureCell(countLabel: viewModel.cellData[indexPath.row].title, textInfoLabel: viewModel.cellData[indexPath.row].subTitle!)
        return creatingHabitTableViewCell
    }
}

extension StatisticViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        }
}

//MARK: Configure UI

private extension StatisticViewController {
    
    func configureUI() {
        view.backgroundColor = color.viewBackgroundColor
        configureTableView()
        configureEmptyTrackerImageAndLabel()
    }
    
    func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(StatisticTableViewCell.self, forCellReuseIdentifier: StatisticTableViewCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.allowsSelection = false
        tableView.backgroundColor = color.viewBackgroundColor
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 77),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func configureEmptyTrackerImageAndLabel() {
        let emptyStatisticStubText = NSLocalizedString("emptyStatisticStubText", comment: "emptyStatisticStubText")
        emptyTrackerImage.translatesAutoresizingMaskIntoConstraints = false
        emptyTrackerLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyTrackerLabel.text = emptyStatisticStubText
        view.addSubview(emptyTrackerImage)
        view.addSubview(emptyTrackerLabel)
        
        NSLayoutConstraint.activate([
            emptyTrackerImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyTrackerImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            emptyTrackerLabel.topAnchor.constraint(equalTo: emptyTrackerImage.bottomAnchor, constant: 8),
            emptyTrackerLabel.centerXAnchor.constraint(equalTo: emptyTrackerImage.centerXAnchor)
        ])
    }
}
