//  Created by Artem Morozov on 28.07.2024.

import UIKit

enum DaysWeek: String, CaseIterable {
    case Monday = "Понедельник"
    case Tuesday = "Вторник"
    case Wednesday = "Среда"
    case Thursday = "Четверг"
    case Friday = "Пятница"
    case Saturday = "Суббота"
    case Sunday = "Воскресенье"
    
    init?(from string: String) {
        switch string.lowercased() {
        case "monday":
            self = .Monday
        case "tuesday":
            self = .Tuesday
        case "wednesday":
            self = .Wednesday
        case "thursday":
            self = .Thursday
        case "friday":
            self = .Friday
        case "saturday":
            self = .Saturday
        case "sunday":
            self = .Sunday
        default:
            return nil
        }
    }
}

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [DaysWeek]
}
