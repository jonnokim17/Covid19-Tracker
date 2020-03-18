//
//  Extension+UIDevice.swift
//  Covid19 Tracker
//
//  Created by Jonathan Kim on 3/18/20.
//  Copyright © 2020 jonno. All rights reserved.
//

import Foundation
import UIKit

extension UIDevice {
    static func isSimulator() -> Bool {
        var isSimulator = false
#if arch(x86_64) || arch(i386)
        isSimulator = true
#endif
        return isSimulator
    }
    
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
    var iPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    enum ScreenType: String {
        case iPhone4 = "iPhone 4 or iPhone 4S"
        case iPhone5 = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
        case iPhone6 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
        case iPhonePlus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhoneX = "iPhone X or iPhone XS or iPhone 11 Pro"
        case iPhoneXR = "iPhone XR or iPhone 11"
        case iPhoneMax = "iPhone XS Max or iPhone 11 Pro Max"
        case unknown
    }
    var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhone4
        case 1136:
            return .iPhone5
        case 1334:
            return .iPhone6
        case 1792:
            return .iPhoneXR
        case 1920, 2208:
            return .iPhonePlus
        case 2436:
            return .iPhoneX
        case 2688:
            return .iPhoneMax
        default:
            return .unknown
        }
    }
}
