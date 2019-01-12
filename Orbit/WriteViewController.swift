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

protocol WriteDoneDelegate: class {
    func writeDone()
}
class WriteViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var isImageLoadingFromiCloud: Bool = false
    fileprivate var keyboardShown = false
    var contentsTextViewCGRect : CGRect!
    
    //MARK: Ream Property
    //    var content = Content()
    //    var user = User()
    var realm = try! Realm()
    let realmManager = RealmManager.shared.realm
    
    //    var model : Model.Contents?
    
    weak var writeDoneDelegate: WriteDoneDelegate!
    fileprivate var date : UILabel!
    fileprivate var titleLabel : UILabel!
    fileprivate var contentTitle: UITextField!
    var dayOfWeek: UILabel!
    var weather: UILabel!
    
    //    fileprivate var weatherImg : UIImageView!
    fileprivate var writeDoneIcon : UIImageView!
    fileprivate var dateTF : CustomTextFiled!
    fileprivate var weatherTF : CustomTextFiled!
    fileprivate var today : Date!
    fileprivate var createAtMonth : String!
    var containerV : UIView!
    fileprivate var contStackV : UIStackView!
    fileprivate var stackBox : UIStackView!
    //    fileprivate var writeDoneBtn : UIButton!
    fileprivate var tapWeather : UIImageView!
    fileprivate var tapDate : UIImageView!
    var contentImgV : UIImageView!
    fileprivate var cameraIconImgView : UIImageView!
    fileprivate var iconBgView : UIView!
    fileprivate var contents : UITextView!
    fileprivate var models : [Model.Contents] = [Model.Contents]()
    var selectedImageData: Data?
    fileprivate var datePicker : UIDatePicker!
    fileprivate var weatherPicker : UIPickerView!
    let pickerData : [String] = [ "맑음", "천둥번개", "이슬비", "비","눈","눈,비","진눈깨비", "안개", "구름", "구름조금"]
    var backButton : UIImageView = UIImageView()
    var weatherItem : Int = 0
    
    
    
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
        setNavigationBackButton(onView: self, in: backButton, bool: true)
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
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .automatic
        self.navigationItem.title = "Write"
        self.navigationItem.hidesBackButton = true
        
    }
    
    override func viewWillLayoutSubviews() {
        if containerV == nil {
            setupLayout()
            setInformation(in: getDate(dateFormat: "dd MMM yyyy hh mm"))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setInformation(in todayDate : String) {
        today = stringToDate(in: todayDate, dateFormat: "dd MMM yyyy hh mm")
        dayOfWeek.text = getWeekDay(in: today, dateFormat: "EEEE")
        date.text = dateToString(in: today, dateFormat: "dd MMM yyyy")
        createAtMonth = dateToString(in: today, dateFormat: "MMM yyyy")
        setWeather(id: weatherItem)
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
                showAlert(title: "경 고", message: "아무 내용이 없어요 \n 이대로 저장할까요?",
                          cancelBtn: true, buttonTitle: "확인", onView: self) { (action) in
                            self.contents.text = " "
                            let data = Content(createdAt: self.today, createdAtMonth : self.createAtMonth ,title: self.contentTitle.text!,
                                               weather: self.weather.text!, body: self.contents.text!, image: self.selectedImageData)
                            RealmManager.shared.creat(object: data)
                            self.writeDoneDelegate.writeDone()
                            self.navigationController?.popViewController(animated: true)
                }
            } else {
                let data = Content(createdAt: self.today, createdAtMonth : self.createAtMonth ,title: self.contentTitle.text!,
                                   weather: self.weather.text!, body: self.contents.text!, image: self.selectedImageData)
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
        // MARK: containerV UIView
        
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
        
        // MARK: dayofWeek Label
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
        dayOfWeek.font.withSize(24)
        dayOfWeek.font = UIFont.boldSystemFont(ofSize: 24)
        dayOfWeek.textAlignment = NSTextAlignment.left
        dayOfWeek.backgroundColor = .clear
        
        //MARK: dateTF textfield
        dateTF = CustomTextFiled()
        dateTF.translatesAutoresizingMaskIntoConstraints = false
        let constDateTF : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: dateTF, attribute: .top, relatedBy: .equal, toItem: dayOfWeek, attribute: .bottom,
                               multiplier: 1, constant: 1),
            NSLayoutConstraint(item: dateTF, attribute: .leading, relatedBy: .equal, toItem: dayOfWeek, attribute: .leading,
                               multiplier: 1, constant: 0),
            NSLayoutConstraint(item: dateTF, attribute: .trailing, relatedBy: .equal, toItem: dayOfWeek, attribute: .trailing,
                               multiplier: 1, constant: 0),
            NSLayoutConstraint(item: dateTF, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height,
                               multiplier: 1,constant: 24),
            NSLayoutConstraint(item: dateTF, attribute: .width, relatedBy: .equal, toItem: containerV, attribute: .width,
                               multiplier: 0.4, constant: 0)]
        
        containerV.addSubview(dateTF)
        containerV.addConstraints(constDateTF)
        dateTF.backgroundColor = .clear
        
        dateTF.allowsEditingTextAttributes = false
        
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
        date.textAlignment = NSTextAlignment.left
        date.backgroundColor = .clear
        let changeDateGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(touchUpInsideDateLabel(sender:)))
        date.isUserInteractionEnabled = true
        date.addGestureRecognizer(changeDateGestureRecognizer)
        
        //MARK: weather Label
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
                               attribute: .trailing, multiplier: 1, constant: 0)]
        
        containerV.addSubview(weatherTF)
        containerV.addConstraints(constWeatherTF)
        weatherTF.allowsEditingTextAttributes = false
        let changeWeatherGesture = UITapGestureRecognizer(target: self, action: #selector(weatherTextFieldReconiger))
        weatherTF.isUserInteractionEnabled = true
        weatherTF.addGestureRecognizer(changeWeatherGesture)
        
        //MARK: tapDate UIImageView
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
        
        //MARK: tapWeather UIImageView
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
        
        //MARK: contStackV UIStackView
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
        contStackV.backgroundColor = .clear
        
        //MARK: stackBox UIStackView
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
                               multiplier: 1, constant: 72)]
        
        contStackV.addSubview(stackBox)
        contStackV.addConstraints(constStackBox)
        stackBox.distribution = .fill
        stackBox.spacing = 1
        
        //MARK: iconBgView
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
        
        //MARK: contentImgBackgroundView UIImageView
        
        //MARK: contentImgV UIImageView
        contentImgV = UIImageView()
        contentImgV.translatesAutoresizingMaskIntoConstraints = false
        
        
        let constImgV : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: contentImgV, attribute: .top, relatedBy: .equal, toItem: dayOfWeek, attribute: .top,
                               multiplier: 1, constant:0),
            NSLayoutConstraint(item: contentImgV, attribute: .bottom, relatedBy: .equal, toItem: weather, attribute: .bottom,
                               multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contentImgV, attribute: .leading, relatedBy: .equal, toItem: containerV, attribute: .trailing,
                               multiplier: 1, constant: containerV.frame.size.width / 3 + 8),
            NSLayoutConstraint(item: contentImgV, attribute: .width, relatedBy: .equal, toItem:  containerV, attribute: .width,
                               multiplier: 0.3, constant: 0)]
        
        containerV.addSubview(self.contentImgV)
        containerV.addConstraints(constImgV)
        contentImgV.layer.cornerRadius = 16
        contentImgV.layer.maskedCorners = [CACornerMask.layerMinXMinYCorner, CACornerMask.layerMinXMaxYCorner]
        contentImgV.layer.borderWidth = 1
        contentImgV.layer.borderColor = UIColor.black.cgColor
        contentImgV.clipsToBounds = true
        contentImgV.backgroundColor = .clear
        
        //MARK: titleLabel
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let constTitleLB : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: stackBox, attribute: .top,
                               multiplier: 1, constant: 0),
            NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal, toItem: stackBox, attribute: .height,
                               multiplier: 0.5, constant: 0),
            NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: stackBox, attribute: .leading,
                               multiplier: 1, constant: 0),
            NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: iconBgView, attribute: .leading,
                               multiplier: 1, constant: 0)]
        
        stackBox.addSubview(titleLabel)
        stackBox.addConstraints(constTitleLB)
        titleLabel.text = "Today Title"
        titleLabel.font.withSize(20)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.backgroundColor = .clear
        
        //MARK: contentTitle Label
        contentTitle = UITextField()
        contentTitle.translatesAutoresizingMaskIntoConstraints = false
        
        let constTitle : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: contentTitle, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height,
                               multiplier: 1, constant: 30),
            NSLayoutConstraint(item: contentTitle, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom,
                               multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contentTitle, attribute: .leading, relatedBy: .equal, toItem: stackBox, attribute: .leading,
                               multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contentTitle, attribute: .trailing, relatedBy: .equal, toItem: stackBox, attribute: .trailing,
                               multiplier: 1, constant: -72)]
        
        stackBox.addSubview(contentTitle)
        stackBox.addConstraints(constTitle)
        contentTitle.attributedPlaceholder = NSAttributedString(string: " 제목을 쓰윽쓰윽",
                                                                attributes: [NSAttributedStringKey.foregroundColor :
                                                                    UIColor(red: 208/255, green: 207/255, blue: 208/255, alpha: 1)])
        contentTitle.backgroundColor = UIColor(red: 246/255, green: 252/255, blue: 226/255, alpha: 1)
        contentTitle.font?.withSize(15)
        
        //MARK: cameraIconImgView UIImageView
        cameraIconImgView = UIImageView()
        cameraIconImgView.translatesAutoresizingMaskIntoConstraints = false
        
        let constCameraIconImg : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: cameraIconImgView, attribute: .top, relatedBy: .equal, toItem: contentTitle,
                               attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: cameraIconImgView, attribute: .leading, relatedBy: .equal, toItem: contentTitle,
                               attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: cameraIconImgView, attribute: .trailing, relatedBy: .equal, toItem: stackBox,
                               attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: cameraIconImgView, attribute: .bottom, relatedBy: .equal, toItem: contentTitle,
                               attribute: .bottom, multiplier: 1, constant: 0)]
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
        
        //MARK: contents UITextView
        contents = UITextView()
        contents.translatesAutoresizingMaskIntoConstraints = false
        
        let constContens : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: contents, attribute: .top, relatedBy: .equal, toItem: stackBox, attribute: .bottom,
                               multiplier: 1, constant: 0),
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
        contents.text = "글을 입력하세요"
        contents.font = UIFont.systemFont(ofSize: 18)
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
                                   attribute: .width, multiplier: 1, constant: 36),
                NSLayoutConstraint(item: writeDoneIcon, attribute: .height, relatedBy: .equal, toItem: nil,
                                   attribute: .height, multiplier: 1, constant: 36),
                NSLayoutConstraint(item: writeDoneIcon, attribute: .trailing, relatedBy: .equal, toItem: self.navigationController?.navigationBar, attribute: .trailing, multiplier: 1, constant: -8),
                NSLayoutConstraint(item: writeDoneIcon, attribute: .bottom, relatedBy: .equal, toItem: self.navigationController?.navigationBar, attribute: .bottom, multiplier: 1, constant: -8)]
            navigationController?.navigationBar.addSubview(writeDoneIcon)
            navigationController?.navigationBar.addConstraints(constWrtieDoneIcon)
            
            writeDoneIcon.image = UIImage(named: "check")
            writeDoneIcon.layer.cornerRadius = 18
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
    
    @objc func contentsTextViewReconiger(sender : UITextView) {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        toolBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 36)
        toolBar.tintColor = .white
        toolBar.barStyle = .blackTranslucent
        let rightAlignment = UIBarButtonItem(title: "right", style: .done, target: self,
                                             action: #selector(rightTextAlignment))
        let leftAlignment = UIBarButtonItem(title: "left", style: .done, target: self,
                                            action: #selector(leftTextAlignment))
        let centerAlignment = UIBarButtonItem(title: "center", style: .done, target: self,
                                              action: #selector(centerTextAlignment))
        let flexibleBtn = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        toolBar.setItems([leftAlignment,flexibleBtn,centerAlignment,flexibleBtn,rightAlignment], animated: true)
        toolBar.isTranslucent = true
        contents.inputAccessoryView = toolBar
        contents.becomeFirstResponder()
    }
    
    @objc func rightTextAlignment() {
        contents.textAlignment = .right
    }
    
    @objc func leftTextAlignment() {
        contents.textAlignment = .left
    }
    
    @objc func centerTextAlignment() {
        contents.textAlignment = .center
    }
    @objc fileprivate func cleanTextView() {
        contents.text = ""
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
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        toolBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 36)
        toolBar.tintColor = .white
        toolBar.barStyle = .blackTranslucent
        let doneBtn = UIBarButtonItem(title: "완료", style: .done, target: self,
                                      action: #selector(changeWeather))
        let flexibleBtn = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: 36))
        label.textColor = .white
        label.text = "날씨 변경하기"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 14)
        let labelBtn = UIBarButtonItem(customView: label)
        toolBar.setItems([flexibleBtn,flexibleBtn,labelBtn,flexibleBtn,doneBtn], animated: true)
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
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.minimumDate = stringToDate(in: "20170101", dateFormat: "yyyyMMdd")
        datePicker.maximumDate = stringToDate(in: "20211231", dateFormat: "yyyyMMdd")
        dateTF.inputView = datePicker
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        toolBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 36)
        toolBar.tintColor = .white
        toolBar.barStyle = .blackTranslucent
        let doneBtn = UIBarButtonItem(title: "완료", style: .done, target: self,
                                      action: #selector(changedDate(sender:)))
        let cancelBtn = UIBarButtonItem(title: "취소", style: .done, target: self,
                                        action: #selector(dismissDatePciker(sender:)))
        let flexibleBtn = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: 36))
        label.textColor = .white
        label.text = "날짜 변경하기"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 14)
        let labelBtn = UIBarButtonItem(customView: label)
        toolBar.setItems([cancelBtn,flexibleBtn,labelBtn,flexibleBtn,doneBtn], animated: true)
        toolBar.isTranslucent = true
        dateTF.inputAccessoryView = toolBar
        dateTF.becomeFirstResponder()
        //            datePicker.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
    }
    
    @objc fileprivate func changedDate(sender : UIBarButtonItem) {
        setInformation(in: dateToString(in: datePicker.date, dateFormat: "dd MMM yyyy hh mm"))
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
                                               name: NSNotification.Name.UITextViewTextDidBeginEditing, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textViewState),
                                               name: NSNotification.Name.UITextViewTextDidEndEditing, object: nil)
    }
    
    fileprivate func unregisterForTextViewTextNotification() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidBeginEditing, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidEndEditing, object: nil)
    }
    
    fileprivate func registerForKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keboardFrameWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameDidChange), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    fileprivate func unregisterForKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
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
        let keyboardFrame: CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        print(keyboardFrame.height)
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
        let keyboardFrame: CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        print(keyboardFrame.height)
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
