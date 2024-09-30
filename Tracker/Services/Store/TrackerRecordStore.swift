//  Created by Artem Morozov on 20.08.2024.

import UIKit
import CoreData

protocol TrackerRecordStoreProtocol: AnyObject {
    func addNewRecord(trackerCoreData: TrackerCoreData, trackerRecord: TrackerRecord) throws
    func getAllRecords() -> [TrackerRecord]?
    func removeRecord(tracker: Tracker, trackerRecord: TrackerRecord) throws
}

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    private lazy var trackerStore: TrackerStore = TrackerStore(context: self.context)
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

//MARK: TrackerRecordStoreProtocol func

extension TrackerRecordStore: TrackerRecordStoreProtocol {
    func addNewRecord(trackerCoreData: TrackerCoreData, trackerRecord: TrackerRecord) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        
        trackerRecordCoreData.dateOfCompletion = trackerRecord.dateOfCompletion
        trackerRecordCoreData.tracker = trackerCoreData
        try? context.save()
    }
    
    func getAllRecords() -> [TrackerRecord]? {
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        
        do {
            let trackerRecordsCoreData = try context.fetch(fetchRequest)
            let trackerRecords: [TrackerRecord] = trackerRecordsCoreData.compactMap{
                guard let id = $0.tracker?.id,
                      let dateOfCompletion = $0.dateOfCompletion else {return nil}
                return TrackerRecord(trackerID: id, dateOfCompletion: dateOfCompletion)
            }
            return trackerRecords
        }
        catch {
            return nil
        }
    }
    
    func removeRecord(tracker: Tracker, trackerRecord: TrackerRecord) throws {
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        let trackerRecordsCoreData = try? context.fetch(fetchRequest)
        
        if let currentRecord = trackerRecordsCoreData?.first(where: {
            guard let dateOfCompletion = $0.dateOfCompletion else {return false}
            return $0.tracker?.id == tracker.id && Calendar.current.isDate(dateOfCompletion, inSameDayAs: trackerRecord.dateOfCompletion)
        }) {
            context.delete(currentRecord)
            try? context.save()
        } else {
            print("Record not found")
        }
    }
}
