//  Created by Artem Morozov on 08.08.2024.

import UIKit

final class PaddedTextField: UITextField {
    var textPadding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }
}
