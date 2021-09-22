//
//  UIImageView.swift
//  ProMind
//
//  Created by Tan Wee Keat on 22/9/21.
//

//import UIKit
//import Gifu
//
//extension UIImageView: GIFAnimatable {
//    private struct AssociatedKeys {
//        static var AnimatorKey = "gifu.animator.key"
//    }
//
//    override open func display(_ layer: CALayer) {
////        guard let image = self.activeFrame else {
////            return
////        }
////        layer.contentsScale = image.scale
////        layer.contents = image.cgImage
//        updateImageIfNeeded()
//    }
//
//    public var animator: Animator? {
//        get {
//            guard let animator = objc_getAssociatedObject(self, &AssociatedKeys.AnimatorKey) as? Animator else {
//                let animator = Animator(withDelegate: self)
//                self.animator = animator
//                return animator
//            }
//            return animator
//        }
//        
//        set {
//            objc_setAssociatedObject(self, &AssociatedKeys.AnimatorKey, newValue as Animator?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//    }
//}
