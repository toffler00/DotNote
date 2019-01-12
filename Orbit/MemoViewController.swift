//
//  MemoViewController.swift
//  Orbit
//
//  Created by ilhan won on 03/01/2019.
//  Copyright © 2019 orbit. All rights reserved.
//

import UIKit
import RealmSwift

protocol SaveMemoDelegate : class {
    func saveMemoDelegate()
}
class MemoViewController: UIViewController {
    
    fileprivate var keyboardShown = false
    var saveMemoDelegate : SaveMemoDelegate?
    
    var backGroundView : UIView!
    var memoView : UIStackView!
    var dateStackView : UIStackView!
    var selectedDate : UILabel!
    var memoTextView : UITextView!
    var saveBtnBackView : UIView!
    var saveBtn : UIImageView!
    var cancelBtn : UIImageView!
    var baseView : UIView!
    var selectDate : Date!
    var memoViewRect : CGRect!
    var updateHeight : NSLayoutConstraint!
    fileprivate var transY : CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        self.view.insetsLayoutMarginsFromSafeArea = false
        self.view.directionalLayoutMargins = NSDirectionalEdgeInsetsMake(0, 0, 0, 0)
//        self.view.layoutMargins = UIEdgeInsets(top: self.view.layoutMargins.top, left: 0, bottom: self.view.layoutMargins.bottom, right: 0)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        registerForKeyboardNotification()
    }
  
    override func viewDidAppear(_ animated: Bool) {
        transY = (view.frame.size.height * 0.18)
        print("memoView \(memoView.frame.size.height)")
        print("memoTextView \(memoTextView.frame.size.height)")
        print("saveBtnBackView \(saveBtnBackView.frame.size.height)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unregisterForKeyboardNotification()
    }
    
    override func viewWillLayoutSubviews() {
        if baseView == nil {
            setUI()
            selectedDate.text = "  \(dateToString(in: selectDate, dateFormat: "yyyy.MM.dd eee"))"
        }
    }
}
extension MemoViewController {
    @objc func dismissMemoView() {
        dismiss(animated: true, completion: nil)
        // 메모내용이 있을경우 경고창
    }
    
    @objc func saveMemo() {
        
        dismiss(animated: true) {
            print("saveMemo")
        }
    }
}
extension  MemoViewController {
    func setUI() {
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
//        let keyboardHeight
        
        backGroundView = UIView()
        memoView = UIStackView()
        selectedDate = UILabel()
        cancelBtn = UIImageView()
        dateStackView = UIStackView()
        memoTextView = UITextView()
        saveBtn = UIImageView()
        baseView = UIView()
        saveBtnBackView = UIView()
        
        backGroundView.translatesAutoresizingMaskIntoConstraints = false
        baseView.translatesAutoresizingMaskIntoConstraints = false
        memoView.translatesAutoresizingMaskIntoConstraints = false
        dateStackView.translatesAutoresizingMaskIntoConstraints = false
        selectedDate.translatesAutoresizingMaskIntoConstraints = false
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        memoTextView.translatesAutoresizingMaskIntoConstraints = false
        saveBtnBackView.translatesAutoresizingMaskIntoConstraints = false
        saveBtn.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(backGroundView)
        backGroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        backGroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        backGroundView.backgroundColor = .clear
        
        view.addSubview(baseView)
        baseView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        baseView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        baseView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        baseView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        baseView.backgroundColor = .black
        baseView.alpha = 0.3
        
        view.addSubview(memoView)
        memoView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75, constant: 0).isActive = true
        memoView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.52, constant: 0).isActive = true
        memoView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        memoView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: (width * 0.15)).isActive = true
        memoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: (width * 0.15)).isActive = true
        memoView.backgroundColor = .white
        
        view.addSubview(dateStackView)
        dateStackView.widthAnchor.constraint(equalTo: memoView.widthAnchor).isActive = true
        dateStackView.heightAnchor.constraint(equalTo: memoView.heightAnchor, multiplier: 0.1).isActive = true
        
        view.addSubview(selectedDate)
        selectedDate.backgroundColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        selectedDate.font = UIFont.boldSystemFont(ofSize: 20)
        
        view.addSubview(cancelBtn)
        cancelBtn.widthAnchor.constraint(equalToConstant: 48).isActive = true
        cancelBtn.backgroundColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        cancelBtn.image = UIImage(named: "multiply")
        cancelBtn.contentMode = .scaleAspectFit
        cancelBtn.isUserInteractionEnabled = true
        let cancelGesture = UITapGestureRecognizer(target: self, action: #selector(dismissMemoView))
        cancelBtn.addGestureRecognizer(cancelGesture)
        
        view.addSubview(dateStackView)
        dateStackView.addArrangedSubview(selectedDate)
        dateStackView.addArrangedSubview(cancelBtn)
        dateStackView.axis = .horizontal
        dateStackView.alignment = .fill
        
        view.addSubview(memoTextView)
        memoTextView.widthAnchor.constraint(equalTo: memoView.widthAnchor, multiplier: 1).isActive = true
        memoTextView.heightAnchor.constraint(equalTo: memoView.heightAnchor, multiplier: 0.8).isActive = true
        memoTextView.backgroundColor = .lightGray
        memoTextView.font = UIFont.systemFont(ofSize: 18)
        
        view.addSubview(saveBtnBackView)
        saveBtnBackView.widthAnchor.constraint(equalTo: memoView.widthAnchor, multiplier: 1).isActive = true
        saveBtnBackView.heightAnchor.constraint(equalTo: memoView.heightAnchor, multiplier: 0.1).isActive = true
        saveBtnBackView.backgroundColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        
        saveBtnBackView.addSubview(saveBtn)
        saveBtn.widthAnchor.constraint(equalToConstant: 36).isActive = true
        saveBtn.heightAnchor.constraint(equalToConstant: 36).isActive = true
        saveBtn.centerXAnchor.constraint(equalTo: saveBtnBackView.centerXAnchor, constant: 1).isActive = true
        saveBtn.centerYAnchor.constraint(equalTo: saveBtnBackView.centerYAnchor, constant: 1).isActive = true
        saveBtn.backgroundColor = .clear
        saveBtn.image = UIImage(named: "post")
        saveBtn.contentMode = .scaleAspectFill
        saveBtn.isUserInteractionEnabled = true
        let saveTapGesture = UITapGestureRecognizer(target: self, action: #selector(saveMemo))
        saveBtn.addGestureRecognizer(saveTapGesture)
        
        
        memoView.addArrangedSubview(dateStackView)
        memoView.addArrangedSubview(memoTextView)
        memoView.addArrangedSubview(saveBtnBackView)
        memoView.axis = .vertical
        memoView.alignment = .fill
        memoView.autoresizesSubviews = true
    }

}

