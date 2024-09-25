//  Created by Artem Morozov on 26.07.2024.

import UIKit

class StatisticViewController: UIViewController {
    
    private lazy var tableView = UITableView()
    private let viewModel: StatisticViewModel = StatisticViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.reloadAllData()
        tableView.reloadData()
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
        configureTableView()
    }
    
    func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(StatisticTableViewCell.self, forCellReuseIdentifier: StatisticTableViewCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.allowsSelection = false
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 77),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
