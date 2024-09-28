//  Created by Artem Morozov on 25.07.2024.

import UIKit

protocol CreateHabitDelegate: AnyObject {
    func didCreateHabit(_ newTrackerCategory: TrackerCategory)
}

protocol TrackerTypeSelectionDelegate: AnyObject {
    func didSelectTrackerType(_ vc: UIViewController,trackerType: TrackerType)
}

class TrackerViewController: UIViewController, TrackerCollectionViewCellDelegate {
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
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
        return imageView
    }()
    
    private lazy var emptyTrackerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private lazy var filterButton = UIButton()
    
    private let statisticService: StatisticService = StatisticServiceImplementation()
    private let filterStateSavingService: FilterStateSavingService = FilterStateSavingServiceImplementation()
    private let colorMarshalling = UIColorMarshalling()
    private var categories: [TrackerCategory] = [] {
        didSet {
            statisticService.store(allTrackerCategories: categories, allTrackerRecords: completedTrackers)
        }
    }
    private var visibleCategories: [TrackerCategory] = [] {
        didSet {
            filteredCategories = visibleCategories
        }
    }
    private var filteredCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = [] {
        didSet {
            statisticService.store(allTrackerCategories: categories, allTrackerRecords: completedTrackers)
        }
    }
    private var currentDate = Date()
    private lazy var dataProvider: DataProviderProtocol? = {
        do {
            try dataProvider = DataProvider(delegate: self)
            return dataProvider
        }
        catch {
            print("Не удалось инициализировать dataProvider")
            return nil
        }
    }()
    
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
        
        guard let dataProvider,
              let categoryIsExists = dataProvider.getAllTrackerCategory() else {return}
        
        self.completedTrackers = dataProvider.getAllRecords()
        self.categories = categoryIsExists
        updateVisibleCategories(from: Date())
        configureUI()
    }
    
    private func updateVisibleCategories(from date: Date) {
        
        let currentFilterState = filterStateSavingService.currentFilterState
        
        let dayOfWeek = DaysWeek(from: getDayOfWeek(from: date))
        var isPinnedTrackers: [Tracker] = []
        
        displayFilterButton(for: date)
    
        var filteredCategories = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                if tracker.isPinned {
                    isPinnedTrackers.append(tracker)
                    return false
                }
                let matchesSchedule = tracker.schedule.contains(where: {$0 == dayOfWeek})
                let firstCompletedTracker = completedTrackers.first { trackerRecord in
                    trackerRecord.trackerID == tracker.id && tracker.schedule.isEmpty
                }
                
                let currentStartOfDay = Calendar.current.startOfDay(for: currentDate)
                let firstCompletedTrackerStartOfDay = Calendar.current.startOfDay(for: firstCompletedTracker?.dateOfCompletion ?? Date())
                
                switch currentFilterState {
                case 2:
                    return (matchesSchedule || tracker.schedule.isEmpty) && completedTrackers.contains(where: {
                        currentStartOfDay == Calendar.current.startOfDay(for: $0.dateOfCompletion) &&
                        $0.trackerID == tracker.id
                    })
                    
                case 3:
                    return (matchesSchedule && !completedTrackers.contains(where: {
                        currentStartOfDay == Calendar.current.startOfDay(for: $0.dateOfCompletion) &&
                        $0.trackerID == tracker.id
                    })) || (tracker.schedule.isEmpty && !completedTrackers.contains(where: {
                        $0.trackerID == tracker.id
                    }))
                    
                default:
                    return
                    // - Показываем трекеры расписание которых соответствует выбранному дню,
                    matchesSchedule ||
                    // - Выполненные трекеры (нерегулярные события (без расписания) показываем только для даты выполнения)
                    (firstCompletedTracker != nil && currentStartOfDay == firstCompletedTrackerStartOfDay) ||
                    // - Пустые нерегулярные события которые еще не выполнены показываем для всех дней
                    (firstCompletedTracker == nil && tracker.schedule.isEmpty)
                }
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(header: category.header, trackers: filteredTrackers)
        }
        
        if !isPinnedTrackers.isEmpty {
            let isPinnedTrackersCategory = TrackerCategory(header: "Закрепленные", trackers: isPinnedTrackers)
            filteredCategories.insert(isPinnedTrackersCategory, at: 0)
            self.visibleCategories = filteredCategories
        } else {
            self.visibleCategories = filteredCategories
        }
        
        guard let allTrackers = dataProvider?.getAllTrackers().isEmpty else {return}
        
        if allTrackers {
            displayStubForEmptyScrollView(displayStub: true, stubType: .emptyCollection)
        } else {
            let displayTrackersIsEmpty = visibleCategories.isEmpty
            displayStubForEmptyScrollView(displayStub: displayTrackersIsEmpty, stubType: .emptySearchResult)
        }
        
        collectionView.reloadData()
    }
    
    private func displayFilterButton(for currentDate: Date) {
        let currentFilterState = filterStateSavingService.currentFilterState
        filterButton.setTitleColor((1...3).contains(currentFilterState) ? .systemRed : .white, for: .normal)
        let dayOfWeek = DaysWeek(from: getDayOfWeek(from: currentDate))
        var trackers: [Tracker] = []
        
        for category in categories {
            for tracker in category.trackers {
                if tracker.schedule.contains(where: {
                    $0 == dayOfWeek
                }) || (tracker.schedule.isEmpty && (completedTrackers.contains(where: {
                    return tracker.id == $0.trackerID && (Calendar.current.startOfDay(for: currentDate) == Calendar.current.startOfDay(for: $0.dateOfCompletion))
                }) || !completedTrackers.contains(where: {$0.trackerID == tracker.id}))){
                    trackers.append(tracker)
                }
            }
        }
        
        filterButton.isHidden = trackers.isEmpty ? true : false
    }
    
    private func displayStubForEmptyScrollView(displayStub: Bool, stubType: StubType) {
        emptyTrackerImage.isHidden = !displayStub
        emptyTrackerLabel.isHidden = !displayStub
        switch stubType {
        case .emptySearchResult:
            emptyTrackerImage.image = UIImage(named: "emptySearchResult")
            emptyTrackerLabel.text = "Ничего не найдено"
        case .emptyCollection:
            emptyTrackerImage.image = UIImage(named: "emptyTracker")
            emptyTrackerLabel.text = "Что будем отслеживать?"
        }
    }
    
    //MARK: Cell delegate func
    
    func cellButtonDidTapped(_ cell: TrackerCollectionViewCell) {
        guard let dataProvider, Calendar.current.compare(Date(), to: currentDate, toGranularity: .day) != .orderedAscending else {return}
        
        completedTrackers = dataProvider.getAllRecords()
        guard let indexPath = collectionView.indexPath(for: cell) else {return}
        
        //Проверяем является ли трекер НЕрегулярным событием и если ранее событие уже было выполнено убираем выполнение и выходим
        //Данная проверка нужна для кейса с закрепленными нерегулярными событиями
        let thisTrackerIsNotRegularEvent = filteredCategories[indexPath.section].trackers[indexPath.row].schedule.isEmpty
        if thisTrackerIsNotRegularEvent, getCurrentTrackerCompletedCount(id: filteredCategories[indexPath.section].trackers[indexPath.row].id) > 0 {
            removeCompletedTracker(cell)
            updateVisibleCategories(from: currentDate)
            return
        }
        
        // Проверяем был ли выполнен трекер сегодня
        if !checkCompletionCurrentTrackerToday(id: filteredCategories[indexPath.section].trackers[indexPath.row].id) {
            completeTracker(cell)
        } else {
            removeCompletedTracker(cell)
        }
        updateVisibleCategories(from: currentDate)
    }
    
    func completeTracker(_ cell: TrackerCollectionViewCell) {
        //Тут проверяем является ли текущая дата меньше currentDate что бы не позволять пользователю отмечать будущие даты
        let currentDateIsNotFuture = Calendar.current.compare(Date(), to: currentDate, toGranularity: .day) != .orderedAscending
        guard let indexPath = collectionView.indexPath(for: cell),
              currentDateIsNotFuture, let dataProvider else {return}
        
        let currentTracker = filteredCategories[indexPath.section].trackers[indexPath.row]
        let currentTrackerID = filteredCategories[indexPath.section].trackers[indexPath.row].id
        
        do {
            try dataProvider.addNewRecord(tracker: currentTracker, trackerRecord: TrackerRecord(trackerID: currentTrackerID, dateOfCompletion: currentDate))
            completedTrackers = dataProvider.getAllRecords()
            
            let trackerCount = getCurrentTrackerCompletedCount(id: filteredCategories[indexPath.section].trackers[indexPath.row].id)
            let trackerCompletedToday = checkCompletionCurrentTrackerToday(id: filteredCategories[indexPath.section].trackers[indexPath.row].id)
            let trackerType = filteredCategories[indexPath.section].trackers[indexPath.row].schedule.isEmpty ? TrackerType.notRegularEvent : TrackerType.habit
            
            cell.trackerStateChange(days: trackerCount, trackerCompletedToday: trackerCompletedToday, trackerType: trackerType)
        }
        catch {
            print("Не удалось сохранить TrackerRecord")
        }
        
    }
    
    func removeCompletedTracker(_ cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell),
              let dataProvider else {return}
        
        let currentTracker = filteredCategories[indexPath.section].trackers[indexPath.row]
        let currentTrackerID = filteredCategories[indexPath.section].trackers[indexPath.row].id
        
        do {
            try dataProvider.removeRecord(tracker: currentTracker, trackerRecord: TrackerRecord(trackerID: currentTrackerID, dateOfCompletion: currentDate))
            completedTrackers = dataProvider.getAllRecords()
            
            let trackerCount = getCurrentTrackerCompletedCount(id: currentTrackerID)
            let trackerCompletedToday = checkCompletionCurrentTrackerToday(id: currentTrackerID)
            let trackerType = filteredCategories[indexPath.section].trackers[indexPath.row].schedule.isEmpty ? TrackerType.notRegularEvent : TrackerType.habit
            
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
}

