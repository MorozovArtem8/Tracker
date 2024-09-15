//  Created by Artem Morozov on 13.09.2024.

import Foundation

typealias Binding<T> = (T) -> Void

protocol CategoryViewModelProtocol: AnyObject {
    func addNewCategory(categoryHeader: String)
    var categoriesBinding: Binding<[TrackerCategory]>? { get set }
    var trackerCategories: [TrackerCategory] {get}
}

final class CategoryViewModel: CategoryViewModelProtocol {
    func getTrackerCategoriesCount() -> Int {
        trackerCategories.count
    }
    
    private lazy var dataProvider: DataProviderProtocol? = {
        do {
            try dataProvider = DataProvider(delegate: self)
            return dataProvider
        }
        catch {
            print("Не удалось инициализировать dataProvider")
            return nil
        }
    }()
    
    private(set) var trackerCategories: [TrackerCategory] = [] {
        didSet {
            categoriesBinding?(trackerCategories)
        }
    }
    
    var categoriesBinding: Binding<[TrackerCategory]>?
    
    init() {
        trackerCategories = dataProvider?.getAllTrackerCategory() ?? []
    }
    
    func addNewCategory(categoryHeader: String) {
        dataProvider?.addTrackerCategory(categoryHeader: categoryHeader)
    }
}

extension CategoryViewModel: DataProviderDelegate {
    func didUpdate() {
        trackerCategories = dataProvider?.getAllTrackerCategory() ?? []
    }
}
