//
//  UIView.swift
//  ProMind
//
//  Created by Tan Wee Keat on 19/9/21.
//

import UIKit

extension UIView {
    func takeScreenshot() -> UIImage {
        // 1. Begin creating image context based on the size of a 'view' parameter.
        // 2. Render the layer of view into that context.
        // 3. Get the actual image from the context.
        // 4. End image context.
        // 5. Write the resulting image to saved photos album.
        
        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)

        // Draw view in that context. If afterScreenUpdates is true, renders the view in-place.
        // drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
        }

        // Lastly, get image from the context.
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        print("UIView :: takeScreenShot() - image is not nil: \(image != nil)")
        
//        UIImageWriteToSavedPhotosAlbum(image ?? UIImage(), nil, nil, nil)
        return image ?? UIImage()
    }
}
