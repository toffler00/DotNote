//
//  DiaryViewController.swift
//  Orbit
//
//  Created by ilhan won on 2018. 8. 11..
//  Copyright © 2018년 orbit. All rights reserved.
//

import UIKit

struct Mock {
    var title: String
    var body: String
}

class DiaryViewController: UIViewController {
    
    fileprivate var mock: Mock?
    fileprivate var diaryTableView: UITableView!
    
//    @IBOutlet weak var writeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//
//        writeButton.addTarget(self, action: #selector(pushWriteViewController), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillLayoutSubviews() {
        if diaryTableView == nil {
            setupLayout()
        }
    }
}

extension DiaryViewController {
    fileprivate func setupLayout() {
        
        diaryTableView = UITableView()
        diaryTableView.translatesAutoresizingMaskIntoConstraints = false
        
        let diaryTableViewConsts: [NSLayoutConstraint] = [NSLayoutConstraint(item: diaryTableView, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 0),
                                                         NSLayoutConstraint(item: diaryTableView, attribute: .leading, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .leading, multiplier: 1, constant: 0),
                                                         NSLayoutConstraint(item: diaryTableView, attribute: .trailing, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .trailing, multiplier: 1, constant: 0),
                                                         NSLayoutConstraint(item: diaryTableView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)]
        
        view.addSubview(diaryTableView)
        view.addConstraints(diaryTableViewConsts)
        
        diaryTableView.register(DiaryTableViewCell.self, forCellReuseIdentifier: "DiaryTableViewCell")
    }
}

extension DiaryViewController {
    @objc fileprivate func pushWriteViewController() {
        let writeViewController = WriteViewController(delegate: self)
        navigationController?.pushViewController(writeViewController, animated: true)
    }
}
