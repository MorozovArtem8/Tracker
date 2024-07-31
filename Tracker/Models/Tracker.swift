//  Created by Artem Morozov on 28.07.2024.

import UIKit

enum DaysWeek: Int {
    case Monday = 0
    case Tuesday = 1
    case Wednesday = 2
    case Thursday = 3
    case Friday = 4
    case Saturday = 5
    case Sunday = 6
}

struct Tracker {
    let id: String
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [DaysWeek]
}
