//
//  ThemeSettingViewController.swift
//  Orbit
//
//  Created by ilhan won on 17/03/2019.
//  Copyright © 2019 orbit. All rights reserved.
//

import UIKit
import RealmSwift

enum ThemeList : Int {
    case naviFont = 0, contentsFont, fontSize, total
}

final class ThemeSettingViewController : UIViewController {
    
    private var realm = try! Realm()
    private var settingData : Results<Settings>!
    
    private var themeTableView : UITableView!
    private var spacingView : UIView!
    private var spacingInnerView : UIView!
    private var fontExampleTextView : UITextView!
    private var backButton : UIImageView = UIImageView()
    private var themeList = [ThemeList : [[String : String]]]()
    private var themeData = [["group" : "naviFont","themeName": "안녕하세요"],
                     ["group" : "naviFont","themeName": "안녕하세요"],
                     ["group" : "contentsFont","themeName": "안녕하세요"],
                     ["group" : "contentsFont","themeName": "안녕하세요"],
                     ["group" : "contentsFont","themeName": "안녕하세요"],
                     ["group" : "fontSize","themeName": ""]]
    private var sectionHeight : CGFloat = 32
    private var fontSizeList = [1,2,3,4,5]
    private var fontBtnStackView : UIStackView!
    private var sizeButtonFirst : UIButton!
    private var sizeButtonSecond : UIButton!
    private var sizeButtonThird : UIButton!
    private var sizeButtonFourth : UIButton!
    private var sizeButtonFifth : UIButton!
    
    override func viewDidLoad() {
        let realmManager = RealmManager.shared.realm
        settingData = realmManager.objects(Settings.self)
        navigationController?.navigationBar.barTintColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.hidesBackButton = true
        navigationItem.title = "폰트"
        self.view.backgroundColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        setUpUI()
        sortData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationBackButton(onView: self, in: backButton, bool: true)
//        setNaviTitle(bool: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        setNavigationBackButton(onView: self, in: backButton, bool: false)
//        setNaviTitle(bool: false)
    }
    
    func sortData() {
        themeList[.naviFont] = themeData.filter({$0["group"] == "naviFont"})
        themeList[.contentsFont] = themeData.filter({$0["group"] == "contentsFont"})
        themeList[.fontSize] = themeData.filter({$0["group"] == "fontSize"})
    }
}

//MARK: UITableViewDelegate
extension ThemeSettingViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let size = settingData[0].contentsFontSize
        let fontSize = CGFloat(size)
        let screenWidth = UIScreen.main.bounds.width
        switch indexPath {
        case [0,0]:
            if screenWidth >= 321 {
                let navigationTitleFont = UIFont(name: "NanumBarunGothicBold", size: 34)
                self.navigationController?.navigationBar.largeTitleTextAttributes =
                    [NSAttributedString.Key.font : navigationTitleFont!]
                navigationItem.title = "폰트"
                try! realm.write {
                    settingData[0].naviTitleFont = "NanumBarunGothicBold"
                }
            } else {
                let navigationTitleFont = UIFont(name: "NanumBarunGothicBold", size: 26)
                self.navigationController?.navigationBar.largeTitleTextAttributes =
                    [NSAttributedString.Key.font : navigationTitleFont!]
                navigationItem.title = "폰트"
                try! realm.write {
                    settingData[0].naviTitleFont = "NanumBarunGothicBold"
                }
            }
            break
        case [0,1]:
            if screenWidth >= 321 {
                let navigationTitleFont = UIFont(name: "NanumMyeongjoEco", size: 34)
                self.navigationController?.navigationBar.largeTitleTextAttributes =
                    [NSAttributedString.Key.font : navigationTitleFont!]
                navigationItem.title = "폰트"
                try! realm.write {
                    settingData[0].naviTitleFont = "NanumMyeongjoEco"
                }
            } else {
                let navigationTitleFont = UIFont(name: "NanumMyeongjoEco", size: 26)
                self.navigationController?.navigationBar.largeTitleTextAttributes =
                    [NSAttributedString.Key.font : navigationTitleFont!]
                navigationItem.title = "폰트"
                try! realm.write {
                    settingData[0].naviTitleFont = "NanumMyeongjoEco"
                }
            }
            break
        case [1,0]:
            fontExampleTextView.font = UIFont(name: "NanumBarunGothic", size: fontSize)
            try! realm.write {
                settingData[0].contentsFont = "NanumBarunGothic"
            }
            break
        case [1,1]:
            fontExampleTextView.font = UIFont(name: "NanumBrush", size: fontSize)
            try! realm.write {
                settingData[0].contentsFont = "NanumBrush"
            }
            break
        case [1,2]:
            fontExampleTextView.font = UIFont(name: "NanumMyeongjoEco", size: fontSize)
            try! realm.write {
                settingData[0].contentsFont = "NanumMyeongjoEco"
            }
            break
        default:
            break
        }
    }
}

