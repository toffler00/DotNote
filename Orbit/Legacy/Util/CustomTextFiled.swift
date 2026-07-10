//
//  CustomTextFiled.swift
//  Orbit
//
//  Created by ilhan won on 13/11/2018.
//  Copyright © 2018 orbit. All rights reserved.
//

import UIKit

class CustomTextFiled: UITextField {
    
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect.zero
    }
    
    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        return []
    }
//
//    override func selectionRects(for range: UITextRange) -> [Any] {
//        return []
//    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