//MARK: UICollectionViewDataSource func

extension TrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.identifier, for: indexPath) as? TrackerCollectionViewCell
        cell?.prepareForReuse()
        
        let cellName = filteredCategories[indexPath.section].trackers[indexPath.row].name
        let cellEmoji = filteredCategories[indexPath.section].trackers[indexPath.row].emoji
        let cellColor = filteredCategories[indexPath.section].trackers[indexPath.row].color
        let cellIsPinned = filteredCategories[indexPath.section].trackers[indexPath.row].isPinned
        cell?.configureCell(name: cellName, emoji: cellEmoji, color: cellColor, delegate: self, trackerIsPin: cellIsPinned)
        
        if checkCompletionCurrentTrackerToday(id: filteredCategories[indexPath.section].trackers[indexPath.row].id) {
            let trackerCount = getCurrentTrackerCompletedCount(id: filteredCategories[indexPath.section].trackers[indexPath.row].id)
            let trackerCompletedToday = checkCompletionCurrentTrackerToday(id: filteredCategories[indexPath.section].trackers[indexPath.row].id)
            let trackerType = filteredCategories[indexPath.section].trackers[indexPath.row].schedule.isEmpty ? TrackerType.notRegularEvent : TrackerType.habit
            
            cell?.trackerStateChange(days: trackerCount, trackerCompletedToday: trackerCompletedToday, trackerType: trackerType)
        }else {
            let trackerCount = getCurrentTrackerCompletedCount(id: filteredCategories[indexPath.section].trackers[indexPath.row].id)
            let trackerCompletedToday = checkCompletionCurrentTrackerToday(id: filteredCategories[indexPath.section].trackers[indexPath.row].id)
            let trackerType = filteredCategories[indexPath.section].trackers[indexPath.row].schedule.isEmpty ? TrackerType.notRegularEvent : TrackerType.habit
            
            cell?.trackerStateChange(days: trackerCount, trackerCompletedToday: trackerCompletedToday, trackerType: trackerType)
        }
        
        return cell ?? UICollectionViewCell()
    }
}

