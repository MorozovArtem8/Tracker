//  Created by Artem Morozov on 13.09.2024.


import UIKit

protocol CreateNewCategoryDelegate: AnyObject {
    func createNewCategory(categoryHeader: String)
}

final class CategoryScreenViewController: UIViewController {
    private var viewModel: CategoryViewModelProtocol?
    
    private lazy var tableView = UITableView()
    private let addCategoryButton: UIButton = UIButton()
    
    private lazy var emptyTrackerImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "emptyTracker")
        return imageView
    }()
    
    private lazy var emptyTrackerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.text = "Привычки и события можно объеденить по смыслу"
        return label
    }()
    
    private var selectCategoryHeader: String?
    
    var completionHandler: ((String?) -> Void)?
    
    init(selectedCategory: String? = nil) {
        self.selectCategoryHeader = selectedCategory
        super .init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        viewModel = CategoryViewModel()
        viewModel?.categoriesBinding = {[weak self] _ in
            self?.displayStubForEmptyTableView(displayStub: self?.viewModel?.trackerCategories.count == 0)
            self?.tableView.reloadData()
        }
        
        displayStubForEmptyTableView(displayStub: viewModel?.trackerCategories.count == 0)
    }
    
    private func displayStubForEmptyTableView(displayStub: Bool) {
        emptyTrackerImage.isHidden = !displayStub
        emptyTrackerLabel.isHidden = !displayStub
    }
}

extension CategoryScreenViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.trackerCategories.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoriesTableViewSell.reuseIdentifier, for: indexPath)
        guard let categoriesTableViewCell = cell as? CategoriesTableViewSell else {return UITableViewCell()}
        
        if let selectedCategory = selectCategoryHeader {
            let currentCellIsSelect = selectedCategory == viewModel?.trackerCategories[indexPath.row].header
            let categoryCell = CategoryCell(title: viewModel?.trackerCategories[indexPath.row].header ?? "", isActive: currentCellIsSelect)
            categoriesTableViewCell.configureCell(categoryCell: categoryCell)
            return categoriesTableViewCell
        }
        
        let categoryCell = CategoryCell(title: viewModel?.trackerCategories[indexPath.row].header ?? "")
        categoriesTableViewCell.configureCell(categoryCell: categoryCell)
        return categoriesTableViewCell
    }
}

extension CategoryScreenViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        completionHandler?(viewModel?.trackerCategories[indexPath.row].header)
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let viewModel else {return}
        
        cell.layer.masksToBounds = false
        cell.layer.cornerRadius = 0
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        if viewModel.trackerCategories.count == 1 {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 16
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 1000)
            return
        }
        
        if indexPath.row == 0 {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        
        if indexPath.row == (viewModel.trackerCategories.count) - 1 {
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

//MARK: CreateNewCategoryDelegate func

extension CategoryScreenViewController: CreateNewCategoryDelegate {
    func createNewCategory(categoryHeader: String) {
        viewModel?.addNewCategory(categoryHeader: categoryHeader)
    }
}

//MARK: Configure UI

private extension CategoryScreenViewController {
    func configureUI() {
        view.backgroundColor = .white
        self.title = "Категория"
        configureAddCategoryButton()
        configureTableView()
        configureEmptyTrackerImageAndLabel()
    }
    
    func configureEmptyTrackerImageAndLabel() {
        emptyTrackerImage.translatesAutoresizingMaskIntoConstraints = false
        emptyTrackerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyTrackerImage)
        view.addSubview(emptyTrackerLabel)
        
        NSLayoutConstraint.activate([
            emptyTrackerImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyTrackerImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            emptyTrackerLabel.topAnchor.constraint(equalTo: emptyTrackerImage.bottomAnchor, constant: 8),
            emptyTrackerLabel.centerXAnchor.constraint(equalTo: emptyTrackerImage.centerXAnchor)
        ])
    }
    
    func configureAddCategoryButton() {
        addCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        addCategoryButton.backgroundColor = UIColor(named: "CustomBackgroundColor")
        addCategoryButton.setTitle("Добавить категорию", for: .normal)
        addCategoryButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        addCategoryButton.layer.cornerRadius = 16
        addCategoryButton.clipsToBounds = true
        addCategoryButton.addTarget(self, action: #selector(addCategoryButtonButtonTapped), for: .touchUpInside)
        view.addSubview(addCategoryButton)
        
        NSLayoutConstraint.activate([
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
            
        ])
    }
    
    @objc func addCategoryButtonButtonTapped() {
        let createCategoryScreenViewController = CreateCategoryScreenViewController(delegate: self)
        let navigationController = UINavigationController(rootViewController: createCategoryScreenViewController)
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        navigationController.navigationBar.titleTextAttributes = textAttributes
        present(navigationController, animated: true)
    }
    
    func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CategoriesTableViewSell.self, forCellReuseIdentifier: CategoriesTableViewSell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = true
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -16)
        ])
    }
}
