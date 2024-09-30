//  Created by Artem Morozov on 27.09.2024.


import Foundation

final class FiltersViewModel {
    
    let filterStateSavingService: FilterStateSavingService = FilterStateSavingServiceImplementation()
    
    var cellData: [CategoryCell] = [
        CategoryCell(title: "Все трекеры"),
        CategoryCell(title: "Трекеры на сегодня"),
        CategoryCell(title: "Завершенные"),
        CategoryCell(title: "Не завершенные")
    ]
}
