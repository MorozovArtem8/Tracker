//  Created by Artem Morozov on 13.08.2024.

import UIKit

class CreatingNotRegularEventViewController: UIViewController {
    private lazy var scrollView = UIScrollView()
    private let contentView = UIView()
    private lazy var nameTrackerTextField = PaddedTextField()
    private lazy var tableView = UITableView()
    private lazy var cancelButton = UIButton(type: .system)
    private lazy var createButton = UIButton(type: .system)
    private lazy var stackView = UIStackView()
    private lazy var completedDaysLabel = UILabel()
    
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
    
    private var collectionViewData: [CreateTrackerCollectionCellData] = [
        CreateTrackerCollectionCellData(header: "Emoji", type: .emoji(["😀", "😍", "😂","🫥", "🤢", "😾","🫵", "👶", "👚","🦋", "🐞", "🐺","🐭", "🐦", "🐋","🍀", "🍄", "🌪️"])),
        CreateTrackerCollectionCellData(header: "Emoji1", type: .color([UIColor("#FD4C49"), UIColor("#FF881E"),UIColor("#007BFA"), UIColor("#6E44FE"),UIColor("#33CF69"),UIColor("#E66DD4"),UIColor("#F9D4D4"),UIColor("#34A7FE"),UIColor("#46E69D"),UIColor("#35347C"),UIColor("#FF674D"),UIColor("#FF99CC"),UIColor("#F6C48B"),UIColor("#7994F5"),UIColor("#832CF1"),UIColor("#AD56DA"),UIColor("#8D72E6"),UIColor("#2FD058")]))]
    private let geometricParams: GeometricParams
    private let delegate: CreateHabitDelegate?
    private var tableViewData: [CellData] = [CellData(title: "Категория")]
    
    //Если при инициализации передаем tracker значит редактируем уже существующий (открываем экран редактирования), если нет - создаем новый (открываем экран создания)
    private let tracker: TrackerCategory?
    private let trackerCompletedToday: Bool?
    
    private var selectedEmoji: String? {
        didSet {
            updateCreateButtonState()
        }
    }
    
    private var selectedCategoryTitle: String? {
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
        let selectedEmojiIsEmpty = selectedEmoji == nil
        let selectedColorIsEmpry = selectedColor == nil
        let selectedCategoriesTitleIsEmpty = selectedCategoryTitle == nil
        return !nameTrackerTextFieldIsEmpty && !selectedEmojiIsEmpty && !selectedColorIsEmpry && !selectedCategoriesTitleIsEmpty
    }
    
    init(delegate: CreateHabitDelegate) {
        self.delegate = delegate
        self.geometricParams =  GeometricParams(cellCount: 6,leftInset: 18,rightInset: 18,cellSpacing: 5)
        self.tracker = nil
        self.trackerCompletedToday = nil
        super.init(nibName: nil, bundle: nil)
    }
    
    init(delegate: CreateHabitDelegate, trackerCategory: TrackerCategory, trackerCompletedToday: Bool) {
        self.delegate = delegate
        self.geometricParams =  GeometricParams(cellCount: 6,leftInset: 18,rightInset: 18,cellSpacing: 5)
        self.tracker = trackerCategory
        self.trackerCompletedToday = trackerCompletedToday
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let tracker = tracker,
           tracker.trackers.count > 0 {
            self.selectedCategoryTitle = tracker.header
            self.selectedEmoji = tracker.trackers[0].emoji
            self.selectedColor = tracker.trackers[0].color
            self.nameTrackerTextField.text = tracker.trackers[0].name
            self.tableViewData[0].subTitle = tracker.header
        }
        
        configureUI()
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(updateCreateButtonState), name: UITextField.textDidChangeNotification, object: nameTrackerTextField)
        updateCreateButtonState()
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
}

//MARK: UITableViewDataSource func

extension CreatingNotRegularEventViewController: UITableViewDataSource {
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

//MARK: UITableViewDelegate func

extension CreatingNotRegularEventViewController: UITableViewDelegate {
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
        default:
            print("Неизвестная ячейка")
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 16
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

//MARK: CollectionView DataSource

extension CreatingNotRegularEventViewController: UICollectionViewDataSource {
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
            
