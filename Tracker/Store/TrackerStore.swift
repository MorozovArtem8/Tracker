//  Created by Artem Morozov on 20.08.2024.

import UIKit
import CoreData

protocol TrackerStoreProtocol: AnyObject {
    func addNewTracker(category: TrackerCategoryCoreData, tracker: Tracker) throws
    func getTrackerCoreDataForId(id: UUID) -> TrackerCoreData?
    func pinnedTracker(id: UUID)
    func getCategoryTitleForTrackerId(id: UUID) -> String?
    func removeTrackerForI(id: UUID)
    func getAllTrackers() -> [Tracker]?
}

final class TrackerStore {
    private let context: NSManagedObjectContext
    private let colorMarshalling = UIColorMarshalling()
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

//MARK: TrackerStoreProtocol func

extension TrackerStore: TrackerStoreProtocol {
    func getAllTrackers() -> [Tracker]? {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        
        do {
            let trackersCoreData = try context.fetch(fetchRequest)
            let trackers: [Tracker] = trackersCoreData.compactMap {
                guard let id = $0.id,
                      let emoji = $0.emoji,
                      let name = $0.name,
                      let schedule = $0.schedule as? [DaysWeek] 
                else {return nil}
                        
                let isPinned = $0.isPinned
                let color = colorMarshalling.color(from: $0.color ?? "")
                
                return Tracker(id: id, name: name, color: color, emoji: emoji, isPinned: isPinned, schedule: schedule)
            }
            return trackers
        }
        catch {
            return nil
        }
    }
    
    func removeTrackerForI(id: UUID) {
        guard let trackerCoreData = getTrackerCoreDataForId(id: id) else {return}
        context.delete(trackerCoreData)
        try? context.save()
    }
    
    func getCategoryTitleForTrackerId(id: UUID) -> String? {
        guard let trackerCoreData = getTrackerCoreDataForId(id: id) else {return nil}
        return trackerCoreData.category?.header
    }
    
    func addNewTracker(category: TrackerCategoryCoreData, tracker: Tracker) throws {
        if let trackerCoreDataAlreadyExist = getTrackerCoreDataForId(id: tracker.id) {
            let schedule = tracker.schedule as NSObject
            trackerCoreDataAlreadyExist.name = tracker.name
            trackerCoreDataAlreadyExist.id = tracker.id
            trackerCoreDataAlreadyExist.emoji = tracker.emoji
            trackerCoreDataAlreadyExist.color = colorMarshalling.hexString(from: tracker.color)
            trackerCoreDataAlreadyExist.schedule = schedule
            trackerCoreDataAlreadyExist.isPinned = tracker.isPinned
            trackerCoreDataAlreadyExist.category = category
            do{
                try context.save()
                print("Отредактировали трекер")
            }catch {
                print("Ошибка редактирования")
            }
            
            return
            
        } else {
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
    }
    
    func getTrackerCoreDataForId(id: UUID) -> TrackerCoreData? {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        let trackers = try? context.fetch(fetchRequest)
        let currentTracker = trackers?.first(where: {
            $0.id == id
        })
        return currentTracker
    }
    
    func pinnedTracker(id: UUID) {
       let trackerCoreData = getTrackerCoreDataForId(id: id)
        guard let trackerIsPinned = trackerCoreData?.isPinned else {return}
        trackerCoreData?.isPinned = !trackerIsPinned
        do {
            try context.save()
            print("Удалось закрепить трекер \(!trackerIsPinned)")
        } catch {
            return
        }
    }
}
