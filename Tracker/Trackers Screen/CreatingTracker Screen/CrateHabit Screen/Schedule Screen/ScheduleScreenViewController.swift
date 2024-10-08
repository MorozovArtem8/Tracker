//  Created by Artem Morozov on 10.08.2024.

import UIKit

final class ScheduleScreenViewController: UIViewController {
    
    var completionHandler: (([DaysWeek]) -> Void)?
    
    private lazy var tableView = UITableView()
    private lazy var readyButton = UIButton(type: .system)
    
    private lazy var heightCell: CGFloat = {
        let height = CGFloat(75)
        let screenHeight = view.bounds.height
        let navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0
        let buttonHeight = readyButton.frame.height
        let availableHeight = screenHeight - navigationBarHeight - buttonHeight - 16 - 24 - 10
        let potentialCellHeight = availableHeight / 7
        if potentialCellHeight < height {
            return CGFloat(potentialCellHeight)
        }
        return height
    }()
    
    private let color = Colors()
    private let tableViewData = DaysWeek.allCases
    private var selectedDays: [DaysWeek] = []
    
    init(selectedDays: [DaysWeek]) {
        self.selectedDays = selectedDays
        super .init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
}

//MARK: UITableViewDataSource func

extension ScheduleScreenViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleTableViewCell.reuseIdentifier, for: indexPath)
        
        guard let scheduleTableViewCell = cell as? ScheduleTableViewCell else {return UITableViewCell()}
        scheduleTableViewCell.configureCell(nameLabel: tableViewData[indexPath.row].rawValue)
        if selectedDays.contains(tableViewData[indexPath.row]) {
            scheduleTableViewCell.toggle.isOn = true
        }
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

//MARK: UITableViewDelegate func

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
        heightCell
    }
}

//MARK: Configure UI

private extension ScheduleScreenViewController {
    func configureUI() {
        view.backgroundColor = color.viewBackgroundColor
        self.title = "Расписание"
        configureReadyButton()
        configureTableView()
    }
    
    func configureReadyButton() {
        readyButton.translatesAutoresizingMaskIntoConstraints = false
        readyButton.backgroundColor = UIColor(named: "CustomBackgroundColor")
        readyButton.setTitle("Готово", for: .normal)
        readyButton.setTitleColor(color.totalBlackAndWhite, for: .normal)
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
        completionHandler?(selectedDays)
        dismiss(animated: true, completion: nil)
    }
    
    func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: ScheduleTableViewCell.reuseIdentifier)
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.separatorColor = UIColor("#AEAFB4")
        tableView.backgroundColor = color.viewBackgroundColor
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0.1))
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.bottomAnchor.constraint(equalTo: readyButton.topAnchor, constant: -10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
}
