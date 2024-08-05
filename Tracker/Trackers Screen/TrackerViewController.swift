//  Created by Artem Morozov on 25.07.2024.


import UIKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func trackerCellDidTapPlus(_ cell: TrackerCollectionViewCell)
}

class TrackerViewController: UIViewController, TrackerCollectionViewCellDelegate {
    
    private var categories: [TrackerCategory]
    private var visibleCategories: [TrackerCategory]
    private var completedTrackers: [TrackerRecord]
    
    private let geometricParams: GeometricParams
    
    init() {
        self.geometricParams =  GeometricParams(cellCount: 2,leftInset: 16,rightInset: 16,cellSpacing: 9)
        self.visibleCategories = []
        self.completedTrackers = []
        
        self.categories = [TrackerCategory(header: "Домашний уют", trackers: [Tracker(id: UUID(), name: "Погладить кота", color: UIColor.black, emoji: "😍", schedule: [.Monday])]), TrackerCategory(header: "Радостные мелочи", trackers: [Tracker(id: UUID(), name: "Укусить Кристину", color: UIColor("#9b59b6"), emoji: "🍑", schedule: [.Monday]), Tracker(id: UUID(), name: "Name", color: UIColor.red, emoji: "🥶", schedule: [.Monday]), Tracker(id: UUID(), name: "Name", color: UIColor.systemPink, emoji: "🏄🏾‍♂️", schedule: [.Monday])]), TrackerCategory(header: "Радостные мелочи", trackers: [Tracker(id: UUID(), name: "Name", color: UIColor.cyan, emoji: "🩲", schedule: [.Monday]), Tracker(id: UUID(), name: "Name", color: UIColor.green, emoji: "😀", schedule: [.Monday]), Tracker(id: UUID(), name: "Name", color: UIColor.brown, emoji: "✌️", schedule: [.Monday])])]
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateVisibleCategories(from: Date())
        //categories = [TrackerCategory(header: "Домашний уют", trackers: [Tracker(id: "123", name: "Name", color: UIColor.green, emoji: "😀", schedule: [.Friday])])]
        configureUI()
    }
    
    private func updateVisibleCategories(from date: Date) {
        let dayOfWeek = DaysWeek(from: getDayOfWeek(from: date))
        
        let filteredCategories = categories.filter { categories in
            categories.trackers.contains {
                $0.schedule.contains(where: {$0 == dayOfWeek})
            }
        }
        
        self.visibleCategories = filteredCategories
        print(visibleCategories)
        collectionView.reloadData()
    }
    
    //MARK: Cell tap button plus func
    func trackerCellDidTapPlus(_ cell: TrackerCollectionViewCell) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else {return}
        if completedTrackers.isEmpty {
            completedTrackers.append(TrackerRecord(trackerID: categories[indexPath.section].trackers[indexPath.row].id, dateOfCompletion: Date()))
            cell.trackerStateChange(days: 1, state: .completion)
            print(completedTrackers)
            return
            
        }
        
        if checkCompletionCurrentTrackerToDay(id: categories[indexPath.section].trackers[indexPath.row].id) {
            print("Ячейка есть")
            let dellIndex = completedTrackers.firstIndex { trackerRecord in
                trackerRecord.trackerID == categories[indexPath.section].trackers[indexPath.row].id && Calendar.current.isDate(Date(), inSameDayAs: trackerRecord.dateOfCompletion)
            }
            guard let dellIndex else {return}
            completedTrackers.remove(at: dellIndex)
            
            let trackerCount = getCurrentTrackerCompletedCount(id: categories[indexPath.section].trackers[indexPath.row].id)
            cell.trackerStateChange(days: trackerCount, state: .incompletion)
            
            
        }else {
            print("Ячейки нет")
            completedTrackers.append(TrackerRecord(trackerID: categories[indexPath.section].trackers[indexPath.row].id, dateOfCompletion: Date()))
            
            let trackerCount = getCurrentTrackerCompletedCount(id: categories[indexPath.section].trackers[indexPath.row].id)
            cell.trackerStateChange(days: trackerCount, state: .completion)
        }
        print(completedTrackers)
        
    }
    
    private func getCurrentTrackerCompletedCount(id: UUID) -> Int {
        completedTrackers.reduce(0) { partialResult, trackerRecord in
            if trackerRecord.trackerID == id {
                return partialResult + 1
            }
            return partialResult
        }
        
    }
    
    private func checkCompletionCurrentTrackerToDay(id: UUID) -> Bool {
        return completedTrackers.contains { tracker in
            tracker.trackerID == id && Calendar.current.isDate(Date(), inSameDayAs: tracker.dateOfCompletion)
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
        
        if checkCompletionCurrentTrackerToDay(id: visibleCategories[indexPath.section].trackers[indexPath.row].id) {
            let trackerCount = getCurrentTrackerCompletedCount(id: categories[indexPath.section].trackers[indexPath.row].id)
            cell?.trackerStateChange(days: trackerCount, state: .completion)
        }else {
            let trackerCount = getCurrentTrackerCompletedCount(id: categories[indexPath.section].trackers[indexPath.row].id)
            cell?.trackerStateChange(days: trackerCount, state: .incompletion)
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
        let searchText = searchController.searchBar.text ?? ""
    }
    
    
}

//MARK: Configure UI
private extension TrackerViewController {
    func configureUI() {
        view.backgroundColor = .white
        addNavigationItems()
        configureCollectionView()
        //configureEmptyTrackerImageAndLabel()
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        updateVisibleCategories(from: selectedDate)
        let dayOfWeek = getDayOfWeek(from: selectedDate)
        
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
        print("Plus button tapped")
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
    
    func configureSearchBar() {
        
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