extension MemoViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if keyboardShown == true {
            view.endEditing(true)
        }
    }
    
    @objc fileprivate func cleanTextView() {
        memoTextView.text = ""
        memoTextView.textColor = .black
    }
    
    @objc fileprivate func textViewState() {
        if memoTextView.text == "" {
            memoTextView.text = ""
            memoTextView.textColor = UIColor(red: 208/255, green: 207/255, blue: 208/255, alpha: 1)
        }
    }
    
    fileprivate func registerForTextViewNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(cleanTextView),
                                               name: NSNotification.Name.UITextViewTextDidBeginEditing, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textViewState),
                                               name: NSNotification.Name.UITextViewTextDidEndEditing, object: nil)
    }
    
    fileprivate func unregisterForTextViewNotification() {
        
    }
    
    fileprivate func registerForKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillshow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    fileprivate func unregisterForKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc fileprivate func keyboardWillshow(notification : Notification) {
        adjustHeight(notification: notification)
    }
    
    @objc fileprivate func keyboardWillHide(notification : Notification) {
        adjustHide(notification: notification)
    }
    
    fileprivate func adjustHeight(notification : Notification) {
        guard let userInfo = notification.userInfo else {return}
        let keyboardFrame : CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        if keyboardFrame.height == 0 || keyboardShown {
            return
        } else {
        keyboardShown = true
//            let height = (view.frame.size.height - keyboardFrame.height - 10)
            UIStackView.animate(withDuration: 0.5, animations: {
                self.memoView.transform = CGAffineTransform(translationX: 0, y: -(self.transY))
            }) { (_) in
//                self.updateHeight.constant = 0.8
                self.memoView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.52, constant: 0).isActive = true
            }
           
            
        }
    }
    
    fileprivate func adjustHide(notification : Notification) {
        keyboardShown = false
        UIStackView.animate(withDuration: 0.5) {
            self.memoView.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }

}

