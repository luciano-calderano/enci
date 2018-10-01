//
//  UIFontExtension.swift
//  Enci
//
//  Created by Luciano Calderano on 28/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit
enum FontType: String {
    case Regular
    case Medium
    case Bold
    case SemiBold
    case ExtraBold
    case Light
    case ExtraLight
}

extension UIFont {
    class func withSize(_ size: CGFloat) -> UIFont {
        return mySize(size, type: FontType.SemiBold)
    }

    class func mySize(_ size: CGFloat, type: FontType) -> UIFont {
        let s = "Dosis-" + type.rawValue
        return UIFont(name: s, size: size)!
    }
}
