//  Created by Artem Morozov on 26.08.2024.

import UIKit
import CoreData

protocol DataProviderDelegate: AnyObject {
    func didUpdate()
}

protocol DataProviderProtocol {
    func addTracker(categoryHeader: String)
    func addTracker(categoryHeader: String, tracker: Tracker)
    
    func getAllTrackerCategory() -> [TrackerCategory]
    
    func addNewRecord(tracker: Tracker, trackerRecord: TrackerRecord) throws
    func getAllRecords() -> [TrackerRecord]
    func removeRecord(tracker: Tracker, trackerRecord: TrackerRecord) throws
}

final class DataProvider: NSObject {
    
    lazy var trackerCategoryStore: TrackerCategoryStoreProtocol = TrackerCategoryStore(context: self.context, delegate: self.delegate!)
    lazy var trackerRecordStore: TrackerRecordStoreProtocol = TrackerRecordStore()
    
    weak var delegate: DataProviderDelegate?
    private let context: NSManagedObjectContext
    
    init(delegate: DataProviderDelegate ,context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext) {
        self.context = context
        self.delegate = delegate
    }
    
}

// MARK: - DataProviderProtocol
extension DataProvider: DataProviderProtocol {
    func addNewRecord(tracker: Tracker, trackerRecord: TrackerRecord) throws {
        do {
            try trackerRecordStore.addNewRecord(tracker: tracker, trackerRecord: trackerRecord)
        }
    }
    
    func getAllRecords() -> [TrackerRecord] {
        guard let trackerRecords = trackerRecordStore.getAllRecords() else  {return []}
        return trackerRecords
    }
    
    func removeRecord(tracker: Tracker, trackerRecord: TrackerRecord) throws {
        do {
            try trackerRecordStore.removeRecord(tracker: tracker, trackerRecord: trackerRecord)
        }
        
    }
    
    func addTracker(categoryHeader: String) {
        trackerCategoryStore.addTrackerCategory(categoryHeader: categoryHeader)
    }
    
    func addTracker(categoryHeader: String, tracker: Tracker) {
        trackerCategoryStore.addTrackerCategory(categoryHeader: categoryHeader, tracker: tracker)
    }
    
    func getAllTrackerCategory() -> [TrackerCategory] {
        trackerCategoryStore.getAllTrackerCategory()
    }
    
    
}
