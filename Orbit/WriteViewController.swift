//
//  WriteViewController.swift
//  Orbit
//
//  Created by David Koo on 25/08/2018.
//  Copyright © 2018 orbit. All rights reserved.
//

import UIKit
import CoreLocation
import RealmSwift
import RSKImageCropper

protocol WriteDoneDelegate: class {
    func writeDone()
}
class WriteViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var isImageLoadingFromiCloud: Bool = false
    fileprivate var keyboardShown = false
    var contentsTextViewCGRect : CGRect!
    
    //MARK: Ream Property
    
    var realm = try! Realm()
    var settingData : Results<Settings>!
    
    //Delegate
    weak var writeDoneDelegate: WriteDoneDelegate!
    
    fileprivate var date : UILabel!
    fileprivate var titleLabel : UILabel!
    fileprivate var contentTitle: UITextField!
    var dayOfWeek: UILabel!
    var weather: UILabel!
    var contentsAlignment : String = "left"
    
    //    fileprivate var weatherImg : UIImageView!
    fileprivate var writeDoneIcon : UIImageView!
    fileprivate var dateTF : CustomTextFiled!
    fileprivate var weatherTF : CustomTextFiled!
    var selectedDate : Date!
    fileprivate var createAtMonth : String!
    var containerV : UIView!
    fileprivate var contStackV : UIStackView!
    fileprivate var stackBox : UIStackView!
    fileprivate var tapWeather : UIImageView!
    fileprivate var tapDate : UIImageView!
    var contentImgV : UIImageView!
    fileprivate var cameraIconImgView : UIImageView!
    fileprivate var iconBgView : UIView!
    fileprivate var contents : UITextView!
    //    fileprivate var models : [Model.Contents] = [Model.Contents]()
    var selectedImageData: Data?
    fileprivate var datePicker : UIDatePicker!
    fileprivate var weatherPicker : UIPickerView!
    let pickerData : [String] = [ "맑음", "천둥번개", "이슬비", "비","눈","눈,비","진눈깨비", "안개", "구름", "구름조금"]
    var backButton : UIImageView = UIImageView()
    var weatherItem : Int = 0
    fileprivate var type : String = "diary"
    
    
    init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil, delegate: WriteDoneDelegate) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.writeDoneDelegate = delegate
        view.backgroundColor = .white
    }
    
    //MARK: LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        registerForKeyboardNotification()
        regitsterForTextViewNotification()
        setUpWriteDoneIcon(bool: true)
        setNavigationBackButton(onView: self, in: backButton, bool: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //        setNavigationBackButton(onView: self, in: backButton, bool: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        unregisterForKeyboardNotification()
        unregisterForTextViewTextNotification()
        setUpWriteDoneIcon(bool: false)
        setNavigationBackButton(onView: self, in: backButton, bool: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let realmManager = RealmManager.shared.realm
        settingData = realmManager.objects(Settings.self)
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationItem.title = "일기"
        self.navigationItem.hidesBackButton = true
        self.view.backgroundColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
    }
    
    override func viewWillLayoutSubviews() {
        if containerV == nil {
            setupLayout()
            setInformation(in: selectedDate)
            applySetting()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func applySetting() {
        let settingData = self.settingData[0]
        let contentsFont = settingData.contentsFont
        let contentsFontSize = CGFloat(settingData.contentsFontSize)
        contents.font = UIFont(name: contentsFont, size: contentsFontSize)
    }
    
    func setInformation(in todayDate : Date) {
//        selectedDate = stringToDate(in: todayDate, dateFormat: "dd MMM yyyy hh mm")
        dayOfWeek.text = getWeekDay(in: selectedDate, dateFormat: "EEEE")
        date.text = dateToString(in: selectedDate, dateFormat: "dd MMM yyyy")
        createAtMonth = dateToString(in: selectedDate, dateFormat: "MMM yyyy")
        let weatherID = getWeatherID()
        setWeather(id: weatherID)
    }
    
    private func getWeatherID() -> Int {
        let selectDate = dateToString(in: self.selectedDate, dateFormat: "yyyyMMdd")
        let today = getDate(dateFormat: "yyyyMMdd")
        if selectDate == today {
            return self.weatherItem
        } else {
            return 0
        }
    }
    func setWeather(id : Int) {
        switch id {
        case 200...299:
            weather.text = "천둥번개"
        case 300...399:
            weather.text = "이슬비"
        case 500...599:
            weather.text = "비"
        case 600, 601, 602, 620, 621, 622 :
            weather.text = "눈"
        case 611, 612:
            weather.text = "진눈깨비"
        case 615, 616:
            weather.text = "눈,비"
        case 700...799:
            weather.text = "안개"
        case 800:
            weather.text = "맑음"
        case 801, 802:
            weather.text = "구름"
        case 803, 804:
            weather.text = "구름조금"
        default:
            weather.text = "날씨를 선택하세요"
        }
    }
}

//MARK: writeDone Post
extension WriteViewController {
    @objc func writeDone() {
        if contentTitle.text == "" {
            showAlert(title: "경 고", message: "제목이 빈칸이네요 \n 제목을 적어주세요.",
                      cancelBtn: true, buttonTitle: "확인", onView: self, completion: nil)
        } else {
            if contents.text == "" || contents.text == "글을 입력하세요" {
                showAlert(title: "경 고", message: "작성한 내용이 없습니다. \n 이대로 저장할까요?",
                          cancelBtn: true, buttonTitle: "확인", onView: self) { (action) in
                            self.contents.text = " "
                            let data = Content(type: self.type,
                                               createdAt: self.selectedDate,
                                               createdAtMonth : self.createAtMonth ,
                                               title: self.contentTitle.text!,
                                               weather: self.weather.text!,
                                               body: self.contents.text!,
                                               contentsAlignment: self.contentsAlignment,
                                               image: self.selectedImageData)
                            RealmManager.shared.creat(object: data)
                            self.writeDoneDelegate.writeDone()
                            self.navigationController?.popViewController(animated: true)
                }
            } else {
                let data = Content(type : self.type, createdAt: self.selectedDate,
                                   createdAtMonth : self.createAtMonth ,title: self.contentTitle.text!,
                                   weather: self.weather.text!, body: self.contents.text!,
                                   contentsAlignment: self.contentsAlignment,image: self.selectedImageData)
                RealmManager.shared.creat(object: data)
                self.writeDoneDelegate.writeDone()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func getWeekDay() {
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = Locale(identifier: "kr_KR")
        let weekDay = dateFormatter.string(from: today).capitalized
        self.dayOfWeek.text = weekDay
    }
}


//MARK: Setup Layout
extension WriteViewController {
    fileprivate func setupLayout() {
        // containerV UIView
        
        log.debug("setup Layout")
        self.view.backgroundColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        containerV = UIView()
        containerV.translatesAutoresizingMaskIntoConstraints = false
        
        let const : [NSLayoutConstraint] = [NSLayoutConstraint(item: containerV, attribute: .top, relatedBy: .equal,
                                                               toItem:self.view.safeAreaLayoutGuide,attribute: .top, multiplier: 1, constant: 8),
                                            NSLayoutConstraint(item: containerV, attribute: .bottom, relatedBy: .equal,
                                                               toItem: self.view.safeAreaLayoutGuide,attribute: .bottom, multiplier: 1, constant: -8),
                                            NSLayoutConstraint(item: containerV, attribute: .leading, relatedBy: .equal,
                                                               toItem: self.view.safeAreaLayoutGuide,attribute: .leading, multiplier: 1, constant: 8),
                                            NSLayoutConstraint(item: containerV, attribute: .trailing, relatedBy: .equal,
                                                               toItem: self.view.safeAreaLayoutGuide,attribute: .trailing, multiplier: 1, constant: -8)]
        
        self.view.addSubview(containerV)
        self.view.addConstraints(const)
        containerV.backgroundColor = .clear
        
        
        // dayofWeek Label
        dayOfWeek = UILabel()
        dayOfWeek.translatesAutoresizingMaskIntoConstraints = false
        let constWeek : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: dayOfWeek, attribute: .top, relatedBy: .equal, toItem: containerV,
                               attribute: .top, multiplier: 1, constant: 8),
            NSLayoutConstraint(item: dayOfWeek, attribute: .leading, relatedBy: .equal, toItem: containerV,
                               attribute: .leading, multiplier: 1, constant: 8),
            NSLayoutConstraint(item: dayOfWeek, attribute: .height, relatedBy: .equal, toItem: nil,
                               attribute: .height, multiplier: 1, constant: 30),
            NSLayoutConstraint(item: dayOfWeek, attribute: .width, relatedBy: .equal, toItem: containerV,
                               attribute: .width, multiplier: 0.4, constant: 0)]
        
        containerV.addSubview(dayOfWeek)
        containerV.addConstraints(constWeek)
        dayOfWeek.numberOfLines = 1
        dayOfWeek.font = setFont(type: .contents, onView: self, font: "NanumBarunGothicBold", size: 24)
        dayOfWeek.textAlignment = NSTextAlignment.left
        dayOfWeek.backgroundColor = .clear
        
        
        //MARK: date Label
        date = UILabel()
        date.translatesAutoresizingMaskIntoConstraints = false
        let constDate : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: date, attribute: .top, relatedBy: .equal, toItem: dayOfWeek, attribute: .bottom,
                               multiplier: 1, constant: 1),
            NSLayoutConstraint(item: date, attribute: .leading, relatedBy: .equal, toItem: dayOfWeek, attribute: .leading,
                               multiplier: 1, constant: 0),
            NSLayoutConstraint(item: date, attribute: .trailing, relatedBy: .equal, toItem: dayOfWeek, attribute: .trailing,
                               multiplier: 1, constant: 0),
            NSLayoutConstraint(item: date, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height,
                               multiplier: 1,constant: 24),
            NSLayoutConstraint(item: date, attribute: .width, relatedBy: .equal, toItem: containerV, attribute: .width,
                               multiplier: 0.4, constant: 0)]
        
        containerV.addSubview(date)
        containerV.addConstraints(constDate)
        date.numberOfLines = 1
        date.adjustsFontForContentSizeCategory = true
        date.adjustsFontSizeToFitWidth = true
        date.font = setFont(type: .date, onView: self, font: "NanumBarunGothic", size: 16)
        date.textAlignment = NSTextAlignment.left
        date.backgroundColor = .clear
        
        
        //dateTF textfield
        dateTF = CustomTextFiled()
        dateTF.translatesAutoresizingMaskIntoConstraints = false
        let constDateTF : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: dateTF, attribute: .top, relatedBy: .equal, toItem: date, attribute: .top,
                               multiplier: 1, constant: 1),
            NSLayoutConstraint(item: dateTF, attribute: .leading, relatedBy: .equal, toItem: date, attribute: .leading,
                               multiplier: 1, constant: 0),
            NSLayoutConstraint(item: dateTF, attribute: .trailing, relatedBy: .equal, toItem: date, attribute: .trailing,
                               multiplier: 1, constant: 20),
            NSLayoutConstraint(item: dateTF, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height,
                               multiplier: 1,constant: 24)]
        
        containerV.addSubview(dateTF)
        containerV.addConstraints(constDateTF)
        dateTF.backgroundColor = .clear
        dateTF.isUserInteractionEnabled = true
        let changeDateGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(touchUpInsideDateLabel(sender:)))
        dateTF.addGestureRecognizer(changeDateGestureRecognizer)
        dateTF.allowsEditingTextAttributes = false
        
        // weather Label
        weather = UILabel()
        weather.translatesAutoresizingMaskIntoConstraints = false
        
        let constWeather : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: weather, attribute: .top, relatedBy: .equal, toItem: date,
                               attribute: .bottom, multiplier: 1, constant: 1),
            NSLayoutConstraint(item: weather, attribute: .leading, relatedBy: .equal, toItem: date,
                               attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: weather, attribute: .height, relatedBy: .equal, toItem: nil,
                               attribute: .height, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: weather, attribute: .width, relatedBy: .equal, toItem: date,
                               attribute: .width, multiplier: 1, constant: 0)]
        
        containerV.addSubview(weather)
        containerV.addConstraints(constWeather)
        weather.font = setFont(type: .weather, onView: self, font: "NanumBarunGothic", size: 16)
        weather.numberOfLines = 1
        weather.textAlignment = NSTextAlignment.left
        weather.backgroundColor = .clear
        
        
        weatherTF = CustomTextFiled()
        weatherTF.translatesAutoresizingMaskIntoConstraints = false
        
        let constWeatherTF : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: weatherTF, attribute: .top, relatedBy: .equal, toItem: weather,
                               attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: weatherTF, attribute: .leading, relatedBy: .equal, toItem: weather,
                               attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: weatherTF, attribute: .height, relatedBy: .equal, toItem: nil,
                               attribute: .height, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: weatherTF, attribute: .trailing, relatedBy: .equal, toItem: weather,
                               attribute: .trailing, multiplier: 1, constant: 20)]
        
        containerV.addSubview(weatherTF)
        containerV.addConstraints(constWeatherTF)
        weatherTF.allowsEditingTextAttributes = false
        let changeWeatherGesture = UITapGestureRecognizer(target: self, action: #selector(weatherTextFieldReconiger))
        weatherTF.isUserInteractionEnabled = true
        weatherTF.addGestureRecognizer(changeWeatherGesture)
        
        // tapDate UIImageView
        tapDate = UIImageView()
        tapDate.translatesAutoresizingMaskIntoConstraints = false
        
        let constTapDate : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: tapDate, attribute: .top, relatedBy: .equal, toItem: date,
                               attribute: .top, multiplier: 1, constant: 4),
            NSLayoutConstraint(item: tapDate, attribute: .bottom, relatedBy: .equal, toItem: date,
                               attribute: .bottom, multiplier: 1, constant: -4),
            NSLayoutConstraint(item: tapDate, attribute: .leading, relatedBy: .equal, toItem: date,
                               attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: tapDate, attribute: .width, relatedBy: .equal, toItem: nil,
                               attribute: .width, multiplier: 1, constant: 16)]
        containerV.addSubview(tapDate)
        containerV.addConstraints(constTapDate)
        tapDate.image = UIImage(named: "right")
        
        //tapWeather UIImageView
        tapWeather = UIImageView()
        tapWeather.translatesAutoresizingMaskIntoConstraints = false
        
        let constTapWeather : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: tapWeather, attribute: .top, relatedBy: .equal, toItem: weather,
                               attribute: .top, multiplier: 1, constant: 2),
            NSLayoutConstraint(item: tapWeather, attribute: .bottom, relatedBy: .equal, toItem: weather,
                               attribute: .bottom, multiplier: 1, constant: -2),
            NSLayoutConstraint(item: tapWeather, attribute: .leading, relatedBy: .equal, toItem: weather,
                               attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: tapWeather, attribute: .width, relatedBy: .equal, toItem: nil,
                               attribute: .width, multiplier: 1, constant: 16)]
        containerV.addSubview(tapWeather)
        containerV.addConstraints(constTapWeather)
        tapWeather.image = UIImage(named: "right")
        
        // contStackV UIStackView
        contStackV = UIStackView()
        contStackV.translatesAutoresizingMaskIntoConstraints = false
        
        let constStackV : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: contStackV, attribute: .top, relatedBy: .equal, toItem: weather, attribute: .bottom,
                               multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contStackV, attribute: .bottom, relatedBy: .equal, toItem: containerV, attribute: .bottom,
                               multiplier: 1, constant: -8),
            NSLayoutConstraint(item: contStackV, attribute: .leading, relatedBy: .equal, toItem: containerV, attribute: .leading,
                               multiplier: 1, constant: 8),
            NSLayoutConstraint(item: contStackV, attribute: .trailing, relatedBy: .equal, toItem: containerV, attribute: .trailing,
                               multiplier: 1, constant: -8)]
        
        containerV.addSubview(contStackV)
        containerV.addConstraints(constStackV)
        
        //stackBox UIStackView
        stackBox = UIStackView()
        stackBox.translatesAutoresizingMaskIntoConstraints = false
        
        let constStackBox : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: stackBox, attribute: .top, relatedBy: .equal, toItem: contStackV, attribute: .top,
                               multiplier: 1, constant: 0),
            NSLayoutConstraint(item: stackBox, attribute: .leading, relatedBy: .equal, toItem: contStackV, attribute: .leading,
                               multiplier: 1, constant: 0),
            NSLayoutConstraint(item: stackBox, attribute: .trailing, relatedBy: .equal, toItem: contStackV, attribute: .trailing,
                               multiplier: 1, constant: 0),
            NSLayoutConstraint(item: stackBox, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height,
                               multiplier: 1, constant: 38)]
        
        contStackV.addSubview(stackBox)
        contStackV.addConstraints(constStackBox)
        stackBox.distribution = .fill
        stackBox.spacing = 1
        
        //iconBgView
        iconBgView = UIView()
        iconBgView.translatesAutoresizingMaskIntoConstraints = false
        
        let constIconBgView : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: iconBgView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width,
                               multiplier: 1, constant:72),
            NSLayoutConstraint(item: iconBgView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height,
                               multiplier: 1, constant: 72),
            NSLayoutConstraint(item: iconBgView, attribute: .trailing, relatedBy: .equal, toItem: stackBox, attribute: .trailing,
                               multiplier: 1, constant: 0)]
        stackBox.addSubview(iconBgView)
        stackBox.addConstraints(constIconBgView)
        
        //contentImgV UIImageView
        contentImgV = UIImageView()
        contentImgV.translatesAutoresizingMaskIntoConstraints = false
        
        
        let constImgV : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: contentImgV, attribute: .top, relatedBy: .equal, toItem: dayOfWeek, attribute: .top,
                               multiplier: 1, constant:0),
            NSLayoutConstraint(item: contentImgV, attribute: .leading, relatedBy: .equal, toItem: containerV, attribute: .trailing,
                               multiplier: 1, constant: containerV.frame.size.width / 3 + 8),
            NSLayoutConstraint(item: contentImgV, attribute: .width, relatedBy: .equal, toItem:  containerV, attribute: .width,
                               multiplier: 0.25, constant: 0),
            NSLayoutConstraint(item: contentImgV, attribute: .height, relatedBy: .equal, toItem: contentImgV, attribute: .width,
                               multiplier: 0.75, constant: 0)]
        
        containerV.addSubview(self.contentImgV)
        containerV.addConstraints(constImgV)
        contentImgV.layer.cornerRadius = 16
        contentImgV.layer.maskedCorners = [CACornerMask.layerMinXMinYCorner, CACornerMask.layerMinXMaxYCorner]
        contentImgV.layer.borderWidth = 0.5
        contentImgV.layer.borderColor = UIColor.black.cgColor
        contentImgV.clipsToBounds = true
        contentImgV.backgroundColor = .clear
        
        //titleLabel
        //        titleLabel = UILabel()
        //        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        //        let constTitleLB : [NSLayoutConstraint] = [
        //            NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: stackBox, attribute: .top,
        //                               multiplier: 1, constant: 0),
        //            NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal, toItem: stackBox, attribute: .height,
        //                               multiplier: 0.5, constant: 0),
        //            NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: stackBox, attribute: .leading,
        //                               multiplier: 1, constant: 0),
        //            NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: iconBgView, attribute: .leading,
        //                               multiplier: 1, constant: 0)]
        //
        //        stackBox.addSubview(titleLabel)
        //        stackBox.addConstraints(constTitleLB)
        //        titleLabel.font = setFont(type: .contents, onView: self, font: "NanumBarunGothicBold", size: 20)
        //        titleLabel.text = "Today Title"
        //        titleLabel.backgroundColor = .clear
        
        //MARK: contentTitle Label
        contentTitle = UITextField()
        contentTitle.translatesAutoresizingMaskIntoConstraints = false
        
        let constTitle : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: contentTitle, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height,
                               multiplier: 1, constant: 30),
            NSLayoutConstraint(item: contentTitle, attribute: .top, relatedBy: .equal, toItem: stackBox, attribute: .top,
                               multiplier: 1, constant: 8),
            NSLayoutConstraint(item: contentTitle, attribute: .leading, relatedBy: .equal, toItem: stackBox, attribute: .leading,
                               multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contentTitle, attribute: .trailing, relatedBy: .equal, toItem: stackBox, attribute: .trailing,
                               multiplier: 1, constant: -72)]
        
        stackBox.addSubview(contentTitle)
        stackBox.addConstraints(constTitle)
        contentTitle.attributedPlaceholder = NSAttributedString(string: " 제목을 쓰윽쓰윽",
                                                                attributes: [NSAttributedString.Key.foregroundColor :
                                                                    UIColor(red: 208/255, green: 207/255, blue: 208/255, alpha: 1)])
        contentTitle.backgroundColor = UIColor(red: 246/255, green: 252/255, blue: 226/255, alpha: 1)
        contentTitle.font = setFont(type: .contents, onView: self, font: "NanumBarunGothic", size: 14)
        contentTitle.tintColor = .gray
        let titleGesture = UITapGestureRecognizer(target: self, action: #selector(addToolBarToTextFieldKeyboard))
        contentTitle.addGestureRecognizer(titleGesture)
        contentTitle.isUserInteractionEnabled = true
        
        //cameraIconImgView UIImageView
        cameraIconImgView = UIImageView()
        cameraIconImgView.translatesAutoresizingMaskIntoConstraints = false
        
        let constCameraIconImg : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: cameraIconImgView, attribute: .centerY, relatedBy: .equal, toItem: contentTitle,
                               attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: cameraIconImgView, attribute: .leading, relatedBy: .equal, toItem: contentTitle,
                               attribute: .trailing, multiplier: 1, constant: 24),
            NSLayoutConstraint(item: cameraIconImgView, attribute: .width, relatedBy: .equal, toItem: nil,
                               attribute: .width, multiplier: 1, constant: 25),
            NSLayoutConstraint(item: cameraIconImgView, attribute: .height, relatedBy: .equal, toItem: nil,
                               attribute: .height, multiplier: 1, constant: 25)]
        stackBox.addSubview(cameraIconImgView)
        stackBox.addConstraints(constCameraIconImg)
        cameraIconImgView.contentMode = .scaleAspectFit
        //        cameraIconImgView.layer.cornerRadius = 9
        //        cameraIconImgView.clipsToBounds = true
        cameraIconImgView.backgroundColor = .clear
        cameraIconImgView.image = UIImage(named: "camera")
        cameraIconImgView.isUserInteractionEnabled = true
        let addImageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addImageGesture))
        cameraIconImgView.addGestureRecognizer(addImageGestureRecognizer)
        
        //contents UITextView
        contents = UITextView()
        contents.translatesAutoresizingMaskIntoConstraints = false
        
        let constContens : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: contents, attribute: .top, relatedBy: .equal, toItem: stackBox, attribute: .bottom,
                               multiplier: 1, constant: 4),
            NSLayoutConstraint(item: contents, attribute: .leading, relatedBy: .equal, toItem: contStackV, attribute: .leading,
                               multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contents, attribute: .trailing, relatedBy: .equal, toItem: contStackV, attribute: .trailing,
                               multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contents, attribute: .bottom, relatedBy: .equal, toItem: contStackV, attribute: .bottom,
                               multiplier: 1, constant: 0)]
        
        contStackV.addSubview(contents)
        contStackV.addConstraints(constContens)
        contents.backgroundColor = UIColor(red: 246/255, green: 252/255, blue: 226/255, alpha: 1)
        contents.isScrollEnabled = true
        //        contents.font = setFont(type: .contents, onView: self, font: "NanumBarunGothic", size: 16)
        let spacing = NSMutableParagraphStyle()
        spacing.lineSpacing = 6
        
        contents.text = "글을 입력하세요"
        contents.tintColor = .gray
        contents.textColor = UIColor(red: 208/255, green: 207/255, blue: 208/255, alpha: 1)
        let contentsGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(contentsTextViewReconiger(sender:)))
        contents.isUserInteractionEnabled = true
        contents.addGestureRecognizer(contentsGestureRecognizer)
        
    }
    
    func setUpWriteDoneIcon(bool : Bool) {
        if bool {
            //MARK: writeDoneIcon UIImageView
            writeDoneIcon = UIImageView()
            writeDoneIcon.translatesAutoresizingMaskIntoConstraints = false
            
            let constWrtieDoneIcon : [NSLayoutConstraint] = [
                NSLayoutConstraint(item: writeDoneIcon, attribute: .width, relatedBy: .equal, toItem: nil,
                                   attribute: .width, multiplier: 1, constant: 25),
                NSLayoutConstraint(item: writeDoneIcon, attribute: .height, relatedBy: .equal, toItem: nil,
                                   attribute: .height, multiplier: 1, constant: 25),
                NSLayoutConstraint(item: writeDoneIcon, attribute: .trailing, relatedBy: .equal, toItem: self.navigationController?.navigationBar, attribute: .trailing, multiplier: 1, constant: -12),
                NSLayoutConstraint(item: writeDoneIcon, attribute: .bottom, relatedBy: .equal, toItem: self.navigationController?.navigationBar, attribute: .bottom, multiplier: 1, constant: -10)]
            navigationController?.navigationBar.addSubview(writeDoneIcon)
            navigationController?.navigationBar.addConstraints(constWrtieDoneIcon)
            
            writeDoneIcon.image = UIImage(named: "checked")
            writeDoneIcon.layer.cornerRadius = 12
            writeDoneIcon.clipsToBounds = true
            let tapWriteDonIcon = UITapGestureRecognizer(target: self, action: #selector(writeDone))
            writeDoneIcon.addGestureRecognizer(tapWriteDonIcon)
            writeDoneIcon.isUserInteractionEnabled = true
        } else {
            writeDoneIcon.isHidden = true
        }
    }
}

