//
//  CustomNavigationBackButton.swift
//  Orbit
//
//  Created by ilhan won on 26/11/2018.
//  Copyright © 2018 orbit. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func setNavigationBackButton(onView : UIViewController,in item : UIImageView = UIImageView() ,bool : Bool) {
        let tapBackBtn = UITapGestureRecognizer(target: onView, action: #selector(popVC))
        item.addGestureRecognizer(tapBackBtn)
        if bool {
            item.translatesAutoresizingMaskIntoConstraints = false
            item.isHidden = false
            let constBackBtn : [NSLayoutConstraint] = [NSLayoutConstraint(item: item, attribute: .width, relatedBy: .equal,
                                                                          toItem: nil,
                                                                          attribute: .width, multiplier: 1, constant: 25),
                                                       NSLayoutConstraint(item: item, attribute: .height, relatedBy: .equal,
                                                                          toItem: nil,
                                                                          attribute: .height, multiplier: 1, constant: 25),
                                                       NSLayoutConstraint(item: item, attribute: .top, relatedBy: .equal,
                                                                          toItem: onView.navigationController?.navigationBar,
                                                                          attribute: .top, multiplier: 1, constant: 8),
                                                       NSLayoutConstraint(item: item, attribute: .leading, relatedBy: .equal,
                                                                          toItem: onView.navigationController?.navigationBar,
                                                                          attribute: .leading, multiplier: 1, constant: 12)]
            onView.navigationController?.navigationBar.addSubview(item)
            onView.navigationController?.navigationBar.addConstraints(constBackBtn)
            item.image = UIImage(named: "left")
            item.contentMode = .scaleAspectFill
            item.isUserInteractionEnabled = true
        
        } else {
            item.isHidden = true
            item.removeGestureRecognizer(tapBackBtn)
        }
    }
    
    @objc func popVC() {
        self.navigationController?.popViewController(animated: true)
    }
}
