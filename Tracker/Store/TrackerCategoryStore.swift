//  Created by Artem Morozov on 20.08.2024.

import UIKit
import CoreData

enum TrackerCategoryStoreError: Error {
    case decodingErrorInvalid
}

final class TrackerCategoryStore: NSObject {
    private let colorMarshalling = UIColorMarshalling()
    private let context: NSManagedObjectContext
    var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>!
    
    private lazy var trackerStore = TrackerStore(context: self.context)
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryCoreData.header, ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: self.context,
                                                              sectionNameKeyPath: #keyPath(TrackerCategoryCoreData.header),
                                                              cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
    }
    
//    var trackerCategories: [TrackerCategory] {
//        guard let objects = self.fetchedResultsController.fetchedObjects,
//              let trackerCategories = try? objects.map({ category in
//                  try self.convertObjectInTrackerCategory(from: category)
//              }) else {return []}
//        return trackerCategories
//    }
    
    func addTrackerCategory(categoryHeader: String, tracker: Tracker) {
        guard let categoryAlreadyExists = fetchedResultsController.fetchedObjects?.first(where: {$0.header == categoryHeader}) else {
            let trackerCategory = TrackerCategoryCoreData(context: self.context)
            trackerCategory.header = categoryHeader
            do {
                try trackerStore.addNewTracker(category: trackerCategory, tracker: tracker)
                if context.hasChanges {
                    do {
                        try context.save()
                        print("Сохранили контекст11111")
                    } catch {
                        context.rollback()
                        let nserror = error as NSError
                        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                    }
                }
                print("Новая категория и трекер добавлены")
            } catch {
                print("Не удалось добавить трекер к категории")
            }
            return
        }
        print("Такая категория уже есть")
        
    }
    
    func addTrackerCategory(categoryHeader: String) {
        guard let fetchedCategory = fetchedResultsController.fetchedObjects else {return}
        //Если такая категория уже есть - выходим
        if fetchedCategory.contains(where: {$0.header == categoryHeader}) {
            return
        }
        let trackerCategory = TrackerCategoryCoreData(context: context)
        trackerCategory.header = categoryHeader
        do {
            try context.save()
            print("Успех сохранили категорию")
        } catch {
            print("Не удалось сохранить категорию")
        }
        
    }
    
    private func convertObjectInTrackerCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let header = trackerCategoryCoreData.header else {
            throw TrackerCategoryStoreError.decodingErrorInvalid
        }
        
        guard let trackersSet = trackerCategoryCoreData.trackers as? Set<TrackerCoreData> else {
            print("Ошибка тут")
            throw TrackerCategoryStoreError.decodingErrorInvalid
        }
        
        let trackers = trackersSet.map{
            let id = $0.id
            let name = $0.name
            let color = colorMarshalling.color(from: $0.color!)
            let emoji = $0.emoji
            let schedule = try? JSONDecoder().decode([DaysWeek].self, from: $0.schedule as! Data)
            
            return Tracker(id: id!, name: name!, color: color, emoji: emoji!, schedule: schedule!)
        }
        return TrackerCategory(header: header, trackers: trackers)
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        print(11)
    }
}
