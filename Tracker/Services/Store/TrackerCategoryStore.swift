//  Created by Artem Morozov on 20.08.2024.

import UIKit
import CoreData

enum TrackerCategoryStoreError: Error {
    case decodingErrorInvalid
}

protocol TrackerCategoryStoreProtocol: AnyObject {
    func getAllTrackerCategory() -> [TrackerCategory]?
    func checkCategoryExistence(categoryHeader: String) -> TrackerCategoryCoreData?
    func addTrackerCategory(categoryHeader: String)
}

final class TrackerCategoryStore: NSObject {
    private let colorMarshalling = UIColorMarshalling()
    private let context: NSManagedObjectContext
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryCoreData.header, ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: #keyPath(TrackerCategoryCoreData.header),
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    private weak var delegate: DataProviderDelegate?
    
    init(context: NSManagedObjectContext, delegate: DataProviderDelegate? = nil) {
        self.context = context
        self.delegate = delegate
    }
    
    private func convertObjectInTrackerCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let header = trackerCategoryCoreData.header else {
            throw TrackerCategoryStoreError.decodingErrorInvalid
        }
        
        guard let trackersSet = trackerCategoryCoreData.trackers as? Set<TrackerCoreData> else {
            throw TrackerCategoryStoreError.decodingErrorInvalid
        }
        
        do {
            let trackers = try trackersSet.map{
                guard let id = $0.id,
                      let name = $0.name,
                      let emoji = $0.emoji,
                      let schedule = $0.schedule as? [DaysWeek] else {throw TrackerCategoryStoreError.decodingErrorInvalid}
                
                
                let color = colorMarshalling.color(from: $0.color ?? "")
                let isPinned = $0.isPinned
                return Tracker(id: id, name: name, color: color, emoji: emoji, isPinned: isPinned, schedule: schedule )
            }
            return TrackerCategory(header: header, trackers: trackers)
        }
    }
}

//MARK: TrackerCategoryStoreProtocole func

extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    func getAllTrackerCategory() -> [TrackerCategory]? {
        let trackerCategoryArray = fetchedResultsController.fetchedObjects?.compactMap {
            do {
                return try convertObjectInTrackerCategory(from: $0)
            } catch {
                return nil
            }
        }
        return trackerCategoryArray
    }
    
    func checkCategoryExistence(categoryHeader: String) -> TrackerCategoryCoreData? {
        if let categoryAlreadyExists = fetchedResultsController.fetchedObjects?.first(where: {$0.header == categoryHeader}) {
            return categoryAlreadyExists
        }
        return nil
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
}

//MARK: NSFetchedResultsControllerDelegate func

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.didUpdate()
    }
}
