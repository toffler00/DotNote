//
//  AlertController.swift
//  Orbit
//
//  Created by ilhan won on 26/11/2018.
//  Copyright © 2018 orbit. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert(title : String?,
                   message : String?,
                   actionStyle : UIAlertActionStyle = UIAlertActionStyle.default,
                   cancelBtn : Bool,
                   buttonTitle : String,
                   onView : UIViewController, completion : ((UIAlertAction) -> Void)?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: buttonTitle, style: .default, handler: completion)
        if cancelBtn {
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
        }
        alert.addAction(okAction)
        onView.present(alert, animated: true, completion: nil)
        }
    }

