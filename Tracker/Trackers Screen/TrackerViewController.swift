//  Created by Artem Morozov on 25.07.2024.

import UIKit

protocol CreateHabitDelegate: AnyObject {
    func didCreateHabit(_ newTrackerCategory: TrackerCategory)
}

protocol TrackerTypeSelectionDelegate: AnyObject {
    func didSelectTrackerType(_ vc: UIViewController,trackerType: TrackerType)
}

class TrackerViewController: UIViewController, TrackerCollectionViewCellDelegate {
    private lazy var dataProvider: DataProviderProtocol = DataProvider(delegate: self)
    
    private let colorMarshalling = UIColorMarshalling()
    
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate = Date()
    
    private let geometricParams: GeometricParams
    
    init() {
        self.geometricParams =  GeometricParams(cellCount: 2,leftInset: 16,rightInset: 16,cellSpacing: 9) //Задаем параметры коллекции трекеров
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.completedTrackers = dataProvider.getAllRecords()
        self.categories = dataProvider.getAllTrackerCategory()
        updateVisibleCategories(from: Date())
        configureUI()
    }
    
    private func updateVisibleCategories(from date: Date) {
        
        let dayOfWeek = DaysWeek(from: getDayOfWeek(from: date))
        
        let filteredCategories = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                let matchesSchedule = tracker.schedule.contains(where: {$0 == dayOfWeek})
                let firstCompletedTracker = completedTrackers.first { trackerRecord in
                    trackerRecord.trackerID == tracker.id && tracker.schedule.isEmpty
                }
                
                let currentStartOfDay = Calendar.current.startOfDay(for: currentDate)
                let firstCompletedTrackerStartOfDay = Calendar.current.startOfDay(for: firstCompletedTracker?.dateOfCompletion ?? Date())
                
                return
                // - Показываем трекеры расписание которых соответствует выбранному дню,
                matchesSchedule ||
                // - Выполненные трекеры (нерегулярные события (без расписания) показываем только для даты выполнения)
                (firstCompletedTracker != nil && currentStartOfDay == firstCompletedTrackerStartOfDay) ||
                // - Пустые нерегулярные события которые еще не выполнены показываем для всех дней
                (firstCompletedTracker == nil && tracker.schedule.isEmpty)
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(header: category.header, trackers: filteredTrackers)
        }
        
