//
//  UIImageExtension.swift
//  vmpendischukPW7
//
//  Created by Vladislav on 21.01.2022.
//

import Foundation
import UIKit

extension UIImage {
    public static func imageWithView(view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
