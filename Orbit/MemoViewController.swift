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
    var cancelBtn : UIImageView!
    var baseView : UIView!
    var selectDate : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        setUI()
    }
  
    override func viewDidAppear(_ animated: Bool) {
        
    }
}
extension MemoViewController {
    @objc func dismissMemoView() {
        dismiss(animated: true, completion: nil)
    }
}
extension  MemoViewController {
    func setUI() {
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
//        let keyboardHeight
        
        backGroundView = UIView()
        memoView = UIView()
        selectedDate = UILabel()
        memoTextView = UITextView()
        saveBtn = UIImageView()
        cancelBtn = UIImageView()
        baseView = UIView()
        
        backGroundView.translatesAutoresizingMaskIntoConstraints = false
        memoView.translatesAutoresizingMaskIntoConstraints = false
        selectedDate.translatesAutoresizingMaskIntoConstraints = false
        memoTextView.translatesAutoresizingMaskIntoConstraints = false
        saveBtn.translatesAutoresizingMaskIntoConstraints = false
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        baseView.translatesAutoresizingMaskIntoConstraints = false
        
        let constBaseView : [NSLayoutConstraint] = [NSLayoutConstraint(item: baseView, attribute: .top, relatedBy: .equal,
                                                                       toItem: view, attribute: .top, multiplier: 1, constant: 0),
                                                    NSLayoutConstraint(item: baseView, attribute: .leading, relatedBy: .equal,
                                                                       toItem: view.safeAreaLayoutGuide, attribute: .leading, multiplier: 1, constant: 0),
                                                    NSLayoutConstraint(item: baseView, attribute: .trailing, relatedBy: .equal,
                                                                       toItem: view.safeAreaLayoutGuide, attribute: .trailing, multiplier: 1, constant: 0),
                                                    NSLayoutConstraint(item: baseView, attribute: .bottom, relatedBy: .equal,
                                                                       toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)]
        self.view.addSubview(baseView)
        self.view.addConstraints(constBaseView)
        baseView.backgroundColor = .black
        baseView.alpha = 0.3
        
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
        backGroundView.backgroundColor = .clear
        
        
        let constmemoView  : [NSLayoutConstraint] = [NSLayoutConstraint(item: memoView, attribute: .centerX, relatedBy: .equal,
                                                                        toItem: backGroundView, attribute: .centerX, multiplier: 1, constant: 0),
                                                     NSLayoutConstraint(item: memoView, attribute: .centerY, relatedBy: .equal,
                                                                        toItem: backGroundView, attribute: .centerY, multiplier: 1, constant: 0),
                                                     NSLayoutConstraint(item: memoView, attribute: .width, relatedBy: .equal,
                                                                        toItem: nil, attribute: .width, multiplier: 1, constant: (width * 0.8)),
                                                     NSLayoutConstraint(item: memoView, attribute: .height, relatedBy: .equal,
                                                                        toItem: nil, attribute: .height, multiplier: 1, constant: (height * 0.8))]
        backGroundView.addSubview(memoView)
        backGroundView.addConstraints(constmemoView)
        backGroundView.backgroundColor = .clear
        
        let constselectedDate  : [NSLayoutConstraint] = [NSLayoutConstraint(item: selectedDate, attribute: .top, relatedBy: .equal,
                                                                            toItem: memoView, attribute: .top, multiplier: 1, constant: 4),
                                                         NSLayoutConstraint(item: selectedDate, attribute: .leading, relatedBy: .equal,
                                                                            toItem: memoView, attribute: .leading, multiplier: 1, constant: 4),
                                                         NSLayoutConstraint(item: selectedDate, attribute: .trailing, relatedBy: .equal,
                                                                            toItem: memoView, attribute: .trailing, multiplier: 1, constant: -52),
                                                         NSLayoutConstraint(item: selectedDate, attribute: .height, relatedBy: .equal,
                                                                            toItem: nil, attribute: .height, multiplier: 1, constant: 48)]
        memoView.addSubview(selectedDate)
        memoView.addConstraints(constselectedDate)
        selectedDate.backgroundColor = .white
        selectedDate.text = "  \(selectDate)"
        selectedDate.font = UIFont.boldSystemFont(ofSize: 20)
        
        let constmemnoTextV  : [NSLayoutConstraint] = [NSLayoutConstraint(item: memoTextView, attribute: .top, relatedBy: .equal,
                                                                          toItem: selectedDate, attribute: .bottom, multiplier: 1, constant: 0),
                                                       NSLayoutConstraint(item: memoTextView, attribute: .leading, relatedBy: .equal,
                                                                          toItem: memoView, attribute: .leading, multiplier: 1, constant: 4),
                                                       NSLayoutConstraint(item: memoTextView, attribute: .trailing, relatedBy: .equal,
                                                                          toItem: memoView, attribute: .trailing, multiplier: 1, constant: -4),
                                                       NSLayoutConstraint(item: memoTextView, attribute: .bottom, relatedBy: .equal,
                                                                          toItem: memoView, attribute: .bottom, multiplier: 1, constant: -52)]
        memoView.addSubview(memoTextView)
        memoView.addConstraints(constmemnoTextV)
        memoTextView.backgroundColor = .lightGray
        
        let constSave  : [NSLayoutConstraint] = [NSLayoutConstraint(item: saveBtn, attribute: .top, relatedBy: .equal,
                                                                    toItem: memoTextView, attribute: .bottom, multiplier: 1, constant: 0),
                                                 NSLayoutConstraint(item: saveBtn, attribute: .leading, relatedBy: .equal,
                                                                    toItem: memoView, attribute: .leading, multiplier: 1, constant: 4),
                                                 NSLayoutConstraint(item: saveBtn, attribute: .trailing, relatedBy: .equal,
                                                                    toItem: memoView, attribute: .trailing, multiplier: 1, constant: -4),
                                                 NSLayoutConstraint(item: saveBtn, attribute: .bottom, relatedBy: .equal,
                                                                    toItem: memoView, attribute: .bottom, multiplier: 1, constant: -4)]
        memoView.addSubview(saveBtn)
        memoView.addConstraints(constSave)
        saveBtn.backgroundColor = .yellow
        
        let constCancel  : [NSLayoutConstraint] = [NSLayoutConstraint(item: cancelBtn, attribute: .top, relatedBy: .equal,
                                                                      toItem: memoView, attribute: .top, multiplier: 1, constant: 4),
                                                   NSLayoutConstraint(item: cancelBtn, attribute: .leading, relatedBy: .equal,
                                                                      toItem: selectedDate, attribute: .trailing, multiplier: 1, constant: 0),
                                                   NSLayoutConstraint(item: cancelBtn, attribute: .trailing, relatedBy: .equal,
                                                                      toItem: memoView, attribute: .trailing, multiplier: 1, constant: -4),
                                                   NSLayoutConstraint(item: cancelBtn, attribute: .bottom, relatedBy: .equal,
                                                                      toItem: memoTextView, attribute: .top, multiplier: 1, constant: 0)]
        memoView.addSubview(cancelBtn)
        memoView.addConstraints(constCancel)
        cancelBtn.backgroundColor = .white
        cancelBtn.image = UIImage(named: "multiply")
        cancelBtn.contentMode = .scaleAspectFill
        cancelBtn.isUserInteractionEnabled = true
        let cancelGesture = UITapGestureRecognizer(target: self, action: #selector(dismissMemoView))
        cancelBtn.addGestureRecognizer(cancelGesture)
        
    }
}
