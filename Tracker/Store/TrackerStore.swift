//  Created by Artem Morozov on 20.08.2024.

import UIKit
import CoreData

protocol TrackerStoreAddNewTrackerProtocol: AnyObject {
    func addNewTracker(category: TrackerCategoryCoreData, tracker: Tracker) throws
}

protocol TrackerStoreGetTrackerCoreDataForIdProtocol: AnyObject {
    func getTrackerCoreDataForId(id: UUID) -> TrackerCoreData?
}

final class TrackerStore: TrackerStoreAddNewTrackerProtocol, TrackerStoreGetTrackerCoreDataForIdProtocol {
    private let context: NSManagedObjectContext
    private let colorMarshalling = UIColorMarshalling()
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addNewTracker(category: TrackerCategoryCoreData, tracker: Tracker) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        
        let schedule = tracker.schedule as NSObject
        trackerCoreData.name = tracker.name
        trackerCoreData.id = tracker.id
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = colorMarshalling.hexString(from: tracker.color)
        trackerCoreData.schedule = schedule
        trackerCoreData.category = category
        try context.save()
    }
    
    func getTrackerCoreDataForId(id: UUID) -> TrackerCoreData? {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        let trackers = try? context.fetch(fetchRequest)
        let currentTracker = trackers?.first(where: {
            $0.id == id
        })
        return currentTracker
    }
}


