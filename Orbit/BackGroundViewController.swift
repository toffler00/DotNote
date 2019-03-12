//
//  BackGroundViewController.swift
//  Orbit
//
//  Created by ilhan won on 30/01/2019.
//  Copyright © 2019 orbit. All rights reserved.
//

import UIKit

protocol SaveMemoDelegate : class {
    func saveMemoDelegate()
}
class BackGroundViewController : UIViewController, DismissDelegate {
    

    fileprivate var backGroundView : UIView!
    var selectedDate : Date!
    var memoViewController = MemoViewController()
    var listViewController = ListViewController()
    weak var saveMemoDelegate : SaveMemoDelegate!
    override func viewDidLoad() {
        self.view.backgroundColor = .clear
        self.view.insetsLayoutMarginsFromSafeArea = false
        self.view.directionalLayoutMargins = NSDirectionalEdgeInsetsMake(0, 0, 0, 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUI()
    }
    
    override func viewWillLayoutSubviews() {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveMemoDelegate.saveMemoDelegate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presentMemoViewController()
    }

    func presentMemoViewController() {
        print("presentMemoView")
        DispatchQueue.main.async {
            self.memoViewController.modalPresentationStyle = .overFullScreen
            self.memoViewController.dismissDelegate = self
            self.memoViewController.selectDate = self.selectedDate
            self.present(self.memoViewController, animated: true, completion: nil)
        }
    }
    
    func setUI() {
        backGroundView = UIView()
        backGroundView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(backGroundView)
        backGroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        backGroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        backGroundView.backgroundColor = .black
        backGroundView.alpha = 0.3
    }
    
    
    func dismissBackGroundView() {
        self.dismiss(animated: false, completion: nil)
    }
}
