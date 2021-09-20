//
//  CGFloat.swift
//  ProMind
//
//  Created by Tan Wee Keat on 10/7/21.
//

import UIKit

extension CGFloat {
    subscript(index: CGFloat) -> CGFloat {
        // To return self * (index/100)%. E.g, if index = 15, the returned value will be 0.15 * self
        return self * index / 100
    }
}
