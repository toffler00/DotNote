//
//  OptionsViewController.swift
//  Orbit
//
//  Created by SSY on 2018. 9. 4.
//  Copyright © 2018년 orbit. All rights reserved.
//

import UIKit
import RealmSwift
import MessageUI

enum OptionTitle : Int {
    case theme = 0, collection, support, deleteData, total
}


class OptionsViewController: UIViewController, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate{
    
    // MARK: properties
    private var realmManager = RealmManager.shared.realm
    var datasourece : Results<Content>!
    private var optionsTableview: UITableView!
    private var spacingView : UIView!
    private var spacingInnerView : UIView!
    private let optionData = [["optionName" : "폰트", "group" : "theme"],
                              ["optionName" : "메모보기", "group" : "collection"],
                              ["optionName" : "일기보기", "group" : "collection"],
                              ["optionName" : "의견보내기", "group" : "support"],
                              ["optionName" : "Dot Note 사용법", "group" : "support"],
                              ["optionName" : "Open-source License", "group" : "support"],
                              ["optionName" : "모든데이터 삭제", "group" : "deleteData"]]
    
    var optionList = [OptionTitle : [[String : String]]]()
    var backButton : UIImageView = UIImageView()
    var sectionHeaderHeight : CGFloat = 32
    
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationController?.navigationBar.barTintColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.hidesBackButton = true
        navigationItem.title = "설정"
        self.view.backgroundColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        // 이곳에서만 크게 타이틀을 보이게 하고 싶은데...
        
        let realmManager = RealmManager.shared.realm
        datasourece = realmManager.objects(Content.self)
        sortData()
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
    
    func sortData() {
        optionList[.theme] = optionData.filter({ $0["group"] == "theme"})
        optionList[.collection] = optionData.filter({ $0["group"] == "collection"})
        optionList[.support] = optionData.filter({ $0["group"] == "support"})
        optionList[.deleteData] = optionData.filter({$0["group"] == "deleteData"})
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
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled :
            controller.dismiss(animated: true, completion: nil)
        case .failed :
            showAlert(title: nil, message: "메일보내기에 실패하였습니다. \n 메일보내기를 취소할까요?",
                      cancelBtn: false, buttonTitle: "확인", onView: controller) { (action) in
                        controller.dismiss(animated: true, completion: nil)
            }
        case .saved :
            showAlert(title: nil, message: "임시저장에 성공하였습니다.",
                      cancelBtn: false, buttonTitle: "확인", onView: controller) { (action) in
                        controller.dismiss(animated: true, completion: nil)
            }
        case .sent :
            showAlert(title: "메일 보내기 성공",
                      message: "소중한 의견을 보내주셔서 감사합니다. \n 보내주신 의견을 잘 수렴하여 \n 더 좋은 앱이 되도록 부지런히 \n 노력하겠습니다.",
                      cancelBtn: false, buttonTitle: "확인", onView: controller) { (action) in
                        controller.dismiss(animated: true, completion: nil)
            }
        }
    }
}
extension OptionsViewController {
    private func setUpLayout() {
        let height = self.navigationController?.navigationBar.bounds.height
        let window = UIApplication.shared.keyWindow
        let safePadding = window?.safeAreaInsets.top
        let heightPadding = CGFloat(height!) + CGFloat(safePadding!)
        
        spacingView = UIView()
        spacingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spacingView)
        
        spacingView.topAnchor.constraint(equalTo: view.topAnchor, constant: heightPadding).isActive = true
        spacingView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        spacingView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        spacingView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        spacingInnerView = UIView()
        spacingInnerView.translatesAutoresizingMaskIntoConstraints = false
        spacingView.addSubview(spacingInnerView)
        
        spacingInnerView.topAnchor.constraint(equalTo: spacingView.topAnchor, constant: 0).isActive = true
        spacingInnerView.leadingAnchor.constraint(equalTo: spacingView.leadingAnchor, constant: 0).isActive = true
        spacingInnerView.trailingAnchor.constraint(equalTo: spacingView.trailingAnchor, constant: 0).isActive = true
        spacingInnerView.heightAnchor.constraint(equalToConstant: 5).isActive = true
        spacingInnerView.backgroundColor = #colorLiteral(red: 0.1843137255, green: 0.1411764706, blue: 0.1333333333, alpha: 0.199261582)
        
        optionsTableview = UITableView()
        optionsTableview.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(optionsTableview)
        
