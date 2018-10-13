//
//  ListViewController.swift
//  Orbit
//
//  Created by SSY on 2018. 8. 30..
//  Copyright © 2018년 orbit. All rights reserved.
//

import UIKit
import RealmSwift
import JTAppleCalendar


class ListViewController: UIViewController {
    
    // MARK: Properties
    var user = User()
    var realm = try! Realm()
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    private var listTableView: UITableView!
    private var writeButton: UIButton!
    var models = [Model.Contents]()
    var thisMonthLabel : UILabel!
    var weeks : [String] = ["Sun", "Mon","Tue","Wed","Thu","Fri","Sat"]
    var weeksStackView : UIStackView!
    var calendarView : JTAppleCalendarView!
    let dateFormatter : DateFormatter = DateFormatter()
    
    // MARK: IBAction
    @IBAction func pushOptionViewController(_ sender: UIBarButtonItem) {
        let optionsVC = OptionsViewController()
        self.navigationController?.pushViewController(optionsVC, animated: true)
    }
    
    // MARK: @objc Method
    @objc fileprivate func pushWriteViewController(){
        let writeViewController = WriteViewController(delegate: self)
        self.navigationController?.pushViewController(writeViewController, animated: true)
    }
    
    // MARK: Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        if appdelegate.datasource.count == 0 {
           return
        }else {
            self.listTableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .automatic
        self.navigationItem.title = "Orbit"
        
    }
    
    // MARK: viewWillLayoutSubviews:
    // 뷰가 먼저 보여야하므로
    override func viewWillLayoutSubviews() {
        if self.listTableView == nil {
            setUpUI()
            setUpCalendarView()
            setCalendar()
            setUpLayout()
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
        // tableview
        self.listTableView = UITableView()
        self.listTableView.translatesAutoresizingMaskIntoConstraints = false
        
        let listTableViewConstraints: [NSLayoutConstraint] = [
            NSLayoutConstraint(item: listTableView, attribute: .top,relatedBy: .equal, toItem: calendarView,
                               attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: listTableView, attribute: .leading, relatedBy: .equal, toItem: view.safeAreaLayoutGuide,
                               attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: listTableView, attribute: .trailing, relatedBy: .equal, toItem: view.safeAreaLayoutGuide,
                               attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: listTableView, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide,
                               attribute: .bottom, multiplier: 1, constant: 0)]

        self.view.addSubview(listTableView)
        self.view.addConstraints(listTableViewConstraints)
        
        // button
        self.writeButton = UIButton()
        self.writeButton.clipsToBounds = true
        self.writeButton.backgroundColor = .clear
        self.writeButton.setImage(UIImage(named: "pluswrite"), for: .normal)
        //        self.writeButton.layer.cornerRadius = 0.5 * self.writeButton.bounds.size.height
        self.writeButton.translatesAutoresizingMaskIntoConstraints = false
        
        let writeButtonConstraints: [NSLayoutConstraint] = [
            NSLayoutConstraint(item: self.writeButton, attribute: .height, relatedBy: .equal, toItem: nil,
                               attribute: .height, multiplier: 1, constant: 55),
            NSLayoutConstraint(item: self.writeButton, attribute: .width, relatedBy: .equal, toItem: nil,
                               attribute: .width, multiplier: 1, constant: 55),
            NSLayoutConstraint(item: self.writeButton, attribute: .trailing, relatedBy: .equal, toItem: view.safeAreaLayoutGuide,
                               attribute: .centerX, multiplier: 1.9, constant: 0),
            NSLayoutConstraint(item: self.writeButton, attribute: .top, relatedBy: .equal, toItem: view,
                               attribute: .centerY, multiplier: 1.7, constant: 0)]
        
        // To add writebutton in listTableview
        self.view.addSubview(writeButton)
        self.view.addConstraints(writeButtonConstraints)
        self.writeButton.layer.cornerRadius = writeButton.frame.width / 2
        
        // writeButton.addTarget
        self.writeButton.addTarget(self, action: #selector(pushWriteViewController), for: .touchUpInside)

        // MARK: ToRegister CustomCell
        self.listTableView.register(ListTableViewCell.self, forCellReuseIdentifier: "ListTableViewCell")
        self.listTableView.delegate = self
        self.listTableView.dataSource = self
    }
}
// MARK: - UITableViewDelegate
extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if appdelegate.datasource.count != 0 {
            let diaryViewController = DiaryViewController()
            self.navigationController?.pushViewController(diaryViewController, animated: true)
            tableView.deselectRow(at: indexPath, animated: false)
            let datasource = appdelegate.datasource[indexPath.row]
            diaryViewController.datasource = datasource
        }
    }
}
// MARK: - UITableViewDataSource
extension ListViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if appdelegate.datasource.count == 0 {
            return 15
        }
        return appdelegate.datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as! ListTableViewCell
        //        cell.model = models[indexPath.row]
        if appdelegate.datasource.count == 0 {
            return cell
        }
        let datasource = appdelegate.datasource[indexPath.row]
        cell.titleLabel.text = datasource.title
        return cell
    }
}
// MARK: - DiaryWriteDelegate
extension ListViewController: DiaryWriteDelegate {
    func writeDone() {
        // MARK: - ToDo
    }   
}
