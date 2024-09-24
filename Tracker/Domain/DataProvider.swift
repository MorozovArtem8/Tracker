//  Created by Artem Morozov on 26.08.2024.

import UIKit
import CoreData

protocol DataProviderDelegate: AnyObject {
    func didUpdate()
}

protocol DataProviderProtocol {
    func addTrackerCategory(categoryHeader: String)
    func addTracker(categoryHeader: String, tracker: Tracker)
    
    func getAllTrackerCategory() -> [TrackerCategory]?
    func pinnedTracker(id: UUID)
    func getCategoryTitleForTrackerId(id: UUID) -> String?
    
    func addNewRecord(tracker: Tracker, trackerRecord: TrackerRecord) throws
    func getAllRecords() -> [TrackerRecord]
    func removeRecord(tracker: Tracker, trackerRecord: TrackerRecord) throws
}

final class DataProvider: NSObject {
    
    enum DataProviderError: Error {
        case failedToInitializeContext
    }
    
    private lazy var trackerCategoryStore: TrackerCategoryStoreProtocol? = {
        guard let delegate = delegate else {return nil}
        trackerCategoryStore = TrackerCategoryStore(context: self.context, delegate: delegate)
        return trackerCategoryStore
        
    }()
    private lazy var trackerStore: TrackerStoreProtocol = TrackerStore(context: self.context)
    private lazy var trackerRecordStore: TrackerRecordStoreProtocol = TrackerRecordStore(context: self.context)
    
    private weak var delegate: DataProviderDelegate?
    private let context: NSManagedObjectContext
    
    init(delegate: DataProviderDelegate) throws {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let context = appDelegate.persistentContainer?.viewContext else {throw DataProviderError.failedToInitializeContext}
        
        self.context = context
        self.delegate = delegate
    }
}

// MARK: - DataProviderProtocol

extension DataProvider: DataProviderProtocol {
    func getCategoryTitleForTrackerId(id: UUID) -> String? {
        return trackerStore.getCategoryTitleForTrackerId(id: id)
    }
    
    func pinnedTracker(id: UUID) {
        trackerStore.pinnedTracker(id: id)
        delegate?.didUpdate()
    }
    
    func addNewRecord(tracker: Tracker, trackerRecord: TrackerRecord) throws {
        if let trackerCoreDataIsExist = trackerStore.getTrackerCoreDataForId(id: tracker.id) {
            try? trackerRecordStore.addNewRecord(trackerCoreData: trackerCoreDataIsExist, trackerRecord: trackerRecord)
        }
    }
    
    func getAllRecords() -> [TrackerRecord] {
        guard let trackerRecords = trackerRecordStore.getAllRecords() else  {return []}
        return trackerRecords
    }
    
    func removeRecord(tracker: Tracker, trackerRecord: TrackerRecord) throws {
        try trackerRecordStore.removeRecord(tracker: tracker, trackerRecord: trackerRecord)
    }
    
    func addTrackerCategory(categoryHeader: String) {
        guard let trackerCategoryStore else {return}
        trackerCategoryStore.addTrackerCategory(categoryHeader: categoryHeader)
    }
    
    func addTracker(categoryHeader: String, tracker: Tracker) {
        guard let trackerCategoryStore else {return}
        //Если такая категория уже есть добавляем трекеры в имющуюся
        if let categoryIsExist = trackerCategoryStore.checkCategoryExistence(categoryHeader: categoryHeader) {
            do {
                try trackerStore.addNewTracker(category: categoryIsExist, tracker: tracker)
                print("Трекер добавлен в существующую категорию")
            } catch {
                print("Не удалось добавить трекер к категории")
            }
            delegate?.didUpdate()
            return
        } else {
            // Иначе создаем новую
            let trackerCategory = TrackerCategoryCoreData(context: self.context)
            trackerCategory.header = categoryHeader
            try? context.save()
            do {
                try trackerStore.addNewTracker(category: trackerCategory, tracker: tracker)
                print("Новая категория и трекер добавлены")
            } catch {
                print("Не удалось добавить трекер к категории")
            }
        }
        
    }
    
    func getAllTrackerCategory() -> [TrackerCategory]? {
        guard let trackerCategoryStore else {return nil}
        return trackerCategoryStore.getAllTrackerCategory()
    }
}
