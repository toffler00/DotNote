//
//  DiaryViewController.swift
//  Orbit
//
//  Created by ilhan won on 2018. 8. 11..
//  Copyright © 2018년 orbit. All rights reserved.
//

import UIKit
import RealmSwift

protocol DeleteMemoDelgate : class {
    func deleteDataDelegate()
}
class DiaryViewController: UIViewController {
    
    
    private var realm = try! Realm()
    var datasourece : Results<Content>!
    var settingData : Results<Settings>!
    weak var deleteMemoDelegate : DeleteMemoDelgate!
    
    var dateLabel : UILabel!
    var dayOfWeek : UILabel!
    var weatherImgV : UIImageView!
    var titleLabel : UILabel!
    var contents : UITextView!
    var contentImgView : UIImageView!
    var containerView : UIView!
    var deleteIcon : UIImageView!
    var dateCollectionView : UICollectionView!
//    let user = User()
    var diaryData : Content!
    var backButton : UIImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let realmManager = RealmManager.shared.realm
        datasourece = realmManager.objects(Content.self).sorted(byKeyPath: "createdAt", ascending: false)
        settingData = realmManager.objects(Settings.self)
        navigationController?.navigationBar.barTintColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.hidesBackButton = true
        self.view.backgroundColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        navigationItem.title = "\(dateToString(in: diaryData.createdAt, dateFormat: "yyyy.MM.dd eee"))"
        setUpDeleteIcon(bool: true)
        
        //        let attrs = [ NSAttributedString.Key.foregroundColor : UIColor(red: 246/255, green: 252/255, blue: 226/255, alpha: 1),
        //                      NSAttributedString.Key.font : UIFont(name: "system", size: 24)]
        //        navigationController?.navigationBar.titleTextAttributes = attrs as [NSAttributedStringKey : Any]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        if titleLabel == nil {
            setupLayout()
            applySetting()
        } else {
            return
        }
        
    }
    override func viewDidLayoutSubviews() {
        dataUpdate()
        print("viewDidLayoutSubviews()")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationBackButton(onView: self, in: backButton, bool: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setUpWeatherIcon(bool: true)
        changeWeatherIcon(weather: diaryData.weather)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        setUpWeatherIcon(bool: false)
        setUpDeleteIcon(bool: false)
        setNavigationBackButton(onView: self, in: backButton, bool: false)
    }
}

