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
    private var user = User()
    private var content = Content()
    private var realmm = try! Realm()
    var datasource : Results<Content>!
    let realmManager = RealmManager.shared.realm
    
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
     var listTableView: UITableView!
    private var writeButton: UIButton!
    var models = [Model.Contents]()
    var thisMonthLabel : UILabel!
    var weeks : [String] = ["Sun", "Mon","Tue","Wed","Thu","Fri","Sat"]
    var weeksStackView : UIStackView!
    var calendarView : JTAppleCalendarView!
    let dateFormatter : DateFormatter = DateFormatter()
    var dates : [Date] = []
    var contentDate : [String] = []
    var optionIcon : UIImageView!
    
    // MARK: IBAction
    @objc func pushOptionViewController(_ sender: UIImageView) {
        let optionsVC = OptionsViewController()
        navigationController?.pushViewController(optionsVC, animated: true)
    }
    
    // MARK: @objc Method
    @objc fileprivate func pushWriteViewController(){
        let writeViewController = WriteViewController(delegate: self)
        navigationController?.pushViewController(writeViewController, animated: true)
    }
    
    // MARK: Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        setUpOptionIcon(bool: true)
        if listTableView == nil {
           return
        }else {
            self.listTableView.reloadData()
            self.calendarView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        setUpOptionIcon(bool: false)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .automatic
        self.navigationItem.title = "Orbit"
        setDatasource(in: getDate(dateFormat: "MMM yyyy"))
        
        print(contentDate)
    }
    
    // MARK: viewWillLayoutSubviews:
    // 뷰가 먼저 보여야하므로
    override func viewWillLayoutSubviews() {
        if self.calendarView == nil {
            setUpUI()
            setUpCalendarView()
            setCalendar()
            setUpLayout()
        }
    }
    
}

// MARK: - extension ListViewController
extension ListViewController {
    // MARK: setUpLayout
    private func setUpLayout(){
        // tableview
        listTableView = UITableView()
        listTableView.separatorStyle = .none
        listTableView.backgroundColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        listTableView.translatesAutoresizingMaskIntoConstraints = false
        
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
            NSLayoutConstraint(item: self.writeButton, attribute: .height, relatedBy: .equal,
                               toItem: nil,
                               attribute: .height, multiplier: 1, constant: 55),
            NSLayoutConstraint(item: self.writeButton, attribute: .width, relatedBy: .equal,
                               toItem: nil,
                               attribute: .width, multiplier: 1, constant: 55),
            NSLayoutConstraint(item: self.writeButton, attribute: .trailing, relatedBy: .equal,
                               toItem: view.safeAreaLayoutGuide,
                               attribute: .centerX, multiplier: 1.9, constant: 0),
            NSLayoutConstraint(item: self.writeButton, attribute: .top, relatedBy: .equal,
                               toItem: view,
                               attribute: .centerY, multiplier: 1.8, constant: 0)]
        
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
    
     //MARK: writeDoneIcon UIImageView
    func setUpOptionIcon(bool : Bool) {
        if bool {
            optionIcon = UIImageView()
            optionIcon.translatesAutoresizingMaskIntoConstraints = false
            
            let constoptionIcon : [NSLayoutConstraint] = [
                NSLayoutConstraint(item: optionIcon, attribute: .width, relatedBy: .equal, toItem: nil,
                                   attribute: .width, multiplier: 1, constant: 36),
                NSLayoutConstraint(item: optionIcon, attribute: .height, relatedBy: .equal, toItem: nil,
                                   attribute: .height, multiplier: 1, constant: 36),
                NSLayoutConstraint(item: optionIcon, attribute: .trailing, relatedBy: .equal, toItem: self.navigationController?.navigationBar, attribute: .trailing, multiplier: 1, constant: -8),
                NSLayoutConstraint(item: optionIcon, attribute: .bottom, relatedBy: .equal, toItem: self.navigationController?.navigationBar, attribute: .bottom, multiplier: 1, constant: -8)]
            navigationController?.navigationBar.addSubview(optionIcon)
            navigationController?.navigationBar.addConstraints(constoptionIcon)
            
            optionIcon.image = UIImage(named: "menu")
            optionIcon.contentMode = .scaleAspectFit
            optionIcon.layer.cornerRadius = 4
            optionIcon.clipsToBounds = true
            let tapWriteDonIcon = UITapGestureRecognizer(target: self, action: #selector(pushOptionViewController))
            optionIcon.addGestureRecognizer(tapWriteDonIcon)
            optionIcon.isUserInteractionEnabled = true
        } else {
            optionIcon.isHidden = true
        }
    }
    
    func setDatasource(in date : String) {
        guard let contentDate = realmManager.objects(Content.self).value(forKey: "createdAt") as? [Date] else {return}
        self.contentDate.removeAll()
        for i in contentDate {
            let date = dateToString(in: i, dateFormat: "yyyyMMdd")
            self.contentDate.append(date)
        }
        print(date)
        datasource = realmManager.objects(Content.self).sorted(byKeyPath: "createdAt", ascending: false)
            .filter("createdAtMonth == '\(date)'")
    }
}
// MARK: - UITableViewDelegate
extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if datasource.count != 0 {
            let diaryViewController = DiaryViewController()
            diaryViewController.diaryData = datasource[indexPath.row]
            self.navigationController?.pushViewController(diaryViewController, animated: true)
            tableView.deselectRow(at: indexPath, animated: false)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
// MARK: - UITableViewDataSource
extension ListViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if datasource.count == 0 {
            return 5
        }
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as! ListTableViewCell
        if datasource.count == 0 {
            return cell
        }
        
        let data = datasource[indexPath.row]
        cell.titleLabel.text = "  \(data.title)"
        cell.dateLabel.text = "\(dateToString(in: data.createdAt, dateFormat: "d"))"
        cell.weekLabel.text = "\(getWeekDay(in: data.createdAt, dateFormat: "EEE"))"
        
        return cell
    }
    
   
}

