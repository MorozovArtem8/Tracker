//  Created by Artem Morozov on 29.08.2024.

import Foundation
@objc(CustomValueTransformer)
final class CustomValueTransformer: ValueTransformer {
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let myCustomClass = value as? [DaysWeek] else { return nil }
        let encoder = JSONEncoder()
        return try? encoder.encode(myCustomClass)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode([DaysWeek].self, from: data)
    }
}