//MARK: UITableViewDatasource
extension ThemeSettingViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        let sections = ThemeList.total.rawValue
        return sections
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let theme = ThemeList(rawValue: section), let listData = themeList[theme], listData.count > 0 {
             return sectionHeight
        }
        return 0
       
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: sectionHeight)
        let headerLabel = UILabel()
        headerLabel.frame = CGRect(x: 15, y: 0, width: tableView.bounds.width / 2, height: sectionHeight)
        headerLabel.textColor = .black
        headerLabel.font = UIFont(name: "NanumBarunGothic", size: 18)
        if let sectionName = ThemeList(rawValue: section) {
            switch sectionName {
            case .naviFont:
                headerLabel.text = "카테고리 글씨체"
            case .contentsFont:
                headerLabel.text = "일기장 글씨체"
            case .fontSize :
                headerLabel.text = "글씨크기"
            default :
                headerLabel.text = ""
            }
        }
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 50)
        footerView.backgroundColor = .clear
        addTopBorderLine(to: footerView, height: 0.7)
        return footerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sectionTitle = ThemeList(rawValue: section),
            let listData = themeList[sectionTitle] {
            print("section = \(section) \(sectionTitle)")
            return listData.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
        cell.backgroundColor = .white
        cell.selectionStyle = .none
        let contentView = UIView()
        contentView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: cell.bounds.height)
        cell.addSubview(contentView)
        if let sectionTitle = ThemeList(rawValue: indexPath.section),
            let listData = themeList[sectionTitle]?[indexPath.row] {
            print(listData)
            if let titleLabel = cell.textLabel {
                switch indexPath {
                case [0,0] :
                    addTopBorderLine(to: contentView, height: 0.7)
                    titleLabel.text = listData["themeName"]
                    titleLabel.font = UIFont(name: "NanumBarunGothicBold", size: 20)
                    break
                case [0,1] :
                    titleLabel.text = listData["themeName"]
                    titleLabel.font = UIFont(name: "NanumMyeongjoEco", size: 20)
                    break
                case [1,0] :
                    addTopBorderLine(to: contentView, height: 0.7)
                    titleLabel.text = listData["themeName"]
                    titleLabel.font = UIFont(name: "NanumBarunGothic", size: 20)
                    break
                case [1,1] :
                    titleLabel.text = listData["themeName"]
                    titleLabel.font = UIFont(name: "NanumBrush", size: 20)
                    break
                case [1,2] :
                    titleLabel.text = listData["themeName"]
                    titleLabel.font = UIFont(name: "NanumMyeongjoEco", size: 20)
                    break
                case [2,0] :
                    addTopBorderLine(to: contentView, height: 0.7)
                    titleLabel.text = listData["themeName"]
                    setSizeButton(cell: cell)
                    setFontSizeButton()
                    break
                default :
                    break
                }
            }
        }
        return cell
    }
}

