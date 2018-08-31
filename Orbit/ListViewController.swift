//
//  ListViewController.swift
//  Orbit
//
//  Created by SSY on 2018. 8. 30..
//  Copyright © 2018년 orbit. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {
    
    private var listTableView: UITableView!
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: viewWillLayoutSubviews
    override func viewWillLayoutSubviews() {
        if self.listTableView == nil {
            self.setUpLayout()
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
// MARK: - extension ListViewController
extension ListViewController {
    // MARK: setUpLayout
    private func setUpLayout(){
        self.listTableView = UITableView()
        self.listTableView.translatesAutoresizingMaskIntoConstraints = false
        
        let listTableViewConstraints: [NSLayoutConstraint] = [NSLayoutConstraint(item: self.listTableView, attribute: .top, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 0),NSLayoutConstraint(item: self.listTableView, attribute: .leading, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .leading, multiplier: 1, constant: 0),NSLayoutConstraint(item: self.listTableView, attribute: .trailing, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .trailing, multiplier: 1, constant: 0),NSLayoutConstraint(item: self.listTableView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)]
        self.view.addSubview(listTableView)
        self.view.addConstraints(listTableViewConstraints)
        
        // ToRegister CustomCell
    }
}
