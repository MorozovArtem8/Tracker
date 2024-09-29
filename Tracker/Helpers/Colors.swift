//  Created by Artem Morozov on 28.09.2024.

import UIKit

final class Colors {
    
    let viewBackgroundColor = UIColor.systemBackground
    
    let textColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return UIColor.black
        } else {
            return UIColor.white
        }
    }
    
    let totalBlackAndWhite = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return UIColor.white
        } else {
            return UIColor.black
        }
    }
    
    let tableViewCellColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return UIColor("#E6E8EB", alpha: 0.3)
        } else {
            return UIColor("#E6E8EB", alpha: 0.2)
        }
    }
}
