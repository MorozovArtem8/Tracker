//  Created by Artem Morozov on 28.07.2024.

import UIKit

enum DaysWeek {
    case Monday
    case Tuesday
    case Wednesday
    case Thursday
    case Friday
    case Saturday
    case Sunday
    
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
