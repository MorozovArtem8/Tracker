//  Created by Artem Morozov on 28.09.2024.


import Foundation

protocol FilterStateSavingService {
    var currentFilterState: Int { get }
    
    func store(newFilterState: Int)
}

final class FilterStateSavingServiceImplementation: FilterStateSavingService{
    
    private let userDefaults = UserDefaults.standard
    
    var currentFilterState: Int {
        get {
            return userDefaults.integer(forKey: "currentFilterIsActive")
        }
        
        set {
            userDefaults.setValue(newValue, forKey: "currentFilterIsActive")
        }
    }
    
    func store(newFilterState: Int) {
        currentFilterState = newFilterState
    }
}