extension WriteViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    @objc fileprivate func addToolBarToTextFieldKeyboard(){
        let width = self.view.frame.size.width
        let toolBar = UIToolbar()
        toolBar.frame = CGRect(x: 0, y: 0, width: width, height: 44)
        toolBar.tintColor = .white
        toolBar.backgroundColor = UIColor(red: 246/255, green: 252/255, blue: 226/255, alpha: 1)
        toolBar.barStyle = .default
        
        let flexibleBtn = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let flexibleLabel = UILabel()
        flexibleLabel.frame = CGRect(x: 0, y: 0, width: width / 3, height: 36)
        flexibleLabel.backgroundColor = .clear
        
        let downArrow = makeKeyboarkHideBtn()
        let keyboardHideBtn = UIBarButtonItem(customView: downArrow)
        let flexibleLabelBtn = UIBarButtonItem(customView: flexibleLabel)
        
        toolBar.items = [flexibleLabelBtn,flexibleBtn,flexibleLabelBtn,flexibleBtn,keyboardHideBtn]
        let items = toolBar.items
        toolBar.setItems(items, animated: true)
        toolBar.isTranslucent = true
        contentTitle.inputAccessoryView = toolBar
        contentTitle.becomeFirstResponder()
    }
    
    @objc func contentsTextViewReconiger(sender : UITextView) {
        let width = self.view.frame.size.width
        let toolBar = UIToolbar()
        toolBar.frame = CGRect(x: 0, y: 0, width: width, height: 44)
        toolBar.tintColor = .white
        toolBar.backgroundColor = UIColor(red: 246/255, green: 252/255, blue: 226/255, alpha: 1)
        toolBar.barStyle = .default
        
        let flexibleBtn = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let flexibleLabel = UILabel()
        flexibleLabel.frame = CGRect(x: 0, y: 0, width: width / 3, height: 36)
        flexibleLabel.backgroundColor = .clear
        
        
        let downArrow = makeKeyboarkHideBtn()
        let keboardHideBtn = UIBarButtonItem(customView: downArrow)
        let flexibleLB = UIBarButtonItem(customView: flexibleLabel)
        let container = makeAlignView()
        let alignView = UIBarButtonItem(customView: container)
        
        toolBar.items = [alignView,flexibleBtn,flexibleLB,flexibleBtn,keboardHideBtn]
        let items = toolBar.items
        toolBar.sizeToFit()
        toolBar.setItems(items, animated: true)
        toolBar.isTranslucent = true
        contents.inputAccessoryView = toolBar
        contents.becomeFirstResponder()
        
    }
    
    fileprivate func makeAlignView() -> UIView{
        let viewBox = UIView()
        let rightAlignment = UIImageView()
        let leftAlignment = UIImageView()
        let centerAlignment = UIImageView()
        
        viewBox.addSubview(leftAlignment)
        viewBox.addSubview(centerAlignment)
        viewBox.addSubview(rightAlignment)
        
        leftAlignment.translatesAutoresizingMaskIntoConstraints = false
        centerAlignment.translatesAutoresizingMaskIntoConstraints = false
        rightAlignment.translatesAutoresizingMaskIntoConstraints = false
        viewBox.translatesAutoresizingMaskIntoConstraints = false
        
        viewBox.widthAnchor.constraint(equalToConstant: 112).isActive = true
        viewBox.heightAnchor.constraint(equalToConstant: 26).isActive = true
        viewBox.backgroundColor = .clear
        
        leftAlignment.leadingAnchor.constraint(equalTo: viewBox.leadingAnchor, constant: 0).isActive = true
        leftAlignment.topAnchor.constraint(equalTo: viewBox.topAnchor, constant: 0).isActive = true
        leftAlignment.bottomAnchor.constraint(equalTo: viewBox.bottomAnchor, constant: 0).isActive = true
        leftAlignment.widthAnchor.constraint(equalToConstant: 26).isActive = true
        leftAlignment.image = UIImage(named: "left-align")
        leftAlignment.contentMode = .scaleAspectFit
        let leftAlignGestureReconizer = UITapGestureRecognizer(target: self, action: #selector(leftTextAlignment))
        leftAlignment.addGestureRecognizer(leftAlignGestureReconizer)
        leftAlignment.isUserInteractionEnabled = true
        
        centerAlignment.leadingAnchor.constraint(equalTo: leftAlignment.trailingAnchor, constant: 20).isActive = true
        centerAlignment.topAnchor.constraint(equalTo: viewBox.topAnchor, constant: 0).isActive = true
        centerAlignment.bottomAnchor.constraint(equalTo: viewBox.bottomAnchor, constant: 0).isActive = true
        centerAlignment.widthAnchor.constraint(equalToConstant: 26).isActive = true
        centerAlignment.image = UIImage(named: "center-align")
        centerAlignment.contentMode = .scaleAspectFit
        let centerAlignGestureReconizer = UITapGestureRecognizer(target: self, action: #selector(centerTextAlignment))
        centerAlignment.addGestureRecognizer(centerAlignGestureReconizer)
        centerAlignment.isUserInteractionEnabled = true
        
        rightAlignment.leadingAnchor.constraint(equalTo: centerAlignment.trailingAnchor, constant: 20).isActive = true
        rightAlignment.topAnchor.constraint(equalTo: viewBox.topAnchor, constant: 0).isActive = true
        rightAlignment.bottomAnchor.constraint(equalTo: viewBox.bottomAnchor, constant: 0).isActive = true
        rightAlignment.widthAnchor.constraint(equalToConstant: 26).isActive = true
        rightAlignment.image = UIImage(named: "right-align")
        rightAlignment.contentMode = .scaleAspectFit
        let rightAlignGestureReconizer = UITapGestureRecognizer(target: self, action: #selector(rightTextAlignment))
        rightAlignment.addGestureRecognizer(rightAlignGestureReconizer)
        rightAlignment.isUserInteractionEnabled = true
        
        return viewBox
    }
    
    fileprivate func makeKeyboarkHideBtn() -> UIView {
        let containerView = UIView()
        let downArrow = UIImageView()
        
        containerView.addSubview(downArrow)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        downArrow.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.widthAnchor.constraint(equalToConstant: 36).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        downArrow.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8).isActive = true
        downArrow.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8).isActive = true
        downArrow.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8).isActive = true
        downArrow.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8).isActive = true
        downArrow.image = UIImage(named: "downarrow")
        downArrow.contentMode = .scaleAspectFit
        let downArrowGestureReconizer = UITapGestureRecognizer(target: self, action: #selector(keyboardHide))
        containerView.addGestureRecognizer(downArrowGestureReconizer)
        containerView.isUserInteractionEnabled = true
        return containerView
    }
    
    @objc fileprivate func keyboardHide() {
        if keyboardShown == true {
            view.endEditing(true)
            keyboardShown = false
        }
    }
    
    @objc func rightTextAlignment() {
        contents.textAlignment = .right
        contentsAlignment = "right"
    }
    
    @objc func leftTextAlignment() {
        contents.textAlignment = .left
        contentsAlignment = "left"
    }
    
    @objc func centerTextAlignment() {
        contents.textAlignment = .center
        contentsAlignment = "center"
    }
    
    @objc fileprivate func cleanTextView() {
        if contents.text == "글을 입력하세요" {
            contents.text = ""
        }
        contents.textColor = .black
    }
    
    @objc fileprivate func textViewState() {
        if contents.text == "" {
            contents.text = "글을 입력하세요"
            contents.textColor = UIColor(red: 208/255, green: 207/255, blue: 208/255, alpha: 1)
        }
    }
    
    @objc func weatherTextFieldReconiger() {
        weatherPicker = UIPickerView()
        weatherPicker.delegate = self
        weatherPicker.dataSource = self
        weatherTF.inputView = weatherPicker
        let width = self.view.frame.size.width
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        toolBar.frame = CGRect(x: 0, y: 0, width: width, height: 36)
        toolBar.backgroundColor = UIColor(red: 246/255, green: 252/255, blue: 226/255, alpha: 1)
        toolBar.barStyle = .default
        
        let flexibleLabel = UILabel()
        flexibleLabel.frame = CGRect(x: 0, y: 0, width: width / 6, height: 36)
        flexibleLabel.backgroundColor = .clear
        
        let doneLabel = UILabel()
        doneLabel.frame = CGRect(x: 0, y: 0, width: width / 6, height: 36)
        doneLabel.backgroundColor = .clear
        let doneGesture = UITapGestureRecognizer(target: self, action: #selector(changeWeather))
        doneLabel.addGestureRecognizer(doneGesture)
        doneLabel.isUserInteractionEnabled = true
        doneLabel.text = "확인"
        doneLabel.textAlignment = .center
        let doneBtn = UIBarButtonItem(customView: doneLabel)
        let flexibleBtn = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width / 3, height: 36))
        label.text = "날씨 변경하기"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 14)
        
        let flexibleLB = UIBarButtonItem(customView: flexibleLabel)
        let labelBtn = UIBarButtonItem(customView: label)
        toolBar.setItems([flexibleLB,flexibleBtn,labelBtn,flexibleBtn,doneBtn], animated: true)
        toolBar.isTranslucent = true
        weatherTF.inputAccessoryView = toolBar
        weatherTF.becomeFirstResponder()
    }
    
    @objc func changeWeather() {
        weatherTF.resignFirstResponder()
    }
    
    @objc func cancelWeaterPickerView() {
        
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        weather.text = pickerData[row]
    }
    
    @objc func popViewController() {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: addImageGessture
extension WriteViewController {
    @objc fileprivate func addImageGesture() {
        if !isImageLoadingFromiCloud {
            let photoViewController = PhotosViewController(nibName: nil, bundle: nil, photosViewControllerDelegate: self)
            self.navigationController?.pushViewController(photoViewController, animated: true)
        }
    }
}

extension WriteViewController {
    //MARK: dateTF inputViews
    @objc fileprivate func touchUpInsideDateLabel(sender : UILabel) {
        let width = self.view.frame.size.width
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.minimumDate = stringToDate(in: "20170101", dateFormat: "yyyyMMdd")
        datePicker.maximumDate = stringToDate(in: "20211231", dateFormat: "yyyyMMdd")
        dateTF.inputView = datePicker
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        toolBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 36)
        toolBar.barStyle = .default
        
        let doneLabel = UILabel()
        doneLabel.frame = CGRect(x: 0, y: 0, width: width / 6, height: 36)
        doneLabel.backgroundColor = .clear
        let doneGesture = UITapGestureRecognizer(target: self, action: #selector(changedDate(sender:)))
        doneLabel.addGestureRecognizer(doneGesture)
        doneLabel.isUserInteractionEnabled = true
        doneLabel.text = "확인"
        doneLabel.textAlignment = .center
        let doneBtn = UIBarButtonItem(customView: doneLabel)
        
        let cancelLabel = UILabel()
        cancelLabel.frame = CGRect(x: 0, y: 0, width: width / 6, height: 36)
        cancelLabel.backgroundColor = .clear
        let cancelGesture = UITapGestureRecognizer(target: self, action: #selector(dismissDatePciker(sender:)))
        cancelLabel.addGestureRecognizer(cancelGesture)
        cancelLabel.isUserInteractionEnabled = true
        cancelLabel.text = "취소"
        cancelLabel.textAlignment = .center
        let cancelBtn = UIBarButtonItem(customView: cancelLabel)
        
        let flexibleBtn = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width / 3, height: 36))
        label.text = "날짜 변경하기"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 14)
        let labelBtn = UIBarButtonItem(customView: label)
        
        toolBar.setItems([cancelBtn,flexibleBtn,labelBtn,flexibleBtn,doneBtn], animated: true)
        toolBar.isTranslucent = true
        dateTF.inputAccessoryView = toolBar
        dateTF.becomeFirstResponder()
        
    }
    
    @objc fileprivate func changedDate(sender : UIBarButtonItem) {
        setInformation(in: datePicker.date)
        dateTF.resignFirstResponder()
    }
    
    @objc fileprivate func dismissDatePciker(sender : UIBarButtonItem) {
        dateTF.resignFirstResponder()
    }
    
}