//MARK: UICollectionViewDelegate func

extension TrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPaths.count > 0 else {return nil}
        
        let indexPath = indexPaths[0]
        let trackerIsPinned = filteredCategories[indexPath.section].trackers[indexPath.row].isPinned
        return UIContextMenuConfiguration(actionProvider:  { action in
            return UIMenu(children: [
                
                UIAction(title: trackerIsPinned ? "Открепить" : "Закрепить") { [weak self] _ in
                    guard let self = self else {return}
                    let id = self.filteredCategories[indexPath.section].trackers[indexPath.row].id
                    
                    self.dataProvider?.pinnedTracker(id: id)
                    self.categories = self.dataProvider?.getAllTrackerCategory() ?? []
                    updateVisibleCategories(from: currentDate)
                },
                
                UIAction(title: "Редактировать") { [weak self] _ in
                    guard let self = self else {return}
                    let currentTracker = filteredCategories[indexPath.section].trackers[indexPath.row]
                    let currentTrackerArray: [Tracker] = [currentTracker]
                    // если в трекере есть расписание(schedule) - открываем экран привычек если нет - нерегулярное событие
                    let openEditHabitViewController = !currentTracker.schedule.isEmpty
                    //получение оригинального title через метод getCategoryTitleForTrackerId используется для корректного передачи title если трекер закреплен
                    guard let categoryTitle = dataProvider?.getCategoryTitleForTrackerId(id: currentTracker.id) else {return}
                    
                    let currentTrackerCategory = TrackerCategory(header: categoryTitle, trackers: currentTrackerArray)
                    let vc = openEditHabitViewController ?
                    EditHabitViewController(delegate: self, trackerCategory: currentTrackerCategory, daysCompleted: getCurrentTrackerCompletedCount(id: currentTracker.id)) : EditNotRegularEventScreen(delegate: self, trackerCategory: currentTrackerCategory, trackerCompletedToday: checkCompletionCurrentTrackerToday(id: currentTracker.id))
                    let navigationController = UINavigationController(rootViewController: vc)
                    
                    let textAttributes: [NSAttributedString.Key: Any] = [
                        .foregroundColor: UIColor.black,
                        .font: UIFont.systemFont(ofSize: 16, weight: .medium)
                    ]
                    navigationController.navigationBar.titleTextAttributes = textAttributes
                    present(navigationController, animated: true)
                    
                },
                
                UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                    guard let self = self else {return}
                    
                    let alert = UIAlertController(title: nil, message: "Уверены что хотите удалить трекер?", preferredStyle: .actionSheet)
                    let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { action in
                        let currentTrackerId = self.filteredCategories[indexPath.section].trackers[indexPath.row].id
                        self.dataProvider?.removeTracker(id: currentTrackerId)
                       }
                    let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { action in
                            print("Нажата кнопка Отмена")
                        }
                    alert.addAction(deleteAction)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                    
                    
                }
            ])
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Тап по ячейки")
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? HeaderSupplementaryView
        view?.titleLabel.text = filteredCategories[indexPath.section].header
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
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            let filteredCategories = visibleCategories.compactMap { category in
                let filteredTrackers = category.trackers.filter { tracker in
                    tracker.name.lowercased().contains(searchText.lowercased())
                }
                return filteredTrackers.isEmpty ? nil : TrackerCategory(header: category.header, trackers: filteredTrackers)
            }
            let oldVisibleCategories = self.filteredCategories
            self.filteredCategories = filteredCategories
            displayStubForEmptyScrollView(displayStub: filteredCategories.count == 0, stubType: .emptySearchResult)
            collectionView.performBatchUpdates({
                for (sectionIndex, oldCategory) in oldVisibleCategories.enumerated() {
                    if !filteredCategories.contains(where: {$0.header == oldCategory.header}) {
                        collectionView.deleteSections(IndexSet(integer: sectionIndex))
                    } else {
                        let oldTrackers = oldCategory.trackers
                        let newTrackers = filteredCategories.first(where: {$0.header == oldCategory.header})?.trackers ?? []
                        let trackersToDelete = oldTrackers.enumerated().compactMap{(index, tracker) in
                            return !newTrackers.contains(where: { $0.name == tracker.name }) ? IndexPath(item: index, section: sectionIndex) : nil
                        }
                        
                        if !trackersToDelete.isEmpty {
                            collectionView.deleteItems(at: trackersToDelete)
                        }
                    }
                }
                
                for (sectionIndex, newCategory) in filteredCategories.enumerated() {
                    if !oldVisibleCategories.contains(where: { $0.header == newCategory.header }) {
                        collectionView.insertSections(IndexSet(integer: sectionIndex))
                    } else {
                        let oldTrackers = oldVisibleCategories.first(where: { $0.header == newCategory.header })?.trackers ?? []
                        let newTrackers = newCategory.trackers
                        
                        let trackersToInsert = newTrackers.enumerated().compactMap { (index, tracker) in
                            return !oldTrackers.contains(where: { $0.name == tracker.name }) ? IndexPath(item: index, section: sectionIndex) : nil
                        }
                        
                        if !trackersToInsert.isEmpty {
                            collectionView.insertItems(at: trackersToInsert)
                        }
                    }
                }
            })
        } else {
            updateVisibleCategories(from: currentDate)
        }
    }
}

