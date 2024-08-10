//  Created by Artem Morozov on 10.08.2024.

import UIKit

final class ScheduleScreenViewController: UIViewController {
    
    private lazy var tableView = UITableView()
    private lazy var readyButton = UIButton(type: .system)
    
    let tableViewData = DaysWeek.allCases
    private var selectedDays: [DaysWeek] = [] {
        didSet {
            print(selectedDays)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
}

extension ScheduleScreenViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleTableViewCell.reuseIdentifier, for: indexPath)
        
        guard let scheduleTableViewCell = cell as? ScheduleTableViewCell else {return UITableViewCell()}
        scheduleTableViewCell.configureCell(nameLabel: tableViewData[indexPath.row].rawValue)
        scheduleTableViewCell.toggle.addTarget(self, action: #selector(toggleSwitchChanged), for: .valueChanged)
        scheduleTableViewCell.toggle.tag = indexPath.row
        return scheduleTableViewCell
    }
    
    @objc private func toggleSwitchChanged(_ sender: UISwitch) {
        let selectedDay = tableViewData[sender.tag]
        if sender.isOn {
            selectedDays.append(selectedDay)
        } else {
            selectedDays.removeAll { day in
                day == selectedDay
            }
        }
        
    }
}

extension ScheduleScreenViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        
        if indexPath.row == tableViewData.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 1000)
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

//MARK: Configure UI
private extension ScheduleScreenViewController {
    func configureUI() {
        view.backgroundColor = .white
        self.title = "Расписание"
        configureReadyButton()
        configureTableView()
    }
    
    func configureReadyButton() {
        readyButton.translatesAutoresizingMaskIntoConstraints = false
        readyButton.backgroundColor = UIColor("#1A1B22")
        readyButton.setTitle("Готово", for: .normal)
        readyButton.setTitleColor(.white, for: .normal)
        readyButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        readyButton.layer.cornerRadius = 16
        readyButton.clipsToBounds = true
        readyButton.addTarget(self, action: #selector(readyButtonTapped), for: .touchUpInside)
        
        view.addSubview(readyButton)
        
        NSLayoutConstraint.activate([
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            readyButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func readyButtonTapped() {
        
    }
    
    func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: ScheduleTableViewCell.reuseIdentifier)
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0.1))
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.bottomAnchor.constraint(equalTo: readyButton.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
}
