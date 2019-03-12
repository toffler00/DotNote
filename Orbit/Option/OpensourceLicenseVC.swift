//
//  OpensourceLicense.swift
//  Orbit
//
//  Created by ilhan won on 06/03/2019.
//  Copyright © 2019 orbit. All rights reserved.
//

import UIKit

class OpensourceLicenseVC : UIViewController {
    
    private var licenseTableView : UITableView!
    private var licenseList : [String] = []
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .automatic
        self.navigationItem.title = "오픈소스 라이선스"
        self.navigationItem.hidesBackButton = true
        
    }
    
    func setTableView() {
        licenseTableView = UITableView()
        
        licenseTableView.translatesAutoresizingMaskIntoConstraints = false
        
        licenseTableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        licenseTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        licenseTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        licenseTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
    }
}

extension OpensourceLicenseVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        return cell
    }
    
    
}

extension OpensourceLicenseVC : UITableViewDelegate {
    
}
