//
//  MemoViewController.swift
//  Orbit
//
//  Created by ilhan won on 03/01/2019.
//  Copyright © 2019 orbit. All rights reserved.
//

import UIKit

class MemoViewController: UIViewController {
    
    var backGroundView : UIView!
    var memoView : UIView!
    var selectedDate : UILabel!
    var memoTextView : UITextView!
    var saveBtn : UIImageView!
    var cancel : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        self.view.window?.backgroundColor = .clear
    }
    
    func setUI() {
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        backGroundView = UIView()
        memoView = UIView()
        selectedDate = UILabel()
        memoTextView = UITextView()
        saveBtn = UIImageView()
        cancel = UIImageView()
        
        backGroundView.translatesAutoresizingMaskIntoConstraints = false
        memoView.translatesAutoresizingMaskIntoConstraints = false
        selectedDate.translatesAutoresizingMaskIntoConstraints = false
        memoTextView.translatesAutoresizingMaskIntoConstraints = false
        saveBtn.translatesAutoresizingMaskIntoConstraints = false
        cancel.translatesAutoresizingMaskIntoConstraints = false
        
        let constBgView : [NSLayoutConstraint] = [NSLayoutConstraint(item: backGroundView, attribute: .top, relatedBy: .equal,
                                                                     toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 0),
                                                  NSLayoutConstraint(item: backGroundView, attribute: .leading, relatedBy: .equal,
                                                                     toItem: view.safeAreaLayoutGuide, attribute: .leading, multiplier: 1, constant: 0),
                                                  NSLayoutConstraint(item: backGroundView, attribute: .trailing, relatedBy: .equal,
                                                                     toItem: view.safeAreaLayoutGuide, attribute: .trailing, multiplier: 1, constant: 0),
                                                  NSLayoutConstraint(item: backGroundView, attribute: .bottom, relatedBy: .equal,
                                                                     toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)]
        self.view.addSubview(backGroundView)
        self.view.addConstraints(constBgView)
        backGroundView.backgroundColor = .black
        backGroundView.alpha = 0.5
        
        let constmemoView  : [NSLayoutConstraint] = [NSLayoutConstraint(item: memoView, attribute: .centerX, relatedBy: .equal,
                                                                        toItem: backGroundView, attribute: .centerX, multiplier: 1, constant: 0),
                                                     NSLayoutConstraint(item: memoView, attribute: .centerY, relatedBy: .equal,
                                                                        toItem: backGroundView, attribute: .centerY, multiplier: 1, constant: 0),
                                                     NSLayoutConstraint(item: memoView, attribute: .width, relatedBy: .equal,
                                                                        toItem: nil, attribute: .width, multiplier: 1, constant: (width * 0.7)),
                                                     NSLayoutConstraint(item: memoView, attribute: .height, relatedBy: .equal,
                                                                        toItem: nil, attribute: .height, multiplier: 1, constant: (height * 0.7))]
        backGroundView.addSubview(memoView)
        backGroundView.addConstraints(constmemoView)
        backGroundView.backgroundColor = .white
        
        let constselectedDate  : [NSLayoutConstraint] = [NSLayoutConstraint(item: selectedDate, attribute: .top, relatedBy: .equal, toItem: backGroundView, attribute: .top, multiplier: 1, constant: 4),
                                                         NSLayoutConstraint(item: selectedDate, attribute: .leading, relatedBy: .equal, toItem: backGroundView, attribute: .leading, multiplier: 1, constant: 4),
                                                         NSLayoutConstraint(item: selectedDate, attribute: .trailing, relatedBy: .equal, toItem: backGroundView, attribute: .trailing, multiplier: 1, constant: -52),
                                                         NSLayoutConstraint(item: selectedDate, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 48)]
        backGroundView.addSubview(selectedDate)
        backGroundView.addConstraints(constselectedDate)
        
        
        let constmemnoTextV  : [NSLayoutConstraint] = []
        let constSave  : [NSLayoutConstraint] = []
        let constCancel  : [NSLayoutConstraint] = []
        
    }
    
}
