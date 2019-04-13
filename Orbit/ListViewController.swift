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
import CoreLocation
import ExpandableButton
import NXDrawKit


class ListViewController: UIViewController {
    
    
    // MARK: Properties
    private var user = User()
    private var content = Content()
    private var realmm = try! Realm()
    var datasource : Results<Content>!
    var settingData : Results<Settings>!
    let realmManager = RealmManager.shared.realm
    
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    var listTableView: UITableView!
    private var writeButton: UIImageView!
    var models = [Model.Contents]()
    var thisMonthLabel : UILabel!
    var weeks : [String] = ["일","월","화","수","목","금","토"]
    var weeksStackView : UIStackView!
    var calendarView : JTAppleCalendarView!
    let dateFormatter : DateFormatter = DateFormatter()
    var dates : [Date] = []
    var contentDate : [String] = []
    var optionIcon : UIImageView!
    var weatherItem : Int!
    
    var exButton : ExpandableButtonView = {
        var item : [ExpandableButtonItem] = []
        let btn = ExpandableButtonView(items: item)
        return btn
    }()
    var selectedDate : Date!
    var locationManager: CLLocationManager!
    var coordinate : CLLocationCoordinate2D?  {
        didSet(oldValue) {
            if oldValue == nil {
                DispatchQueue(label: "io.orbit.callWeatherAPI").async {
                    let weatherApi = WeatherAPI()
                    let lati = Float(CGFloat((self.coordinate?.latitude)!))
                    let longi = Float(CGFloat((self.coordinate?.longitude)!))
                    weatherApi.call(lati: lati, longi: longi, complete: { (error, weather) in
                        if let error = error {
                            log.error(error)
                            return
                        }
                        if let weather = weather {
                            //up update
                            DispatchQueue.main.async {
                                log.debug(weather.weather)
                                let items = weather.weather[0]
                                self.weatherItem = items.id
                            }
                        }
                    })
                }
            }
        }
    }
    // MARK: IBAction
    @objc func pushOptionViewController(_ sender: UIImageView) {
        let optionsVC = OptionsViewController()
        navigationController?.pushViewController(optionsVC, animated: true)
    }
    
    // MARK: @objc Method
    @objc func pushWriteViewController(){
        let writeViewController = WriteViewController(delegate: self)
        if self.weatherItem == nil {
            self.weatherItem = 0
            writeViewController.weatherItem = self.weatherItem
            navigationController?.pushViewController(writeViewController, animated: true)
        } else {
            writeViewController.weatherItem = self.weatherItem
            navigationController?.pushViewController(writeViewController, animated: true)
        }
    }
    
    @objc func pushDrawingViewController() {
        let drawingDiaryViewController = DrawingDiaryViewController()
        if self.weatherItem == nil {
            self.weatherItem = 0
            drawingDiaryViewController.weatherItem = self.weatherItem
            drawingDiaryViewController.drawingDiarySaveDeleagate = self
            navigationController?.pushViewController(drawingDiaryViewController, animated: true)
        } else {
            drawingDiaryViewController.weatherItem = self.weatherItem
            drawingDiaryViewController.drawingDiarySaveDeleagate = self
            navigationController?.pushViewController(drawingDiaryViewController, animated: true)
        }
    }
    
    @objc func presentMemoViewController(){
        let backgroundViewController = BackGroundViewController()
        backgroundViewController.selectedDate = self.selectedDate
        backgroundViewController.modalPresentationStyle = .overFullScreen
        backgroundViewController.saveMemoDelegate = self
        present(backgroundViewController, animated: false, completion: nil)
    }
    
    func reloadData(){
        self.listTableView.reloadData()
        self.calendarView.reloadData()
    }
    
