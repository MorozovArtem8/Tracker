//  Created by Artem Morozov on 28.07.2024.

import UIKit

enum DaysWeek: String, CaseIterable, Comparable, Codable {
    
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
    
    static func < (lhs: DaysWeek, rhs: DaysWeek) -> Bool {
        return order(lhs) < order(rhs)
    }
    
    private static func order(_ day: DaysWeek) -> Int {
        switch day {
        case .Monday: return 1
        case .Tuesday: return 2
        case .Wednesday: return 3
        case .Thursday: return 4
        case .Friday: return 5
        case .Saturday: return 6
        case .Sunday: return 7
        }
    }
    
    func getAbbreviatedName() -> String {
        switch self {
        case .Monday:
            return "Пн"
        case .Tuesday:
            return "Вт"
        case .Wednesday:
            return "Ср"
        case .Thursday:
            return "Чт"
        case .Friday:
            return "Пт"
        case .Saturday:
            return "Сб"
        case .Sunday:
            return "Вс"
        }
    }
}

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    var isPinned: Bool
    let schedule: [DaysWeek]
}
