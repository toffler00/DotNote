//
//  OptionsViewController.swift
//  Orbit
//
//  Created by SSY on 2018. 9. 4..
//  Copyright © 2018년 orbit. All rights reserved.
//

import UIKit
import RealmSwift

class OptionsViewController: UIViewController {

    // MARK: properties
    private var realmManager = RealmManager.shared.realm
    var datasourece : Results<Content>!
    private var optionsTableview: UITableView!
    private let items: [String] = ["Font Size","Location Setting","OpenSource License",
                                   "BackUp / Restore", "Delete All Data"]
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .automatic
        self.navigationItem.title = "Options"
        self.navigationController?.navigationBar.barTintColor = .white
        // 이곳에서만 크게 타이틀을 보이게 하고 싶은데...
        
        let realmManager = RealmManager.shared.realm
        datasourece = realmManager.objects(Content.self)
        
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
            NSLayoutConstraint(item: optionsTableview, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide,
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
        case 2:
            break
        case 3:
            break
        case 4:
            let alert = UIAlertController(title: "경 고",
                                          message: "지금까지 작성한 일기가 모두 삭제됩니다. \n 삭제된 데이터는 복구할 수 없습니다. \n 삭제하시겠습니까?",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "승인", style: .default) { (okAction) in
                RealmManager.shared.deletedAll(object: self.datasourece)
                self.navigationController?.popViewController(animated: true)
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel) { (cancel) in
                self.dismiss(animated: false, completion: nil)
            }
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        case 5:
            break
        default:
            break
        }
    }
    
}
