//
//  OptionsViewController.swift
//  Orbit
//
//  Created by SSY on 2018. 9. 4.
//  Copyright © 2018년 orbit. All rights reserved.
//

import UIKit
import RealmSwift

class OptionsViewController: UIViewController {

    // MARK: properties
    private var realmManager = RealmManager.shared.realm
    var datasourece : Results<Content>!
    private var optionsTableview: UITableView!
    private let items: [String] = ["폰트","모아보기","오픈소스 라이선스",
                                   "백업 / 복원", "모든 데이터 삭제"]
    var backButton : UIImageView = UIImageView()
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        // Do any additional setup after loading the view.
        navigationController?.navigationBar.barTintColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.hidesBackButton = true
        navigationItem.title = "설정"
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

    override func viewWillAppear(_ animated: Bool) {
        setNavigationBackButton(onView: self, in: backButton, bool: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        setNavigationBackButton(onView: self, in: backButton, bool: false)
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
        optionsTableview.backgroundColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        optionsTableview.translatesAutoresizingMaskIntoConstraints = false
        
        let optionsTableviewConstraints:[NSLayoutConstraint] = [
            NSLayoutConstraint(item: optionsTableview, attribute: .top, relatedBy: .equal,
                               toItem: view.safeAreaLayoutGuide,
                               attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: optionsTableview, attribute: .bottom, relatedBy: .equal,
                               toItem: view.safeAreaLayoutGuide,
                               attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: optionsTableview, attribute: .leading, relatedBy: .equal,
                               toItem: view.safeAreaLayoutGuide,
                               attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: optionsTableview, attribute: .trailing, relatedBy: .equal,
                               toItem: view.safeAreaLayoutGuide,
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
        cell.backgroundColor = .clear
        cell.textLabel?.text = items[indexPath.row]
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            break
        case 1:
            break
        case 2:
            break
        case 3:
            break
        case 4:
            showAlert(title: "경 고",
                      message: "지금까지 작성한 일기가 모두 삭제됩니다. \n 삭제된 데이터는 복구할 수 없습니다. \n 삭제하시겠습니까?",
                      cancelBtn: true, buttonTitle: "승인", onView: self) { (okAction) in
                        RealmManager.shared.deletedAll(object: self.datasourece)
                        self.navigationController?.popViewController(animated: true)}
        default:
            break
        }
    }
    
}