extension DiaryViewController {
    fileprivate func setupLayout() {
        //MARK: containerView : UIView
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let consContainerV : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: containerView, attribute: .top, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide,
                               attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: containerView, attribute: .leading, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide,
                               attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: containerView, attribute: .trailing, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide,
                               attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: containerView, attribute: .bottom, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide,
                               attribute: .bottom, multiplier: 1, constant: 0)]
        
        view.addSubview(containerView)
        view.addConstraints(consContainerV)
        containerView.backgroundColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        
        
        //MARK: weatherImgV : UIImageView
        //        weatherImgV = UIImageView()
        //        weatherImgV.translatesAutoresizingMaskIntoConstraints = false
        //
        //        let consWeather : [NSLayoutConstraint] = [
        //            NSLayoutConstraint(item: weatherImgV, attribute: .top, relatedBy: .equal, toItem: containerView
        //                , attribute: .top, multiplier: 1, constant: 4),
        //            NSLayoutConstraint(item: weatherImgV, attribute: .width, relatedBy: .equal, toItem: containerView,
        //                               attribute: .width, multiplier: 0.1, constant: 0),
        //            NSLayoutConstraint(item: weatherImgV, attribute: .height, relatedBy: .equal, toItem: weatherImgV,
        //                               attribute: .width, multiplier: 1, constant: 0),
        //            NSLayoutConstraint(item: weatherImgV, attribute: .trailing, relatedBy: .equal, toItem: containerView,
        //                               attribute: .trailing, multiplier: 1, constant: -4)]
        //
        //        containerView.addSubview(weatherImgV)
        //        containerView.addConstraints(consWeather)
        //        weatherImgV.backgroundColor = .clear
        
        //MARK: titleLabel : UILabel
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let consTitleLabel : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: containerView,
                               attribute: .leading, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: containerView,
                               attribute: .trailing, multiplier: 1, constant: -8),
            NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal, toItem: nil,
                               attribute: .height, multiplier: 1, constant: 28),
            NSLayoutConstraint(item: titleLabel, attribute: .top ,relatedBy: .equal, toItem: containerView,
                               attribute: .top, multiplier: 1, constant: 4)]
        
        containerView.addSubview(titleLabel)
        containerView.addConstraints(consTitleLabel)
        titleLabel.backgroundColor = .clear
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        
        //MARK: contentImgView : UIImageView
        contentImgView = UIImageView()
        contentImgView.translatesAutoresizingMaskIntoConstraints = false
        
        if diaryData.image == nil {
            let consContentImgV : [NSLayoutConstraint] = [
                NSLayoutConstraint(item: contentImgView, attribute: .top, relatedBy: .equal, toItem: titleLabel,
                                   attribute: .bottom, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: contentImgView, attribute: .width, relatedBy: .equal, toItem: containerView,
                                   attribute: .width, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: contentImgView, attribute: .height, relatedBy: .equal, toItem: nil,
                                   attribute: .height, multiplier: 1, constant: 1),
                NSLayoutConstraint(item: contentImgView, attribute: .centerX, relatedBy: .equal, toItem: containerView,
                                   attribute: .centerX, multiplier: 1, constant: 0)]
            
            containerView.addSubview(contentImgView)
            containerView.addConstraints(consContentImgV)
            contentImgView.backgroundColor = .clear
            contentImgView.contentMode = .scaleAspectFill
            contentImgView.clipsToBounds = true
        } else {
                let consContentImgV : [NSLayoutConstraint] = [
                    NSLayoutConstraint(item: contentImgView, attribute: .top, relatedBy: .equal, toItem: titleLabel,
                                       attribute: .bottom, multiplier: 1, constant: 4),
                    NSLayoutConstraint(item: contentImgView, attribute: .width, relatedBy: .equal, toItem: containerView,
                                       attribute: .width, multiplier: 1, constant: 0),
                    NSLayoutConstraint(item: contentImgView, attribute: .height, relatedBy: .equal, toItem: containerView,
                                       attribute: .width, multiplier: 0.75, constant: 0),
                    NSLayoutConstraint(item: contentImgView, attribute: .centerX, relatedBy: .equal, toItem: containerView,
                                       attribute: .centerX, multiplier: 1, constant: 0)]
                
                containerView.addSubview(contentImgView)
                containerView.addConstraints(consContentImgV)
                contentImgView.backgroundColor = .clear
                contentImgView.contentMode = .scaleAspectFit
                contentImgView.clipsToBounds = true
        }
        
        //MARK: contents : UITextView
        contents = UITextView()
        contents.translatesAutoresizingMaskIntoConstraints = false
        
        let consContents : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: contents, attribute: .top, relatedBy: .equal, toItem: contentImgView,
                               attribute: .bottom, multiplier: 1, constant: 4),
            NSLayoutConstraint(item: contents, attribute: .leading, relatedBy: .equal, toItem: containerView,
                               attribute: .leading, multiplier: 1, constant: 4),
            NSLayoutConstraint(item: contents, attribute: .trailing, relatedBy: .equal, toItem: containerView,
                               attribute: .trailing, multiplier: 1, constant: -4),
            NSLayoutConstraint(item: contents, attribute: .bottom, relatedBy: .equal, toItem: containerView,
                               attribute: .bottom, multiplier: 1, constant: 0)]
        
        containerView.addSubview(contents)
        containerView.addConstraints(consContents)
        contents.backgroundColor = UIColor(red: 246/255, green: 252/255, blue: 226/255, alpha: 1)
        contents.isEditable = false
        contents.sizeToFit()
        contents.isScrollEnabled = true
        let spacing = NSMutableParagraphStyle()
        spacing.lineSpacing = 6
        let atributes = [NSAttributedString.Key.paragraphStyle: spacing ]
        contents.attributedText = NSAttributedString(string: contents.text, attributes: atributes)
    }
    
    func setUpWeatherIcon(bool : Bool) {
        if bool {
            //MARK: weatherIcon UIImageView
            weatherImgV = UIImageView()
            weatherImgV.translatesAutoresizingMaskIntoConstraints = false
            
            let constWeatherIcon : [NSLayoutConstraint] = [
                NSLayoutConstraint(item: weatherImgV, attribute: .width, relatedBy: .equal, toItem: nil,
                                   attribute: .width, multiplier: 1, constant: 36),
                NSLayoutConstraint(item: weatherImgV, attribute: .height, relatedBy: .equal, toItem: nil,
                                   attribute: .height, multiplier: 1, constant: 36),
                NSLayoutConstraint(item: weatherImgV, attribute: .trailing, relatedBy: .equal, toItem: self.navigationController?.navigationBar,
                                   attribute: .trailing, multiplier: 1, constant: -8),
                NSLayoutConstraint(item: weatherImgV, attribute: .bottom, relatedBy: .equal, toItem: self.navigationController?.navigationBar,
                                   attribute: .bottom, multiplier: 1, constant: -8)]
            navigationController?.navigationBar.addSubview(weatherImgV)
            navigationController?.navigationBar.addConstraints(constWeatherIcon)
            
            weatherImgV.layer.cornerRadius = 8
            weatherImgV.clipsToBounds = true
            weatherImgV.isUserInteractionEnabled = true
        } else {
            weatherImgV.isHidden = true
        }
    }
    
    func setUpDeleteIcon(bool : Bool) {
        if bool {
            //MARK: deleteIcon UIImageView
            deleteIcon = UIImageView()
            deleteIcon.translatesAutoresizingMaskIntoConstraints = false
            
            let constDeleteIcon : [NSLayoutConstraint] = [
                NSLayoutConstraint(item: deleteIcon, attribute: .width, relatedBy: .equal, toItem: nil,
                                   attribute: .width, multiplier: 1, constant: 27),
                NSLayoutConstraint(item: deleteIcon, attribute: .height, relatedBy: .equal, toItem: nil,
                                   attribute: .height, multiplier: 1, constant: 27),
                NSLayoutConstraint(item: deleteIcon, attribute: .trailing, relatedBy: .equal, toItem: self.navigationController?.navigationBar,
                                   attribute: .trailing, multiplier: 1, constant: -12),
                NSLayoutConstraint(item: deleteIcon, attribute: .top, relatedBy: .equal, toItem: self.navigationController?.navigationBar,
                                   attribute: .top, multiplier: 1, constant: 6)]
            navigationController?.navigationBar.addSubview(deleteIcon)
            navigationController?.navigationBar.addConstraints(constDeleteIcon)
            
            deleteIcon.image = UIImage(named: "recycle-bin")
            
            let tapDeleteIcon = UITapGestureRecognizer(target: self, action: #selector(deleteData))
            deleteIcon.addGestureRecognizer(tapDeleteIcon)
            deleteIcon.isUserInteractionEnabled = true
            
        } else {
            deleteIcon.isHidden = true
        }
    }
}

