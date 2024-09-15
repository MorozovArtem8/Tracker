//  Created by Artem Morozov on 08.08.2024.

import UIKit

final class CreatingHabitViewController: UIViewController {
    
    private lazy var scrollView = UIScrollView()
    private let contentView = UIView()
    private lazy var nameTrackerTextField = PaddedTextField()
    private lazy var tableView = UITableView()
    private lazy var cancelButton = UIButton(type: .system)
    private lazy var createButton = UIButton(type: .system)
    private lazy var stackView = UIStackView()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.allowsMultipleSelection = true
        collectionView.isScrollEnabled = false
        collectionView.register(CreateTrackerCollectionViewEmojiCell.self, forCellWithReuseIdentifier: CreateTrackerCollectionViewEmojiCell.identifier)
        collectionView.register(CreateTrackerCollectionViewColorCell.self, forCellWithReuseIdentifier: CreateTrackerCollectionViewColorCell.identifier)
        collectionView.register(HeaderSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        return collectionView
    }()
    
    //IndexPath переменные для хранения 2-х выбранных ячеек одной CollectionView emoji и color
    private var selectedEmojiIndexPath: IndexPath?
    private var selectedColorIndexPath: IndexPath?
    
    private let delegate: CreateHabitDelegate?
    private let geometricParams: GeometricParams
    private var tableViewData: [CellData] = [CellData(title: "Категория"), CellData(title: "Расписание")]
    private var collectionViewData: [CreateTrackerCollectionCellData] = [
        CreateTrackerCollectionCellData(header: "Emoji", type: .emoji(["😀", "😍", "😂","🫥", "🤢", "😾","🫵", "👶", "👚","🦋", "🐞", "🐺","🐭", "🐦", "🐋","🍀", "🍄", "🌪️"])),
        CreateTrackerCollectionCellData(header: "Emoji1", type: .color([UIColor("#FD4C49"), UIColor("#FF881E"),UIColor("#007BFA"), UIColor("#6E44FE"),UIColor("#33CF69"),UIColor("#E66DD4"),UIColor("#F9D4D4"),UIColor("#34A7FE"),UIColor("#46E69D"),UIColor("#35347C"),UIColor("#FF674D"),UIColor("#FF99CC"),UIColor("#F6C48B"),UIColor("#7994F5"),UIColor("#832CF1"),UIColor("#AD56DA"),UIColor("#8D72E6"),UIColor("#2FD058")]))]
    
    private var selectedDays: [DaysWeek] = [] {
        didSet {
            updateCreateButtonState()
        }
    }
    
    private var selectedCategoryTitle: String? {
        didSet {
            updateCreateButtonState()
        }
    }
    
    private var selectedEmoji: String? {
        didSet {
            updateCreateButtonState()
        }
    }
    
    private var selectedColor: UIColor? {
        didSet {
            updateCreateButtonState()
        }
    }
    
    private var createButtonIsEnabled: Bool {
        let nameTrackerTextFieldIsEmpty = nameTrackerTextField.text?.isEmpty ?? true
        let selectedDaysIsEmpty = selectedDays.isEmpty
        let selectedCategoriesTitleIsEmpty = selectedCategoryTitle == nil
        let selectedEmojiIsEmpty = selectedEmoji == nil
        let selectedColorIsEmpty = selectedColor == nil
        return !nameTrackerTextFieldIsEmpty && !selectedDaysIsEmpty && !selectedEmojiIsEmpty && !selectedColorIsEmpty && !selectedCategoriesTitleIsEmpty
    }
    
