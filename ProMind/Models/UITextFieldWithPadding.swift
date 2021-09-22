//
//  UITextFieldWithPadding.swift
//  ProMind
//
//  Created by Tan Wee Keat on 22/9/21.
//

import UIKit

class UITextFieldWithPadding: UITextField {
    var textPadding = UIEdgeInsets(
        top: 8,
        left: 16,
        bottom: 8,
        right: 16
    )

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
}