    // MARK: Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        setUpOptionIcon(bool: true)
        //        setWriteBtn(bool: true)
        setExpandableButton()
        setNavigationBackButton(onView: self, bool: false)
        if listTableView == nil {
            return
        }else {
            
            self.calendarView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        setUpOptionIcon(bool: false)
        //        setWriteBtn(bool: false)
        exButton.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.view.frame)
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .automatic
        setSettingsDefaultValue()
        setNavieTitle()
        self.view.backgroundColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        setDatasource(in: getDate(dateFormat: "MMM yyyy"))
        setupLocationManager()
        print(contentDate)
    }
    
    func setNavieTitle() {
        if settingData.count == 1 {
            let data = settingData[0]
            let naviTitleFont = data.naviTitleFont
            let screensWidth = UIScreen.main.bounds.width
            switch screensWidth {
            case ...320:
                let titleFont = setFont(type: .navigationTitle, onView: self, font: naviTitleFont, size: 26)
                self.navigationController?.navigationBar.largeTitleTextAttributes =
                    [NSAttributedString.Key.font : titleFont!]
                self.navigationItem.title = "Dot Note"
            case 321...:
                let titleFont = setFont(type: .navigationTitle, onView: self, font: naviTitleFont, size: 34)
                self.navigationController?.navigationBar.largeTitleTextAttributes =
                    [NSAttributedString.Key.font : titleFont!]
                self.navigationItem.title = "Dot Note"
            default:
                let titleFont = setFont(type: .navigationTitle, onView: self, font: naviTitleFont, size: 34)
                self.navigationController?.navigationBar.largeTitleTextAttributes =
                    [NSAttributedString.Key.font : titleFont!]
                self.navigationItem.title = "Dot Note"
            }
        } else {
            self.navigationItem.title = "Dot Note"
        }
        
    }
    
    func setSettingsDefaultValue() {
        self.settingData = realmManager.objects(Settings.self)
        if settingData.count == 0 {
            let data = Settings(categoryFont: "NanumMyeongjoEco", titleFont: "NanumBarunGothic",
                                contentsFont: "NanumBarunGothic", fontSize: 16, collectionFilter: 1)
            RealmManager.shared.creat(object: data)
        }
        print(settingData)
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
                                   attribute: .width, multiplier: 1, constant: 32),
                NSLayoutConstraint(item: optionIcon, attribute: .height, relatedBy: .equal, toItem: nil,
                                   attribute: .height, multiplier: 1, constant: 32),
                NSLayoutConstraint(item: optionIcon, attribute: .trailing, relatedBy: .equal, toItem: self.navigationController?.navigationBar,
                                   attribute: .trailing, multiplier: 1, constant: -14),
                NSLayoutConstraint(item: optionIcon, attribute: .top, relatedBy: .equal, toItem: self.navigationController?.navigationBar,
                                   attribute: .top, multiplier: 1, constant: 8)]
            navigationController?.navigationBar.addSubview(optionIcon)
            navigationController?.navigationBar.addConstraints(constoptionIcon)
            
            optionIcon.image = UIImage(named: "moreMenu")
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
    
    //MARK: writeButton UIImageView
    func setWriteBtn(bool : Bool) {
        if bool {
            writeButton = UIImageView()
            writeButton.translatesAutoresizingMaskIntoConstraints = false
            
            let writeButtonConstraints: [NSLayoutConstraint] = [
                NSLayoutConstraint(item: writeButton, attribute: .height, relatedBy: .equal,
                                   toItem: nil,
                                   attribute: .height, multiplier: 1, constant: 36),
                NSLayoutConstraint(item: writeButton, attribute: .width, relatedBy: .equal,
                                   toItem: nil,
                                   attribute: .width, multiplier: 1, constant: 36),
                NSLayoutConstraint(item: writeButton, attribute: .centerX, relatedBy: .equal,
                                   toItem: optionIcon,
                                   attribute: .centerX, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: writeButton, attribute: .bottom, relatedBy: .equal,
                                   toItem: self.navigationController?.navigationBar,
                                   attribute: .bottom, multiplier: 1, constant: -8)]
            
            // To add writebutton in listTableview
            self.navigationController?.navigationBar.addSubview(writeButton)
            self.navigationController?.navigationBar.addConstraints(writeButtonConstraints)
            writeButton.layer.cornerRadius = writeButton.frame.width / 2
            writeButton.clipsToBounds = true
            writeButton.backgroundColor = .clear
            writeButton.image = UIImage(named: "edit")
            writeButton.isUserInteractionEnabled = true
            // writeButton.addTarget
            let tapWriteBtn = UITapGestureRecognizer(target: self, action: #selector(pushWriteViewController))
            writeButton.addGestureRecognizer(tapWriteBtn)
        } else {
            writeButton.isHidden = true
        }
    }
    
    func setDatasource(in date : String) {
        guard let contentDate = self.realmManager.objects(Content.self).value(forKey: "createdAt") as? [Date] else {return}
        self.contentDate.removeAll()
        for i in contentDate {
            let date = self.dateToString(in: i, dateFormat: "yyyyMMdd")
            self.contentDate.append(date)
        }
        self.datasource = self.realmManager.objects(Content.self).sorted(byKeyPath: "createdAt", ascending: false)
            .filter("createdAtMonth == '\(date)'")
    }
}

// MARK: - UITableViewDelegate
extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if datasource.count != 0 {
            let diaryViewController = DiaryViewController()
            diaryViewController.deleteMemoDelegate = self
            diaryViewController.diaryData = datasource[indexPath.row]
            self.navigationController?.pushViewController(diaryViewController, animated: true)
            tableView.deselectRow(at: indexPath, animated: false)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    //        if editingStyle == UITableViewCellEditingStyle.delete {
    //            print("deleted")
    //            let content = datasource[indexPath.row]
    //            print(content)
    //            RealmManager.shared.delete(object: content)
    //            listTableView.reloadData()
    //        }
    //        calendarView.reloadData()
    //    }
}
// MARK: - UITableViewDataSource
extension ListViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if datasource.count == 0 {
            return 0
        }
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as! ListTableViewCell
        if datasource.count == 0 {
            return cell
        }
        let data = datasource[indexPath.row]
        let typeName = data.type
        switch typeName {
        case "memo" :
            cell.titleLabel.text = "  \(data.body)"
            cell.contentType.image = UIImage(named: "memo")
        case "diary" :
            cell.titleLabel.text = "  \(data.title)"
            cell.contentType.image = UIImage(named: "edit")
        case "drawing" :
            cell.titleLabel.text = "  \(data.title)"
            cell.contentType.image = UIImage(named: "draw")
        default :
            cell.titleLabel.text = "  \(data.title)"
        }
        cell.dateLabel.text = "\(dateToString(in: data.createdAt, dateFormat: "yyyy.MM.dd EEE"))"
        return cell
    }
    
}