    init(delegate: CreateHabitDelegate) {
        self.delegate = delegate
        self.geometricParams =  GeometricParams(cellCount: 6,leftInset: 18,rightInset: 18,cellSpacing: 5)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(updateCreateButtonState), name: UITextField.textDidChangeNotification, object: nameTrackerTextField)
    }
    
    @objc private func updateCreateButtonState() {
        if createButtonIsEnabled {
            createButton.backgroundColor = .black
            createButton.isEnabled = true
        } else {
            createButton.backgroundColor = UIColor("#AEAFB4")
            createButton.isEnabled = false
        }
    }
    
    private func getScheduleCellString(daysWeek: [DaysWeek]) -> String {
        if daysWeek.count == 7 {
            return "Каждый день"
        }
        let sortedDaysWeek = daysWeek.sorted()
        let selectedDaysString = sortedDaysWeek.map {$0.getAbbreviatedName()}.joined(separator: ", ")
        return selectedDaysString
    }
}

extension CreatingHabitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CreatingHabitTableViewCell.reuseIdentifier, for: indexPath)
        
        guard let creatingHabitTableViewCell = cell as? CreatingHabitTableViewCell else {return UITableViewCell()}
        creatingHabitTableViewCell.configureCell(nameLabel: tableViewData[indexPath.row].title, subLabel: tableViewData[indexPath.row].subTitle)
        return creatingHabitTableViewCell
    }
}

extension CreatingHabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            let categoriesScreenViewController = CategoryScreenViewController(selectedCategory: selectedCategoryTitle)
            categoriesScreenViewController.completionHandler = { [weak self] categoryTitle in
                self?.selectedCategoryTitle = categoryTitle
                self?.tableViewData[0].subTitle = categoryTitle
                self?.tableView.reloadData()
            }
            let navigationController = UINavigationController(rootViewController: categoriesScreenViewController)
            
            let textAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 16, weight: .medium)
            ]
            navigationController.navigationBar.titleTextAttributes = textAttributes
            present(navigationController, animated: true)
        case 1:
            let scheduleScreenViewController = ScheduleScreenViewController(selectedDays: selectedDays)
            scheduleScreenViewController.completionHandler = { [weak self] data in
                self?.selectedDays = data
                self?.tableViewData[1].subTitle = self?.getScheduleCellString(daysWeek: data)
                self?.tableView.reloadData()
            }
            
            let navigationController = UINavigationController(rootViewController: scheduleScreenViewController)
            
            let textAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 16, weight: .medium)
            ]
            navigationController.navigationBar.titleTextAttributes = textAttributes
            present(navigationController, animated: true)
        default:
            print("Неизвестная ячейка")
        }
    }
    
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

//MARK: CollectionView DataSource

extension CreatingHabitViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? HeaderSupplementaryView
        view?.titleLabel.text = collectionViewData[indexPath.section].header
        return view ?? UICollectionReusableView()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return collectionViewData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionViewData[section].type {
        case .emoji(let emojis):
            return emojis.count
        case .color(let colors):
            return colors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        
        switch collectionViewData[indexPath.section].type {
        case .emoji(let emojis):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreateTrackerCollectionViewEmojiCell.identifier, for: indexPath) as? CreateTrackerCollectionViewEmojiCell else {return UICollectionViewCell()}
            cell.prepareForReuse()
            cell.configureCell(emoji: emojis[indexPath.item])
            return cell
        case .color(let colors):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreateTrackerCollectionViewColorCell.identifier, for: indexPath) as? CreateTrackerCollectionViewColorCell else {return UICollectionViewCell()}
            cell.prepareForReuse()
            cell.configureCell(colors[indexPath.row])
            return cell
        }
    }
}

//MARK: CollectionView Deleage

extension CreatingHabitViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionViewData[indexPath.section].type {
        case .emoji(let emoji):
            guard let cell = collectionView.cellForItem(at: indexPath) as? CreateTrackerCollectionViewEmojiCell else {return}
            if let selectedEmojiIndexPath,
               let previousCell = collectionView.cellForItem(at: selectedEmojiIndexPath) as? CreateTrackerCollectionViewEmojiCell {
                self.selectedEmojiIndexPath = indexPath
                previousCell.selectCell(select: false)
                collectionView.deselectItem(at: selectedEmojiIndexPath, animated: true)
                
                cell.selectCell(select: true)
                self.selectedEmoji = emoji[indexPath.row]
                return
            }
            self.selectedEmojiIndexPath = indexPath
            cell.selectCell(select: true)
            self.selectedEmoji = emoji[indexPath.row]
            