        displayStubForEmptyScrollView(displayStub: filteredCategories.count == 0)
        self.visibleCategories = filteredCategories
        collectionView.reloadData()
    }
    
    private func displayStubForEmptyScrollView(displayStub: Bool) {
        emptyTrackerImage.isHidden = !displayStub
        emptyTrackerLabel.isHidden = !displayStub
        
    }
    
    //MARK: Cell delegate func
    func cellButtonDidTapped(_ cell: TrackerCollectionViewCell) {
        guard Calendar.current.compare(Date(), to: currentDate, toGranularity: .day) != .orderedAscending else {return}
        
        completedTrackers = dataProvider.getAllRecords()
        guard let indexPath = collectionView.indexPath(for: cell) else {return}
        // Проверяем был ли выполнен трекер сегодня
        if !checkCompletionCurrentTrackerToday(id: visibleCategories[indexPath.section].trackers[indexPath.row].id) {
            completeTracker(cell)
        } else {
            removeCompletedTracker(cell)
        }
    }
    
    func completeTracker(_ cell: TrackerCollectionViewCell) {
        //Тут проверяем является ли текущая дата меньше currentDate что бы не позволять пользователю отмечать будущие даты
        let currentDateIsNotFuture = Calendar.current.compare(Date(), to: currentDate, toGranularity: .day) != .orderedAscending
        guard let indexPath = collectionView.indexPath(for: cell),
              currentDateIsNotFuture else {return}
        
        let currentTracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let currentTrackerID = visibleCategories[indexPath.section].trackers[indexPath.row].id
        
        do {
            try dataProvider.addNewRecord(tracker: currentTracker, trackerRecord: TrackerRecord(trackerID: currentTrackerID, dateOfCompletion: currentDate))
            completedTrackers = dataProvider.getAllRecords()
            
            let trackerCount = getCurrentTrackerCompletedCount(id: visibleCategories[indexPath.section].trackers[indexPath.row].id)
            let trackerCompletedToday = checkCompletionCurrentTrackerToday(id: visibleCategories[indexPath.section].trackers[indexPath.row].id)
            let trackerType = visibleCategories[indexPath.section].trackers[indexPath.row].schedule.isEmpty ? TrackerType.notRegularEvent : TrackerType.habit
            
            cell.trackerStateChange(days: trackerCount, trackerCompletedToday: trackerCompletedToday, trackerType: trackerType)
        }
        catch {
            print("Не удалось сохранить TrackerRecord")
        }
        
    }
    
    func removeCompletedTracker(_ cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {return}
        
        let currentTracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let currentTrackerID = visibleCategories[indexPath.section].trackers[indexPath.row].id
        
        do {
            try dataProvider.removeRecord(tracker: currentTracker, trackerRecord: TrackerRecord(trackerID: currentTrackerID, dateOfCompletion: currentDate))
            completedTrackers = dataProvider.getAllRecords()
            
            let trackerCount = getCurrentTrackerCompletedCount(id: currentTrackerID)
            let trackerCompletedToday = checkCompletionCurrentTrackerToday(id: currentTrackerID)
            let trackerType = visibleCategories[indexPath.section].trackers[indexPath.row].schedule.isEmpty ? TrackerType.notRegularEvent : TrackerType.habit
            
            cell.trackerStateChange(days: trackerCount, trackerCompletedToday: trackerCompletedToday, trackerType: trackerType)
        }
        catch {
            print("Не удалось удалить TrackerRecord")
        }
        
        
    }
    
    // Сколько раз(дней) трекер был выполнен
    private func getCurrentTrackerCompletedCount(id: UUID) -> Int {
        completedTrackers.reduce(0) { count, trackerRecord in
            if trackerRecord.trackerID == id {
                return count + 1
            }
            return count
        }
    }
    // Проверяет был ли трекер выполнен сегодня
    private func checkCompletionCurrentTrackerToday(id: UUID) -> Bool {
        return completedTrackers.contains { tracker in
            tracker.trackerID == id && Calendar.current.isDate(currentDate, inSameDayAs: tracker.dateOfCompletion)
        }
    }
    
    
    //MARK: UI Elements
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
        collectionView.register(HeaderSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        return collectionView
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        
        let currentDate = Date()
        let calendar = Calendar.current
        let minDate = calendar.date(byAdding: .year, value: -1, to: currentDate)
        let maxDate = calendar.date(byAdding: .year, value: 1, to: currentDate)
        datePicker.minimumDate = minDate
        datePicker.maximumDate = maxDate
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        return searchController
    }()
    
    private lazy var emptyTrackerImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "emptyTracker")
        return imageView
    }()
    
    private lazy var emptyTrackerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "Что будем отслеживать?"
        return label
    }()
}
//MARK: UICollectionViewDataSource func
extension TrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.identifier, for: indexPath) as? TrackerCollectionViewCell
        cell?.prepareForReuse()
        
        let cellName = visibleCategories[indexPath.section].trackers[indexPath.row].name
        let cellEmoji = visibleCategories[indexPath.section].trackers[indexPath.row].emoji
        let cellColor = visibleCategories[indexPath.section].trackers[indexPath.row].color
        cell?.configureCell(name: cellName, emoji: cellEmoji, color: cellColor, delegate: self)
        
        if checkCompletionCurrentTrackerToday(id: visibleCategories[indexPath.section].trackers[indexPath.row].id) {
            let trackerCount = getCurrentTrackerCompletedCount(id: visibleCategories[indexPath.section].trackers[indexPath.row].id)
            let trackerCompletedToday = checkCompletionCurrentTrackerToday(id: visibleCategories[indexPath.section].trackers[indexPath.row].id)
            let trackerType = visibleCategories[indexPath.section].trackers[indexPath.row].schedule.isEmpty ? TrackerType.notRegularEvent : TrackerType.habit
            
            cell?.trackerStateChange(days: trackerCount, trackerCompletedToday: trackerCompletedToday, trackerType: trackerType)
        }else {
            let trackerCount = getCurrentTrackerCompletedCount(id: visibleCategories[indexPath.section].trackers[indexPath.row].id)
            let trackerCompletedToday = checkCompletionCurrentTrackerToday(id: visibleCategories[indexPath.section].trackers[indexPath.row].id)
            let trackerType = visibleCategories[indexPath.section].trackers[indexPath.row].schedule.isEmpty ? TrackerType.notRegularEvent : TrackerType.habit
            
            cell?.trackerStateChange(days: trackerCount, trackerCompletedToday: trackerCompletedToday, trackerType: trackerType)
        }
        
        return cell ?? UICollectionViewCell()
    }
    
    
}
//MARK: UICollectionViewDelegate func
extension TrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Тап по ячейки")
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? HeaderSupplementaryView
        view?.titleLabel.text = visibleCategories[indexPath.section].header
        return view ?? UICollectionReusableView()
    }
    
}

