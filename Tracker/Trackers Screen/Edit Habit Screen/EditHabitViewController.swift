//  Created by Artem Morozov on 23.09.2024.


import UIKit

final class EditHabitViewController: CreatingHabitViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Редактирование привычки"
        createButton.setTitle("Сохранить", for: .normal)
    }
}