extension DiaryViewController {
    @objc fileprivate func pushWriteViewController() {
        //        let writeViewController = WriteViewController(delegate: self)
        //        navigationController?.pushViewController(writeViewController, animated: true)
    }
    
    func dataUpdate() {
        titleLabel.text = diaryData.title
        let contentType = diaryData.type
        let alignment = diaryData.contentsAlignment
        applySetting()
        switch contentType {
        case "memo":
            contents.text = diaryData.body
            contents.textAlignment = .left
        default :
            contents.text = diaryData.body
            switch alignment {
            case "right" :
                contents.textAlignment = .right
            case "left" :
                contents.textAlignment = .left
            case "center" :
                contents.textAlignment = .center
            default:
                break
            }
        }
        if diaryData.image == nil {
            print("nodata")
        } else {
            contentImgView.image = UIImage(data: diaryData.image!)
        }
    }
    
    func applySetting() {
        let settingData = self.settingData[0]
        let contentsFont = settingData.contentsFont
        let contentsFontSize = CGFloat(settingData.contentsFontSize)
        contents.font = UIFont(name: contentsFont, size: contentsFontSize)
    }
    
    @objc func deleteData() {
        let contentType = diaryData.type
        switch contentType {
        case "memo":
            showAlert(title: "경 고", message: "현재 메모를 삭제하시겠습니까?", cancelBtn: true, buttonTitle: "확인", onView: self) { (alertAction) in
                RealmManager.shared.delete(object: self.diaryData)
                self.deleteMemoDelegate.deleteDataDelegate()
                self.navigationController?.popViewController(animated: true)
                
            }
        default:
            showAlert(title: "경 고", message: "\(diaryData.title)를 삭제하시겠습니까?", cancelBtn: true, buttonTitle: "확인", onView: self) { (alertAction) in
                print("deleteData()")
                RealmManager.shared.delete(object: self.diaryData)
                self.deleteMemoDelegate.deleteDataDelegate()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    @objc func changeWeatherIcon(weather : String) {
        switch weather {
        case "맑음" :
            self.weatherImgV.image = UIImage(named: "sun")
        case "안개" :
            self.weatherImgV.image = UIImage(named: "haze")
        case "구름", "구름조금" :
            self.weatherImgV.image = UIImage(named: "cloudy")
        case "이슬비" :
            self.weatherImgV.image = UIImage(named: "hail")
        case "비" :
            self.weatherImgV.image = UIImage(named: "rainy")
        case "눈","진눈깨비", "눈,비" :
            self.weatherImgV.image = UIImage(named: "snow")
        case "천둥번개" :
            self.weatherImgV.image = UIImage(named: "storm")
        default:
            self.weatherImgV.backgroundColor = .clear
        }
    }
}