            if let tracker = tracker,
               tracker.trackers.count > 0,
               emojis[indexPath.row] == tracker.trackers[0].emoji {
                cell.selectCell(select: true)
                self.selectedEmojiIndexPath = indexPath
            }
            
            return cell
        case .color(let colors):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreateTrackerCollectionViewColorCell.identifier, for: indexPath) as? CreateTrackerCollectionViewColorCell else {return UICollectionViewCell()}
            cell.prepareForReuse()
            cell.configureCell(colors[indexPath.row])
            
            if let tracker = tracker,
               tracker.trackers.count > 0,
               colors[indexPath.row] == tracker.trackers[0].color {
                cell.selectCell(select: true)
                self.selectedColorIndexPath = indexPath
            }
            
            return cell
        }
    }
}

//MARK: CollectionView Deleage

extension CreatingNotRegularEventViewController: UICollectionViewDelegate {
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

extension CreatingNotRegularEventViewController: UICollectionViewDelegateFlowLayout {
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

private extension CreatingNotRegularEventViewController {
    func configureUI() {
        view.backgroundColor = .white
        self.title = "Новое нерегулярное событие"
        
        configureScrollView()
        configureCompletedLabel()
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
    
    func configureCompletedLabel() {
        guard let _ = tracker, 
                let trackerCompletedToday
        else {return}
        completedDaysLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(completedDaysLabel)
        
        completedDaysLabel.text = trackerCompletedToday ? "Выполнено" : "Не выполнено"
        completedDaysLabel.textAlignment = .center
        completedDaysLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        
        NSLayoutConstraint.activate([
            completedDaysLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            completedDaysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            completedDaysLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }
    
    func configureNameTrackerTextField() {
        let trackerInitialized = tracker != nil && trackerCompletedToday != nil
        nameTrackerTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTrackerTextField.placeholder = "Введите название трекера"
        nameTrackerTextField.textColor = .black
        nameTrackerTextField.backgroundColor = UIColor("#E6E8EB", alpha: 0.3)
        nameTrackerTextField.textAlignment = .left
        nameTrackerTextField.layer.cornerRadius = 16
        nameTrackerTextField.clipsToBounds = true
        
        contentView.addSubview(nameTrackerTextField)
        
        NSLayoutConstraint.activate([
            nameTrackerTextField.topAnchor.constraint(equalTo: trackerInitialized ? completedDaysLabel.bottomAnchor : contentView.topAnchor, constant: trackerInitialized ? 40 : 24),
            nameTrackerTextField.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameTrackerTextField.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nameTrackerTextField.heightAnchor.constraint(equalToConstant: 75)
            
        ])
    }
    
    func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CreatingHabitTableViewCell.self, forCellReuseIdentifier: CreatingHabitTableViewCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        contentView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: nameTrackerTextField.bottomAnchor, constant: 24),
            tableView.heightAnchor.constraint(equalToConstant: 75),
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
        createButton.setTitleColor(.white, for: .normal)
        createButton.setTitle("Создать", for: .normal)
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        createButton.layer.cornerRadius = 16
        createButton.clipsToBounds = true
        createButton.isEnabled = false
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
        
        if let tracker = tracker,
           tracker.trackers.count > 0 {
            let id = tracker.trackers[0].id
            guard let name = nameTrackerTextField.text,
                  let color = selectedColor,
                  let emoji = selectedEmoji,
                  let header = selectedCategoryTitle
            else {return}
            
            let trackerCategory = TrackerCategory(header: header, trackers: [Tracker(id: id, name: name, color: color, emoji: emoji, isPinned: tracker.trackers[0].isPinned, schedule: [])])
            delegate?.didCreateHabit(trackerCategory)
        } else {
            let id = UUID()
            guard let name = nameTrackerTextField.text,
                  let color = selectedColor,
                  let emoji = selectedEmoji,
                  let header = selectedCategoryTitle
            else {return}
            let trackerCategory = TrackerCategory(header: header, trackers: [Tracker(id: id, name: name, color: color, emoji: emoji, isPinned: false, schedule: [])])
            delegate?.didCreateHabit(trackerCategory)
        }
    }
}