extension MemoViewController {
    func setupUI() {
        
//        let constBaseView : [NSLayoutConstraint] = [NSLayoutConstraint(item: baseView, attribute: .top, relatedBy: .equal,
//                                                                       toItem: view, attribute: .top, multiplier: 1, constant: 0),
//                                                    NSLayoutConstraint(item: baseView, attribute: .leading, relatedBy: .equal,
//                                                                       toItem: view.safeAreaLayoutGuide, attribute: .leading, multiplier: 1, constant: 0),
//                                                    NSLayoutConstraint(item: baseView, attribute: .trailing, relatedBy: .equal,
//                                                                       toItem: view.safeAreaLayoutGuide, attribute: .trailing, multiplier: 1, constant: 0),
//                                                    NSLayoutConstraint(item: baseView, attribute: .bottom, relatedBy: .equal,
//                                                                       toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)]
//        self.view.addSubview(baseView)
//        self.view.addConstraints(constBaseView)
//        baseView.backgroundColor = .black
//        baseView.alpha = 0.3
//        NSLayoutConstraint.activate(constBaseView)
//
//        let constBgView : [NSLayoutConstraint] = [NSLayoutConstraint(item: backGroundView, attribute: .top, relatedBy: .equal,
//                                                                     toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 0),
//                                                  NSLayoutConstraint(item: backGroundView, attribute: .leading, relatedBy: .equal,
//                                                                     toItem: view.safeAreaLayoutGuide, attribute: .leading, multiplier: 1, constant: 0),
//                                                  NSLayoutConstraint(item: backGroundView, attribute: .trailing, relatedBy: .equal,
//                                                                     toItem: view.safeAreaLayoutGuide, attribute: .trailing, multiplier: 1, constant: 0),
//                                                  NSLayoutConstraint(item: backGroundView, attribute: .bottom, relatedBy: .equal,
//                                                                     toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)]
//        self.view.addSubview(backGroundView)
//        self.view.addConstraints(constBgView)
//        backGroundView.backgroundColor = .clear
//        NSLayoutConstraint.activate(constBgView)
//
//        let constmemoView  : [NSLayoutConstraint] = [NSLayoutConstraint(item: memoView, attribute: .centerX, relatedBy: .equal,
//                                                                        toItem: backGroundView, attribute: .centerX, multiplier: 1, constant: 0),
//                                                     NSLayoutConstraint(item: memoView, attribute: .centerY, relatedBy: .equal,
//                                                                        toItem: backGroundView, attribute: .centerY, multiplier: 1, constant: 0),
//                                                     NSLayoutConstraint(item: memoView, attribute: .width, relatedBy: .equal,
//                                                                        toItem: nil, attribute: .width, multiplier: 1, constant: (width * 0.8)),
//                                                     NSLayoutConstraint(item: memoView, attribute: .height, relatedBy: .equal,
//                                                                        toItem: nil, attribute: .height, multiplier: 1, constant: (height * 0.65))]
//        backGroundView.addSubview(memoView)
//        backGroundView.addConstraints(constmemoView)
//        memoView.backgroundColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
//        memoView.tintColor = .black
//        memoView.autoresizesSubviews = true
//        NSLayoutConstraint.activate(constmemoView)
//
//        let constselectedDate  : [NSLayoutConstraint] = [NSLayoutConstraint(item: selectedDate, attribute: .top, relatedBy: .equal,
//                                                                            toItem: memoView, attribute: .top, multiplier: 1, constant: 4),
//                                                         NSLayoutConstraint(item: selectedDate, attribute: .leading, relatedBy: .equal,
//                                                                            toItem: memoView, attribute: .leading, multiplier: 1, constant: 4),
//                                                         NSLayoutConstraint(item: selectedDate, attribute: .trailing, relatedBy: .equal,
//                                                                            toItem: memoView, attribute: .trailing, multiplier: 1, constant: -52),
//                                                         NSLayoutConstraint(item: selectedDate, attribute: .height, relatedBy: .equal,
//                                                                            toItem: nil, attribute: .height, multiplier: 1, constant: 48)]
//        memoView.addSubview(selectedDate)
//        memoView.addConstraints(constselectedDate)
//        selectedDate.backgroundColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
//        selectedDate.text = "  \(selectDate)"
//        selectedDate.font = UIFont.boldSystemFont(ofSize: 20)
//        NSLayoutConstraint.activate(constselectedDate)
//
//        let constmemnoTextV  : [NSLayoutConstraint] = [NSLayoutConstraint(item: memoTextView, attribute: .top, relatedBy: .equal,
//                                                                          toItem: memoView, attribute: .top, multiplier: 1, constant: 52),
//                                                       NSLayoutConstraint(item: memoTextView, attribute: .leading, relatedBy: .equal,
//                                                                          toItem: memoView, attribute: .leading, multiplier: 1, constant: 4),
//                                                       NSLayoutConstraint(item: memoTextView, attribute: .trailing, relatedBy: .equal,
//                                                                          toItem: memoView, attribute: .trailing, multiplier: 1, constant: -4),
//                                                       NSLayoutConstraint(item: memoTextView, attribute: .height, relatedBy: .equal,
//                                                                          toItem: memoView, attribute: .height, multiplier: 0.8, constant: 0),
//                                                       NSLayoutConstraint(item: memoTextView, attribute: .bottom, relatedBy: .greaterThanOrEqual,
//                                                                          toItem: memoView, attribute: .bottom, multiplier: 1, constant: -4)]
//
//        memoView.addSubview(memoTextView)
//        memoView.addConstraints(constmemnoTextV)
//        //        memoTextView.backgroundColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
//        memoTextView.backgroundColor = .lightGray
//        NSLayoutConstraint.activate(constmemnoTextV)
//        //        memoTextView.backgroundColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
//        //
//        //        let constSaveView : [NSLayoutConstraint] = [NSLayoutConstraint(item: saveBtnBackView, attribute: .top, relatedBy: .equal,
//        //                                                                       toItem: memoTextView, attribute: .bottom, multiplier: 1, constant: 0),
//        //                                                    NSLayoutConstraint(item: saveBtnBackView, attribute: .leading, relatedBy: .equal,
//        //                                                                       toItem: memoView, attribute: .leading, multiplier: 1, constant: 4),
//        //                                                    NSLayoutConstraint(item: saveBtnBackView, attribute: .trailing, relatedBy: .equal,
//        //                                                                       toItem: memoView, attribute: .trailing, multiplier: 1, constant: -4),
//        //                                                    NSLayoutConstraint(item: saveBtnBackView, attribute: .bottom, relatedBy: .equal,
//        //                                                                       toItem: memoView, attribute: .bottom, multiplier: 1, constant: -4)]
//        //
//        //        memoView.addSubview(saveBtnBackView)
//        //        memoView.addConstraints(constSaveView)
//        ////        saveBtnBackView.backgroundColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
//        //        saveBtnBackView.backgroundColor = .yellow
//        //
//        //        let constSave  : [NSLayoutConstraint] = [NSLayoutConstraint(item: saveBtn, attribute: .width, relatedBy: .equal,
//        //                                                                    toItem: nil, attribute: .width, multiplier: 1, constant: 36),
//        //                                                 NSLayoutConstraint(item: saveBtn, attribute: .height, relatedBy: .equal,
//        //                                                                    toItem: nil, attribute: .height, multiplier: 1, constant: 36),
//        //                                                 NSLayoutConstraint(item: saveBtn, attribute: .centerX, relatedBy: .equal,
//        //                                                                    toItem: saveBtnBackView, attribute: .centerX, multiplier: 1, constant: 0),
//        //                                                 NSLayoutConstraint(item: saveBtn, attribute: .bottom, relatedBy: .equal,
//        //                                                                    toItem: saveBtnBackView, attribute: .bottom, multiplier: 1, constant: -4)]
//        //        saveBtnBackView.addSubview(saveBtn)
//        //        saveBtnBackView.addConstraints(constSave)
//        //        saveBtn.backgroundColor = .clear
//        //        saveBtn.image = UIImage(named: "post")
//        //        saveBtn.contentMode = .scaleAspectFill
//        //        let saveTapGesture = UITapGestureRecognizer(target: self, action: #selector(saveMemo))
//        //        saveBtn.addGestureRecognizer(saveTapGesture)
//        //        NSLayoutConstraint.activate(constSave)
//
//        let constCancel  : [NSLayoutConstraint] = [NSLayoutConstraint(item: cancelBtn, attribute: .top, relatedBy: .equal,
//                                                                      toItem: memoView, attribute: .top, multiplier: 1, constant: 4),
//                                                   NSLayoutConstraint(item: cancelBtn, attribute: .leading, relatedBy: .equal,
//                                                                      toItem: selectedDate, attribute: .trailing, multiplier: 1, constant: 0),
//                                                   NSLayoutConstraint(item: cancelBtn, attribute: .trailing, relatedBy: .equal,
//                                                                      toItem: memoView, attribute: .trailing, multiplier: 1, constant: -4),
//                                                   NSLayoutConstraint(item: cancelBtn, attribute: .bottom, relatedBy: .equal,
//                                                                      toItem: memoTextView, attribute: .top, multiplier: 1, constant: 0)]
//        memoView.addSubview(cancelBtn)
//        memoView.addConstraints(constCancel)
//        cancelBtn.backgroundColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
//        cancelBtn.image = UIImage(named: "multiply")
//        cancelBtn.contentMode = .scaleAspectFill
//        cancelBtn.isUserInteractionEnabled = true
//        let cancelGesture = UITapGestureRecognizer(target: self, action: #selector(dismissMemoView))
//        cancelBtn.addGestureRecognizer(cancelGesture)
//        NSLayoutConstraint.activate(constCancel)
    }
}
