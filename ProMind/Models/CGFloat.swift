//
//  CGFloat.swift
//  ProMind
//
//  Created by Tan Wee Keat on 10/7/21.
//

import UIKit

extension CGFloat {
    subscript(index: CGFloat) -> CGFloat {
        return self * index / 100
    }
}