        case .color(let color):
            guard let cell = collectionView.cellForItem(at: indexPath) as? CreateTrackerCollectionViewColorCell else {return}
            if let selectedColorIndexPath,
               let previousCell = collectionView.cellForItem(at: selectedColorIndexPath) as? CreateTrackerCollectionViewColorCell {
                self.selectedColorIndexPath = indexPath
                previousCell.selectCell(select: false)
                collectionView.deselectItem(at: selectedColorIndexPath, animated: true)
                
                cell.selectCell(select: true)
                self.selectedColor = color[indexPath.row]
                return
            }
            self.selectedColorIndexPath = indexPath
            cell.selectCell(select: true)
            self.selectedColor = color[indexPath.row]
            
        }
    }
    
}



//MARK: UICollectionViewFlowLayout func
extension CreatingHabitViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 19)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - geometricParams.paddingWidth
        let cellWidth = availableWidth / CGFloat(geometricParams.cellCount)
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 24, left: geometricParams.leftInset, bottom: 24, right: geometricParams.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        geometricParams.cellSpacing
    }
}


//MARK: Configure UI

private extension CreatingHabitViewController {
    func configureUI() {
        view.backgroundColor = .white
        self.title = "Новая привычка"
    
        configureScrollView()
        configureNameTrackerTextField()
        configureTableView()
        configureButtons()
        configureCollectionView()
    }
    
    func configureScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
    }
    
    func configureNameTrackerTextField() {
        nameTrackerTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTrackerTextField.placeholder = "Введите название трекера"
        nameTrackerTextField.textColor = .black
        nameTrackerTextField.backgroundColor = UIColor("#E6E8EB", alpha: 0.3)
        nameTrackerTextField.textAlignment = .left
        nameTrackerTextField.layer.cornerRadius = 16
        nameTrackerTextField.clipsToBounds = true
        
        contentView.addSubview(nameTrackerTextField)
        
        NSLayoutConstraint.activate([
            nameTrackerTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            nameTrackerTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTrackerTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameTrackerTextField.heightAnchor.constraint(equalToConstant: 75)
            
        ])
    }
    
    func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CreatingHabitTableViewCell.self, forCellReuseIdentifier: CreatingHabitTableViewCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        contentView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: nameTrackerTextField.bottomAnchor, constant: 24),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }
    
    func configureCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(collectionView)
        
        let availableWidth = view.frame.width - geometricParams.paddingWidth
        let cellHeight = availableWidth / CGFloat(geometricParams.cellCount)
        let numberOfRows = 36 / CGFloat(geometricParams.cellCount)
        let topAndBottomInsets = CGFloat((24 + 24) * collectionViewData.count)
        let headerHeight = CGFloat(19 * collectionViewData.count)
        let collectionViewHeight: CGFloat = numberOfRows * cellHeight + topAndBottomInsets + headerHeight
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: collectionViewHeight),
            collectionView.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -16)
        ])
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func configureButtons() {
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cancelButton.setTitleColor(UIColor("#F56B6C"), for: .normal)
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor("#F56B6C").cgColor
        cancelButton.clipsToBounds = true
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.backgroundColor = UIColor("#AEAFB4")
        createButton.isEnabled = false
        createButton.setTitleColor(.white, for: .normal)
        createButton.setTitle("Создать", for: .normal)
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        createButton.layer.cornerRadius = 16
        createButton.clipsToBounds = true
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        
        self.stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
        ])
    }
    
    @objc func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc func createButtonTapped() {
        self.dismiss(animated: true)
        
        let id = UUID()
        let schedule = selectedDays
        guard let name = nameTrackerTextField.text,
              let color = selectedColor,
              let emoji = selectedEmoji,
              let header = selectedCategoryTitle
              else {return}
        
        let trackerCategory = TrackerCategory(header: header, trackers: [Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)])
        delegate?.didCreateHabit(trackerCategory)
    }
}
