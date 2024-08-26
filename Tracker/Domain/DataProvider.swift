//  Created by Artem Morozov on 26.08.2024.

import UIKit
import CoreData

protocol DataProviderDelegate: AnyObject {
    func didUpdate()
}

protocol DataProviderProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at: IndexPath) -> Tracker?
    func addTracker(categoryHeader: String, tracker: Tracker) throws
    func deleteTracker(at indexPath: IndexPath) throws
}

final class DataProvider: NSObject {
    
    let trackerCategoryStore: TrackerCategoryStore
    
    weak var delegate: DataProviderDelegate?
    private let context: NSManagedObjectContext
    
    init(delegate: DataProviderDelegate ,context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext) {
        self.context = context
        self.delegate = delegate
        self.trackerCategoryStore = TrackerCategoryStore(context: self.context)
    }
    
}

// MARK: - DataProviderProtocol
extension DataProvider: DataProviderProtocol {
    var numberOfSections: Int {
        trackerCategoryStore.fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        guard let sections = trackerCategoryStore.fetchedResultsController.sections,
              sections.indices.contains(section) else {return 0}
        
        let trackerCategoryCoreData = trackerCategoryStore.fetchedResultsController.object(at: IndexPath(row: 0, section: section))
        //        trackerCategoryStore.addTrackerCategory(categoryHeader: "Дима")
        //        print(trackerCategoryStore.trackerCategories)
        return trackerCategoryCoreData.trackers?.count ?? 0
        
    }
    
    func object(at: IndexPath) -> Tracker? {
        Tracker(id: UUID(), name: "a", color: UIColor(), emoji: "ds", schedule: [DaysWeek.Friday])
    }
    
    func addTracker(categoryHeader: String, tracker: Tracker) throws {
        trackerCategoryStore.addTrackerCategory(categoryHeader: categoryHeader, tracker: tracker)
      
    }
    
    func deleteTracker(at indexPath: IndexPath) throws {
        
    }
    
    
}
