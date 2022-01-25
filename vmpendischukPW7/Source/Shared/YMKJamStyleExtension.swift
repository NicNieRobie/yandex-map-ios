//
//  YMKJamStyleExtension.swift
//  vmpendischukPW7
//
//  Created by Vladislav on 24.01.2022.
//

import Foundation
import YandexMapsMobile
import UIKit

// MARK: - YMKJamStyle extended

extension YMKJamStyle {
    /// Creates an in-app default dark traffic jam color style and returns it.
    ///
    /// - returns: _YMKJamStyle_ instance.
    public static func createJamDarkStyle() -> YMKJamStyle {
        let palette: NSMutableArray = []
        
        // Setting the colors for each jam type.
        let freeJamColor = YMKJamTypeColor(jamType: .free, jam: UIColor(red: 0, green: 0.83, blue: 0.83, alpha: 1))
        let lightJamColor = YMKJamTypeColor(jamType: .light, jam: UIColor(red: 0, green: 0.69, blue: 0.83, alpha: 1))
        let hardJamColor = YMKJamTypeColor(jamType: .hard, jam: UIColor(red: 0, green: 0.49, blue: 0.83, alpha: 1))
        let veryHardJamColor = YMKJamTypeColor(jamType: .veryHard, jam: UIColor(red: 0, green: 0.27, blue: 0.83, alpha: 1))
        let blockedJamColor = YMKJamTypeColor(jamType: .blocked, jam: UIColor(red: 0.53, green: 0, blue: 0.83, alpha: 1))
        let unknownJamColor = YMKJamTypeColor(jamType: .unknown, jam: UIColor(red: 0.77, green: 0.82, blue: 0.85, alpha: 1))
        
        // Creating the color palette.
        palette.addObjects(from: [blockedJamColor, freeJamColor, hardJamColor, lightJamColor, unknownJamColor, veryHardJamColor])
        
        return YMKJamStyle(colors: palette as! [YMKJamTypeColor])
    }
}
