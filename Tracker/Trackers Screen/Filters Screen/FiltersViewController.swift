//
//  FilteresViewController.swift
//  Tracker
//
//  Created by Artem Morozov on 27.09.2024.
//

import UIKit

final class FiltersViewController: UIViewController {
    
    private lazy var tableView = UITableView()
    
    private let color = Colors()
    private var viewModel = FiltersViewModel()
    var completionHandler: (Int) -> Void
    
    init(completionHandler: @escaping (Int) -> Void) {
        self.completionHandler = completionHandler
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

extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.cellData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoriesTableViewSell.reuseIdentifier, for: indexPath)
        guard let categoriesTableViewCell = cell as? CategoriesTableViewSell else {return UITableViewCell()}
        categoriesTableViewCell.configureCell(categoryCell: viewModel.cellData[indexPath.row])
        let saveCellIsActive = viewModel.filterStateSavingService.currentFilterState
        if saveCellIsActive == indexPath.row {
            categoriesTableViewCell.didTapCell(true)
        }
        
        return categoriesTableViewCell
    }
}

extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.filterStateSavingService.store(newFilterState: indexPath.row)
        completionHandler(indexPath.row)
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.layer.masksToBounds = false
        cell.layer.cornerRadius = 0
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        
        if viewModel.cellData.count == 1 {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 16
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 1000)
            return
        }
        
        if indexPath.row == 0 {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        
        if indexPath.row == viewModel.cellData.count - 1 {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 16
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 1000)
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

//MARK: ConfigureUI

private extension FiltersViewController {
    func configureUI() {
        view.backgroundColor = color.viewBackgroundColor
        self.title = "Фильтры"
        configureTableView()
    }
    
    func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CategoriesTableViewSell.self, forCellReuseIdentifier: CategoriesTableViewSell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = color.viewBackgroundColor
        tableView.isScrollEnabled = true
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorColor = UIColor("#AEAFB4")
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.tableHeaderView = UIView()
        
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])
    }
}