extension ThemeSettingViewController {
    func setUpUI() {
        let height = self.navigationController?.navigationBar.bounds.height
        let window = UIApplication.shared.keyWindow
        let safePadding = window?.safeAreaInsets.top
        let heightPadding = CGFloat(height!) + CGFloat(safePadding!)
        
        spacingView = UIView()
        spacingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spacingView)
        
        spacingInnerView = UIView()
        spacingInnerView.translatesAutoresizingMaskIntoConstraints = false
        spacingView.addSubview(spacingInnerView)
        
        fontExampleTextView = UITextView()
        fontExampleTextView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(fontExampleTextView)
        
        themeTableView = UITableView()
        themeTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(themeTableView)
        themeTableView.separatorStyle = .singleLine
        themeTableView.backgroundColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        
        spacingView.topAnchor.constraint(equalTo: view.topAnchor, constant: heightPadding).isActive = true
        spacingView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        spacingView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        spacingView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        spacingInnerView.topAnchor.constraint(equalTo: spacingView.topAnchor, constant: 0).isActive = true
        spacingInnerView.leadingAnchor.constraint(equalTo: spacingView.leadingAnchor, constant: 0).isActive = true
        spacingInnerView.trailingAnchor.constraint(equalTo: spacingView.trailingAnchor, constant: 0).isActive = true
        spacingInnerView.heightAnchor.constraint(equalToConstant: 5).isActive = true
        spacingInnerView.backgroundColor = #colorLiteral(red: 0.1843137255, green: 0.1411764706, blue: 0.1333333333, alpha: 0.199261582)
        