extension WriteViewController {
    //MARK: UIKeyboard notification
    fileprivate func regitsterForTextViewNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(cleanTextView),
                                               name: UITextView.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textViewState),
                                               name: UITextView.textDidEndEditingNotification, object: nil)
    }
    
    fileprivate func unregisterForTextViewTextNotification() {
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidEndEditingNotification, object: nil)
    }
    
    fileprivate func registerForKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keboardFrameWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameDidChange), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    fileprivate func unregisterForKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if keyboardShown == true {
            view.endEditing(true)
        }
    }
    
    @objc fileprivate func keyboardDidShow(notification: NSNotification) {
        //        adjustingHeight(notification: notification)
    }
    
    @objc fileprivate func keyboardFrameDidChange(notification: NSNotification) {
        adjustingHeight(notification: notification)
    }
    
    @objc fileprivate func keboardFrameWillHide(notification : NSNotification) {
        adjustingHide(notification: notification)
    }
    
    fileprivate func adjustingHeight(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        let keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        if keyboardFrame.height == 0 || keyboardShown == true {
            return
        } else {
            self.contentsTextViewCGRect = contents.frame
            contents.frame.size.height = contents.frame.size.height - keyboardFrame.height
            keyboardShown = true
        }
    }
    
    fileprivate func adjustingHide(notification : NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        let keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        self.contents.frame.size.height = self.contentsTextViewCGRect.height
        keyboardShown = false
    }
}

