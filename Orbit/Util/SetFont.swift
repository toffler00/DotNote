//
//  SetFont.swift
//  Orbit
//
//  Created by ilhan won on 15/01/2019.
//  Copyright © 2019 orbit. All rights reserved.
//

import UIKit

extension UIViewController {
    enum TextType {
        case navigationTitle
        case contents
        case date
        case weather
    }
    func setFont(type: TextType, onView : UIViewController, font name: String, size : CGFloat) -> UIFont? {
        switch type {
        case .navigationTitle :
            
            let font  = UIFont(name: name, size: size)
            return font
        case .contents :
            let font = UIFont(name: name, size: size)
            return font
        case .date :
            let font = UIFont(name: name, size: size)
            return font
        case .weather :
            let font = UIFont(name: name, size: size)
            return font
        }
    }
}