extension TrackerViewController: CreateHabitDelegate {
    func didCreateHabit(_ newTrackerCategory: TrackerCategory) {
        guard let tracker = newTrackerCategory.trackers.first,
              let dataProvider else {return}
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
        guard let dataProvider,
              let categoryIsExists = dataProvider.getAllTrackerCategory()else {return}
        
        self.completedTrackers = dataProvider.getAllRecords()
        self.categories = categoryIsExists
        updateVisibleCategories(from: currentDate)
    }
}

//MARK: Filters func

extension TrackerViewController {
    func filtersDidUpdate(activeFilters: Int) {
        switch activeFilters {
        case 1:
            currentDate = Date()
            datePicker.date = currentDate
            updateVisibleCategories(from: currentDate)
        default:
            updateVisibleCategories(from: currentDate)
        }
    }
}

//MARK: Configure UI

private extension TrackerViewController {
    func configureUI() {
        view.backgroundColor = .white
        addNavigationItems()
        configureCollectionView()
        configureEmptyTrackerImageAndLabel()
        configureFilterButton()
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
        plusButton.tintColor = UIColor(named: "CustomBackgroundColor")
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
    
    func configureFilterButton() {
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.backgroundColor = UIColor("#3772E7")
        filterButton.setTitle("Фильтры", for: .normal)
        filterButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        filterButton.layer.cornerRadius = 16
        filterButton.clipsToBounds = true
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        
        view.addSubview(filterButton)
        
        NSLayoutConstraint.activate([
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            
        ])
        
    }
    
    @objc func filterButtonTapped() {
        let filterViewController = FiltersViewController { [weak self] value in
            self?.filtersDidUpdate(activeFilters: value)
        }
        let navigationController = UINavigationController(rootViewController: filterViewController)
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        navigationController.navigationBar.titleTextAttributes = textAttributes
        present(navigationController, animated: true)
    }
}