//MARK: animation contentImgV
extension WriteViewController {
    func transformContentImgV(view : UIImageView?) {
        if contentImgV == nil {
            return
        } else {
            let transX = (contentImgV.frame.size.width)
            UIImageView.animate(withDuration: 0.5) {
                view?.transform = CGAffineTransform(translationX: -transX, y: 0)
            }
        }
    }
}

extension WriteViewController: SendDrawingImageDelegate, RSKImageCropViewControllerDelegate, RSKImageCropViewControllerDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func sendDrawingImageDelegate(_ image: UIImage) {
        
    }
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        self.contentImgV?.image = croppedImage
        self.selectedImageData = croppedImage.pngData()
        controller.dismiss(animated: true) {
            self.transformContentImgV(view: self.contentImgV)
        }
    }
    
    func imageCropViewControllerCustomMaskRect(_ controller: RSKImageCropViewController) -> CGRect {
        let width = self.view.bounds.width
        let height = width * 0.75
        let maskRect = CGRect(x: 0, y: 100, width: width, height: height)
        return maskRect
    }
    
    func imageCropViewControllerCustomMaskPath(_ controller: RSKImageCropViewController) -> UIBezierPath {
        let rect = controller.maskRect
        let point1 = CGPoint(x: rect.minX, y: rect.maxY)
        let point2 = CGPoint(x: rect.maxX, y: rect.maxY)
        let point3 = CGPoint(x: rect.maxX, y: rect.minY)
        let point4 = CGPoint(x: rect.minX, y: rect.minY)
        
        let rectangle = UIBezierPath()
        rectangle.move(to: point1)
        rectangle.addLine(to: point2)
        rectangle.addLine(to: point3)
        rectangle.addLine(to: point4)
        rectangle.close()
        return rectangle
    }
    
    func imageCropViewControllerCustomMovementRect(_ controller: RSKImageCropViewController) -> CGRect {
        let rect = controller.maskRect
        return rect
    }
    
    
}

