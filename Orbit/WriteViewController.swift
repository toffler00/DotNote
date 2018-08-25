//
//  WriteViewController.swift
//  Orbit
//
//  Created by David Koo on 25/08/2018.
//  Copyright © 2018 orbit. All rights reserved.
//

import UIKit

class WriteViewController: UIViewController {
    fileprivate weak var diaryWriteDelegate: DiaryWriteDelegate!
    
    fileprivate var newTitle: UITextView!
    fileprivate var newBody: UITextView!
    fileprivate var newBodyBottomConst: NSLayoutConstraint!
    
    init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil, delegate: DiaryWriteDelegate) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.diaryWriteDelegate = delegate
        view.backgroundColor = .white
    }
    
    override func viewWillLayoutSubviews() {
        if newTitle == nil {
            setupLayout()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension WriteViewController {
    fileprivate func setupLayout() {
        newTitle = UITextView()
        newTitle.translatesAutoresizingMaskIntoConstraints = false
        
        let newTitleConsts = [NSLayoutConstraint(item: newTitle, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 0),
                              NSLayoutConstraint(item: newTitle, attribute: .leading, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .leading, multiplier: 1, constant: 0),
                              NSLayoutConstraint(item: newTitle, attribute: .trailing, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .trailing, multiplier: 1, constant: 0),
                              NSLayoutConstraint(item: newTitle, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 30)]
        
        view.addSubview(newTitle)
        view.addConstraints(newTitleConsts)
        
        newBody = UITextView()
        newBody.translatesAutoresizingMaskIntoConstraints = false
        
        var newBodyConsts = [NSLayoutConstraint(item: newBody, attribute: .leading, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .leading, multiplier: 1, constant: 0),
                             NSLayoutConstraint(item: newBody, attribute: .trailing, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .trailing, multiplier: 1, constant: 0),
                             NSLayoutConstraint(item: newBody, attribute: .top, relatedBy: .equal, toItem: newTitle, attribute: .bottom, multiplier: 1, constant: 10)]

        newBodyBottomConst = NSLayoutConstraint(item: view.safeAreaLayoutGuide, attribute: .bottom, relatedBy: .equal, toItem: newBody, attribute: .bottom, multiplier: 1, constant: 0)
        
        newBodyConsts.append(newBodyBottomConst)
        
        view.addSubview(newBody)
        view.addConstraints(newBodyConsts)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameDidChange), name: NSNotification.Name.UIKeyboardDidChangeFrame, object: nil)
        
        newTitle.becomeFirstResponder()
    }
}

extension WriteViewController {
    @objc fileprivate func keyboardDidShow(notification: NSNotification) {
        adjustingHeight(notification: notification)
    }
    
    @objc fileprivate func keyboardFrameDidChange(notification: NSNotification) {
        adjustingHeight(notification: notification)
    }
    
    fileprivate func adjustingHeight(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        let keyboardFrame: CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        newBodyBottomConst.constant = keyboardFrame.height - view.safeAreaInsets.bottom
    }
}
