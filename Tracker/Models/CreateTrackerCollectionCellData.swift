//  Created by Artem Morozov on 16.08.2024.

import UIKit

enum SectionType {
    case emoji([String])
    case color([UIColor])
}

struct CreateTrackerCollectionCellData {
    let header: String
    let type: SectionType
}