        fontExampleTextView.topAnchor.constraint(equalTo: spacingView.bottomAnchor, constant: 0).isActive = true
        fontExampleTextView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 8).isActive = true
        fontExampleTextView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -8).isActive = true
        fontExampleTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        fontExampleTextView.text = "안녕하세요. 글씨체를 바꿔 보세요."
        fontExampleTextView.isEditable = false
        fontExampleTextView.font = UIFont(name: "NanumBarunGothic", size: 16)
        fontExampleTextView.backgroundColor = UIColor(red: 246/255, green: 252/255, blue: 226/255, alpha: 1)
        
        themeTableView.topAnchor.constraint(equalTo: fontExampleTextView.bottomAnchor, constant: 24).isActive = true
        themeTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        themeTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        themeTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        // ToRegister cell
        themeTableView.register(UITableViewCell.self, forCellReuseIdentifier: "BasicCell")
        // delegate & dataSource
        themeTableView.delegate = self
        themeTableView.dataSource = self
    }
    

    func addBottomBorderLine(to view : UIView ,height : CGFloat) {
        let border = CALayer()
        border.frame = CGRect(x: 0, y: view.bounds.height - height,
                              width: view.bounds.width, height: height)
        border.backgroundColor = UIColor(red: 235 / 255, green: 235 / 255, blue: 235 / 255, alpha: 1).cgColor
        view.layer.addSublayer(border)
    }
    
    func addTopBorderLine(to view : UIView, height : CGFloat) {
        let border = CALayer()
        border.frame = CGRect(x: 0, y: 0,
                              width: view.bounds.width, height: height)
        border.backgroundColor = UIColor(red: 235 / 255, green: 235 / 255, blue: 235 / 255, alpha: 1).cgColor
        view.layer.addSublayer(border)
    }
    
    func setSizeButton(cell : UITableViewCell) {
        fontBtnStackView = UIStackView()
        sizeButtonFirst = UIButton()
        sizeButtonSecond = UIButton()
        sizeButtonThird = UIButton()
        sizeButtonFourth = UIButton()
        sizeButtonFifth = UIButton()
        
        sizeButtonFirst.translatesAutoresizingMaskIntoConstraints = false
        sizeButtonSecond.translatesAutoresizingMaskIntoConstraints = false
        sizeButtonThird.translatesAutoresizingMaskIntoConstraints = false
        sizeButtonFourth.translatesAutoresizingMaskIntoConstraints = false
        sizeButtonFifth.translatesAutoresizingMaskIntoConstraints = false
    
        fontBtnStackView.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(fontBtnStackView)
        fontBtnStackView.addArrangedSubview(sizeButtonFirst)
        fontBtnStackView.addArrangedSubview(sizeButtonSecond)
        fontBtnStackView.addArrangedSubview(sizeButtonThird)
        fontBtnStackView.addArrangedSubview(sizeButtonFourth)
        fontBtnStackView.addArrangedSubview(sizeButtonFifth)
        
        fontBtnStackView.centerXAnchor.constraint(equalTo: cell.centerXAnchor, constant: 0).isActive = true
        fontBtnStackView.centerYAnchor.constraint(equalTo: cell.centerYAnchor, constant: 0).isActive = true
        fontBtnStackView.heightAnchor.constraint(equalTo: cell.heightAnchor, multiplier: 0.9).isActive = true
        fontBtnStackView.widthAnchor.constraint(equalTo: cell.widthAnchor, multiplier: 0.9).isActive = true
        fontBtnStackView.axis = .horizontal
        fontBtnStackView.alignment = .fill
        fontBtnStackView.distribution = .fillEqually
        fontBtnStackView.spacing = 2
        
        sizeButtonFirst.centerYAnchor.constraint(equalTo: fontBtnStackView.centerYAnchor, constant: 0).isActive = true
        sizeButtonFirst.widthAnchor.constraint(equalToConstant: 60).isActive = true
        sizeButtonFirst.heightAnchor.constraint(equalTo: fontBtnStackView.heightAnchor, constant: 0).isActive = true
        sizeButtonFirst.layer.cornerRadius = 4
        sizeButtonFirst.clipsToBounds = true
        
        sizeButtonSecond.centerYAnchor.constraint(equalTo: fontBtnStackView.centerYAnchor, constant: 0).isActive = true
        sizeButtonSecond.widthAnchor.constraint(equalToConstant: 60).isActive = true
        sizeButtonSecond.heightAnchor.constraint(equalTo: fontBtnStackView.heightAnchor, constant: 0).isActive = true
        sizeButtonSecond.layer.cornerRadius = 4
        sizeButtonSecond.clipsToBounds = true
        
        sizeButtonThird.centerYAnchor.constraint(equalTo: fontBtnStackView.centerYAnchor, constant: 0).isActive = true
        sizeButtonThird.widthAnchor.constraint(equalToConstant: 60).isActive = true
        sizeButtonThird.heightAnchor.constraint(equalTo: fontBtnStackView.heightAnchor, constant: 0).isActive = true
        sizeButtonThird.layer.cornerRadius = 4
        sizeButtonThird.clipsToBounds = true
        
        sizeButtonFourth.centerYAnchor.constraint(equalTo: fontBtnStackView.centerYAnchor, constant: 0).isActive = true
        sizeButtonFourth.widthAnchor.constraint(equalToConstant: 60).isActive = true
        sizeButtonFourth.heightAnchor.constraint(equalTo: fontBtnStackView.heightAnchor, constant: 0).isActive = true
        sizeButtonFourth.layer.cornerRadius = 4
        sizeButtonFourth.clipsToBounds = true
        
        sizeButtonFifth.centerYAnchor.constraint(equalTo: fontBtnStackView.centerYAnchor, constant: 0).isActive = true
        sizeButtonFifth.widthAnchor.constraint(equalToConstant: 60).isActive = true
        sizeButtonFifth.heightAnchor.constraint(equalTo: fontBtnStackView.heightAnchor, constant: 0).isActive = true
        sizeButtonFifth.layer.cornerRadius = 4
        sizeButtonFifth.clipsToBounds = true
    }
    
    func setFontSizeButton() {
        sizeButtonFirst.setTitle("1", for: .normal)
        sizeButtonFirst.tag = 1
        sizeButtonFirst.setTitleColor(.black, for: .normal)
        sizeButtonFirst.setBackgroundColor(.clear, for: .normal)
        sizeButtonFirst.addTarget(self, action: #selector(changeFontSize(sender:)), for: .touchUpInside)
        sizeButtonFirst.addTarget(self, action: #selector(selectedSizeButton(sender:)), for: .touchUpInside)
    
        sizeButtonSecond.setTitle("2", for: .normal)
        sizeButtonSecond.tag = 2
        sizeButtonSecond.setTitleColor(.black, for: .normal)
        sizeButtonSecond.setBackgroundColor(.clear, for: .normal)
        sizeButtonSecond.addTarget(self, action: #selector(changeFontSize(sender:)), for: .touchUpInside)
        sizeButtonSecond.addTarget(self, action: #selector(selectedSizeButton(sender:)), for: .touchUpInside)
        
        sizeButtonThird.setTitle("3", for: .normal)
        sizeButtonThird.tag = 3
        sizeButtonThird.setTitleColor(.black, for: .normal)
        sizeButtonThird.setBackgroundColor(.clear, for: .normal)
        sizeButtonThird.addTarget(self, action: #selector(changeFontSize(sender:)), for: .touchUpInside)
        sizeButtonThird.addTarget(self, action: #selector(selectedSizeButton(sender:)), for: .touchUpInside)
        
        sizeButtonFourth.setTitle("4", for: .normal)
        sizeButtonFourth.tag = 4
        sizeButtonFourth.setTitleColor(.black, for: .normal)
        sizeButtonFourth.setBackgroundColor(.clear, for: .normal)
        sizeButtonFourth.addTarget(self, action: #selector(changeFontSize(sender:)), for: .touchUpInside)
        sizeButtonFourth.addTarget(self, action: #selector(selectedSizeButton(sender:)), for: .touchUpInside)
        
        sizeButtonFifth.setTitle("5", for: .normal)
        sizeButtonFifth.tag = 5
        sizeButtonFifth.setTitleColor(.black, for: .normal)
        sizeButtonFifth.setBackgroundColor(.clear, for: .normal)
        sizeButtonFifth.addTarget(self, action: #selector(changeFontSize(sender:)), for: .touchUpInside)
        sizeButtonFifth.addTarget(self, action: #selector(selectedSizeButton(sender:)), for: .touchUpInside)
    }
    
    @objc func selectedSizeButton(sender : UIButton) {
        let buttonList : [UIButton] = [sizeButtonFirst, sizeButtonSecond, sizeButtonThird, sizeButtonFourth, sizeButtonFifth]
        for btn in buttonList {
            if sender.tag == btn.tag {
                sender.isSelected = true
                sender.setBackgroundColor(.lightGray, for: .selected)
                sender.setTitleColor(.white, for: .selected)
            } else {
                btn.isSelected = false
                btn.setBackgroundColor(.clear, for: .normal)
                btn.setTitleColor(.black, for: .normal)
            }
        }
        
    }
    
    @objc func changeFontSize(sender : UIButton) {
        let tag = sender.tag
        let fontName = settingData[0].contentsFont
        
        switch tag {
        case 1:
            fontExampleTextView.font = UIFont(name: fontName, size: 16)
            try! realm.write {
                settingData[0].contentsFontSize = 16
            }
            break
        case 2:
            fontExampleTextView.font = UIFont(name: fontName, size: 18)
            try! realm.write {
                settingData[0].contentsFontSize = 18
            }
            break
        case 3:
            fontExampleTextView.font = UIFont(name: fontName, size: 20)
            try! realm.write {
                settingData[0].contentsFontSize = 20
            }
            break
        case 4:
            fontExampleTextView.font = UIFont(name: fontName, size: 22)
            try! realm.write {
                settingData[0].contentsFontSize = 22
            }
            break
        case 5:
            fontExampleTextView.font = UIFont(name: fontName, size: 24)
            try! realm.write {
                settingData[0].contentsFontSize = 24
            }
            break
        default:
            fontExampleTextView.font = UIFont(name: fontName, size: 16)
            try! realm.write {
                settingData[0].contentsFontSize = 16
            }
            break
        }
    }
}


