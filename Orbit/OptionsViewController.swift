//
//  OptionsViewController.swift
//  Orbit
//
//  Created by SSY on 2018. 9. 4..
//  Copyright © 2018년 orbit. All rights reserved.
//

import UIKit

class OptionsViewController: UIViewController {

    // MARK: properties
    private var optionsTableview: UITableView!
    private let items: [String] = ["Font Size","Calendar",
                                   "Location Setting","OpenSource License",
                                   "BackUp / Restore"]
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       
        // 이곳에서만 크게 타이틀을 보이게 하고 싶은데...
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .automatic
        self.navigationItem.title = "Options"
    }
    
    // MARK: viewWillLayoutSubviews
    override func viewWillLayoutSubviews() {
        if optionsTableview == nil {
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
extension OptionsViewController {
    private func setUpLayout() {
        optionsTableview = UITableView()
        optionsTableview.separatorStyle = .none
        optionsTableview.translatesAutoresizingMaskIntoConstraints = false
        
        let optionsTableviewConstraints:[NSLayoutConstraint] = [
            NSLayoutConstraint(item: optionsTableview, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide,
                               attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: optionsTableview, attribute: .bottom, relatedBy: .equal, toItem: view,
                               attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: optionsTableview, attribute: .leading, relatedBy: .equal, toItem: view.safeAreaLayoutGuide,
                               attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: optionsTableview, attribute: .trailing, relatedBy: .equal, toItem: view.safeAreaLayoutGuide,
                               attribute: .trailing, multiplier: 1, constant: 0)]
        
        view.addSubview(optionsTableview)
        view.addConstraints(optionsTableviewConstraints)
        
        // ToRegister cell
        optionsTableview.register(UITableViewCell.self, forCellReuseIdentifier: "BasicCell")
        // delegate & dataSource
        optionsTableview.delegate = self
        optionsTableview.dataSource = self
    }
}
// MARK: - UITableViewDelegate
extension OptionsViewController: UITableViewDelegate {
    
}

// MARK: - UITableViewDataSource
extension OptionsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 1:
            break
        default:
            break
        }
    }
    
}
