//  Created by Artem Morozov on 20.08.2024.

import UIKit
import CoreData

final class TrackerStore {
    private let context: NSManagedObjectContext
    private let colorMarshalling = UIColorMarshalling()
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addNewTracker(category: TrackerCategoryCoreData, tracker: Tracker) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        
        guard let encodeData = try? JSONEncoder().encode(tracker.schedule) else {return}
        
        trackerCoreData.name = tracker.name
        trackerCoreData.id = tracker.id
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = colorMarshalling.hexString(from: tracker.color)
        trackerCoreData.schedule = encodeData
        trackerCoreData.category = category
    }
}