        optionsTableview.separatorStyle = .singleLine
        optionsTableview.backgroundColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        
        optionsTableview.topAnchor.constraint(equalTo: spacingView.bottomAnchor, constant: 0).isActive = true
        optionsTableview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        optionsTableview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        optionsTableview.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        // ToRegister cell
        optionsTableview.register(UITableViewCell.self, forCellReuseIdentifier: "BasicCell")
        // delegate & dataSource
        optionsTableview.delegate = self
        optionsTableview.dataSource = self
    }
}


// MARK: - UITableViewDelegate
extension OptionsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectRowSwitch(indexpath: indexPath)
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
    
    func didSelectRowSwitch(indexpath : IndexPath) {
        switch indexpath {
        case [0,0]:
            let themeVC = ThemeSettingViewController()
            self.navigationController?.pushViewController(themeVC, animated: true)
        case [1,0]:
            let memoVC = MemoCollectionTableView()
            self.navigationController?.pushViewController(memoVC, animated: true)
        case [1,1]:
            let diaryVC = DiaryCollectionViewController()
            self.navigationController?.pushViewController(diaryVC, animated: true)
        case [2,0]:
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            composeVC.setToRecipients(["toffler00@gmail.com"])
            composeVC.setSubject("Dot Note 의견보내기")
            composeVC.setMessageBody("Dot Note에 대한 불편한 사항이나 개선사항 또는 \n 아이디어가 있다면 보내주시기 바랍니다. \n \n 의견: ", isHTML: false)
            self.present(composeVC, animated: true, completion: nil)
        case [2,1]:
            print(indexpath)
        case [2,2]:
            let openSourceList = OpensourceLicenseVC()
            self.navigationController?.pushViewController(openSourceList, animated: true)
        case [3,0]:
            showAlert(title: "정말 모든 기록을 삭제할까요?",
                      message: "삭제된 데이터는 복구할 수 없습니다. \n 데이터 삭제를 진행할까요?",
                      cancelBtn: true, buttonTitle: "승인", onView: self) { (okAction) in
                        RealmManager.shared.deletedAll(object: self.datasourece)
                        self.navigationController?.popViewController(animated: true)}
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 50)
        footerView.backgroundColor = .clear
        addTopBorderLine(to: footerView, height: 0.7)
        return footerView
    }
}

// MARK: - UITableViewDataSource
extension OptionsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return OptionTitle.total.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let optionTitle = OptionTitle(rawValue: section),
            let listData = optionList[optionTitle] {
            print("section = \(section) \(optionTitle)")
            return listData.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let optionTitle = OptionTitle(rawValue: section),
            let listData = optionList[optionTitle], listData.count > 0 {
            return sectionHeaderHeight
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0,
                                  width: tableView.bounds.width,
                                  height: sectionHeaderHeight)
        //headerView.backgroundColor = UIColor(red: 246/255, green: 252/255, blue: 226/255, alpha: 1)
        headerView.backgroundColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        let headerLabel = UILabel()
        headerLabel.frame = CGRect(x: 15, y: 0,
                                   width: tableView.bounds.width - 30,
                                   height: sectionHeaderHeight)
        headerLabel.textColor = UIColor.black
        headerLabel.font = UIFont(name: "NanumBarunGothic", size: 18)
        if let optionTitle = OptionTitle(rawValue: section) {
            switch optionTitle {
            case .theme :
                headerLabel.text = "테마"
            case .collection :
                headerLabel.text = "모아보기"
            case .support :
                headerLabel.text = "지원"
            case .deleteData :
                headerLabel.text = "데이터삭제"
            default :
                headerLabel.text = ""
            }
        }
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
        cell.backgroundColor = .white
        cell.selectionStyle = .none
        let contentView = UIView()
        contentView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: cell.bounds.height)
        cell.addSubview(contentView)
        if let optionTitle = OptionTitle(rawValue: indexPath.section), let listData = optionList[optionTitle]?[indexPath.row] {
            if let titleLabel = cell.textLabel {
                switch indexPath {
                case [0,0] :
                    self.addTopBorderLine(to: contentView, height: 0.7)
                    titleLabel.text = listData["optionName"]
                case [1,0] :
                    self.addTopBorderLine(to: contentView, height: 0.7)
                    titleLabel.text = listData["optionName"]
                case [2,0]:
                    self.addTopBorderLine(to: contentView, height: 0.7)
                    titleLabel.text = listData["optionName"]
                case [3,0]:
                    self.addTopBorderLine(to: contentView, height: 0.5)
                    titleLabel.text = listData["optionName"]
                    titleLabel.textColor = UIColor.red
                default :
                    titleLabel.text = listData["optionName"]
                }
            }
        }
        return cell
    }
    
    
}