//MARK: UICollectionViewFlowLayout func
extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 19)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - geometricParams.paddingWidth
        let cellWidth = availableWidth / CGFloat(geometricParams.cellCount)
        return CGSize(width: cellWidth, height: cellWidth * 0.9)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: geometricParams.leftInset, bottom: 12, right: geometricParams.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        geometricParams.cellSpacing
    }
}
//MARK: UISearchResultsUpdating func
extension TrackerViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        //let searchText = searchController.searchBar.text ?? ""
    }
}

extension TrackerViewController: CreateHabitDelegate {
    func didCreateHabit(_ newTrackerCategory: TrackerCategory) {
        guard let tracker = newTrackerCategory.trackers.first else {return}
        dataProvider.addTracker(categoryHeader: newTrackerCategory.header, tracker: tracker)
    }
}

extension TrackerViewController: TrackerTypeSelectionDelegate {
    func didSelectTrackerType(_ vc: UIViewController,trackerType: TrackerType) {
        vc.dismiss(animated: true)
        switch trackerType {
        case .habit:
            let creatingHabitViewController = CreatingHabitViewController(delegate: self)
            let navigationController = UINavigationController(rootViewController: creatingHabitViewController)
            
            let textAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 16, weight: .medium)
            ]
            navigationController.navigationBar.titleTextAttributes = textAttributes
            present(navigationController, animated: true)
            
        case .notRegularEvent:
            let creatingNotRegularEventViewController = CreatingNotRegularEventViewController(delegate: self)
            let navigationController = UINavigationController(rootViewController: creatingNotRegularEventViewController)
            
            let textAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 16, weight: .medium)
            ]
            navigationController.navigationBar.titleTextAttributes = textAttributes
            present(navigationController, animated: true)
        }
    }
}

//MARK: DataProviderDelegate
extension TrackerViewController: DataProviderDelegate {
    func didUpdate() {
        self.categories = dataProvider.getAllTrackerCategory()
        updateVisibleCategories(from: currentDate)
    }
    
}

//MARK: Configure UI
private extension TrackerViewController {
    func configureUI() {
        view.backgroundColor = .white
        addNavigationItems()
        configureCollectionView()
        configureEmptyTrackerImageAndLabel()
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        self.currentDate = sender.date
        updateVisibleCategories(from: currentDate)
        let dayOfWeek = getDayOfWeek(from: currentDate)
        print(dayOfWeek)
    }
    
    func getDayOfWeek(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_En") // Устанавливаем локаль на русский
        dateFormatter.dateFormat = "EEEE" // Формат дня недели
        
        let dayOfWeek = dateFormatter.string(from: date)
        return dayOfWeek
    }
    
    func addNavigationItems() {
        let plusButton = UIBarButtonItem(image: UIImage(named: "plus"), style: .plain, target: self, action: #selector(plusButtonTapped))
        plusButton.tintColor = UIColor("#1A1B22")
        self.navigationItem.leftBarButtonItem = plusButton
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
    @objc func plusButtonTapped() {
        let creatingTrackerViewController = CreatingTrackerViewController(delegate: self)
        let navigationController = UINavigationController(rootViewController: creatingTrackerViewController)
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        navigationController.navigationBar.titleTextAttributes = textAttributes
        present(navigationController, animated: true)
    }
    
    func configureEmptyTrackerImageAndLabel() {
        emptyTrackerImage.translatesAutoresizingMaskIntoConstraints = false
        emptyTrackerLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.addSubview(emptyTrackerImage)
        collectionView.addSubview(emptyTrackerLabel)
        
        NSLayoutConstraint.activate([
            emptyTrackerImage.centerXAnchor.constraint(equalTo: collectionView.safeAreaLayoutGuide.centerXAnchor),
            emptyTrackerImage.centerYAnchor.constraint(equalTo: collectionView.safeAreaLayoutGuide.centerYAnchor),
            emptyTrackerLabel.topAnchor.constraint(equalTo: emptyTrackerImage.bottomAnchor, constant: 8),
            emptyTrackerLabel.centerXAnchor.constraint(equalTo: emptyTrackerImage.centerXAnchor)
        ])
    }
    
    func configureCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}
