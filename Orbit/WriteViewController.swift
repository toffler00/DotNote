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

class WriteViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var isImageLoadingFromiCloud: Bool = false
    var keyboardShown = false
    
    //MARK: Ream Property
//    var content = Content()
//    var user = User()
    var realm = try! Realm()
    let realmManager = RealmManager.shared.realm

    //    var model : Model.Contents?
    
    fileprivate weak var diaryWriteDelegate: DiaryWriteDelegate!
    fileprivate var titleLabel : UILabel!
    fileprivate var contentTitle: UITextField!
    fileprivate var dayOfWeek: UILabel!
    fileprivate var weather: UILabel!
    
//    fileprivate var weatherImg : UIImageView!
    fileprivate var date : UILabel!
    fileprivate var today : Date!
    fileprivate var containerV : UIView!
    fileprivate var contStackV : UIStackView!
    fileprivate var stackBox : UIStackView!
    fileprivate var writeDoneBtn : UIButton!
    var contentImgV : UIImageView!
    fileprivate var cameraIconImgView : UIImageView!
    fileprivate var iconBgView : UIView!
    fileprivate var contents : UITextView!
    fileprivate var models : [Model.Contents] = [Model.Contents]()
    var selectedImageData: Data?
    var weatherItems : Model.WeatherModel.Weather?
    
    
    fileprivate var locationManager: CLLocationManager!
    fileprivate var coordinate : CLLocationCoordinate2D?  {
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
                                self.weatherItems = items
                                self.weather.text = items.main
                            }
                        }
                    })
                }
            }
        }
    }
    
    
    init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil, delegate: DiaryWriteDelegate) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.diaryWriteDelegate = delegate
        view.backgroundColor = .white
        setupLocationManager()
    }
    
    //MARK: LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        registerForKeyboardNotification()
        regitsterForTextViewNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unregisterForKeyboardNotification()
        unregisterForTextViewTextNotification()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .automatic
        self.navigationItem.title = "Write"
        

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
    }
}

//MARK: writeDone Post
extension WriteViewController : DiaryWriteDelegate {
   @objc func writeDone() {
    let getMonth = dateToString(in: today, dateFormat: "yyyyMM")
    let data = Content(createdAt: today, title: contentTitle.text!,
                       weather: weather.text!, body: contents.text!, image: selectedImageData!)
    RealmManager.shared.creat(object: data)
    navigationController?.popViewController(animated: true)
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
                               multiplier: 1,constant: 20),
            NSLayoutConstraint(item: date, attribute: .width, relatedBy: .equal, toItem: containerV, attribute: .width,
                               multiplier: 0.4, constant: 0)]
        
        containerV.addSubview(date)
        containerV.addConstraints(constDate)
        date.numberOfLines = 1
        date.adjustsFontForContentSizeCategory = true
        date.adjustsFontSizeToFitWidth = true
        
        date.textAlignment = NSTextAlignment.left
        date.backgroundColor = .clear
        
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

        writeDoneBtn = UIButton()
        writeDoneBtn.translatesAutoresizingMaskIntoConstraints = false
        
        let constwrt : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: writeDoneBtn, attribute: .top, relatedBy: .equal, toItem: containerV, attribute: .top,
                               multiplier: 1, constant: 8),
            NSLayoutConstraint(item: writeDoneBtn, attribute: .trailing, relatedBy: .equal, toItem: containerV, attribute: .trailing,
                               multiplier: 1, constant: -8),
            NSLayoutConstraint(item: writeDoneBtn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height,
                               multiplier: 1, constant: 48),
            NSLayoutConstraint(item: writeDoneBtn, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width,
                               multiplier: 1, constant: 48)]
        
        containerV.addSubview(writeDoneBtn)
        containerV.addConstraints(constwrt)
        writeDoneBtn.backgroundColor = .yellow
        writeDoneBtn.addTarget(self, action: #selector(writeDone) , for: .touchUpInside)
        
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
        
        //MARK: cameraIconImgView UIImageView
        cameraIconImgView = UIImageView()
        cameraIconImgView.translatesAutoresizingMaskIntoConstraints = false
        
        let constCameraIconImg : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: cameraIconImgView, attribute: .width, relatedBy: .equal, toItem: iconBgView,
                               attribute: .width, multiplier: 0.7, constant: 0),
            NSLayoutConstraint(item: cameraIconImgView, attribute: .height, relatedBy: .equal, toItem: iconBgView,
                               attribute: .height, multiplier: 0.7, constant: 0),
            NSLayoutConstraint(item: cameraIconImgView, attribute: .centerX, relatedBy: .equal, toItem: iconBgView,
                               attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: cameraIconImgView, attribute: .centerY, relatedBy: .equal, toItem: iconBgView,
                               attribute: .centerY, multiplier: 1, constant: 0)]
        iconBgView.addSubview(cameraIconImgView)
        iconBgView.addConstraints(constCameraIconImg)
        cameraIconImgView.contentMode = .scaleAspectFill
        cameraIconImgView.layer.cornerRadius = 18
        cameraIconImgView.clipsToBounds = true
        cameraIconImgView.backgroundColor = .clear
        cameraIconImgView.image = UIImage(named: "photo")
        
        //MARK: contentImgV UIImageView
        contentImgV = UIImageView()
        contentImgV.translatesAutoresizingMaskIntoConstraints = false
        
        let constImgV : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: contentImgV, attribute: .top, relatedBy: .equal, toItem: iconBgView, attribute: .top,
                               multiplier: 1, constant:0),
            NSLayoutConstraint(item: contentImgV, attribute: .bottom, relatedBy: .equal, toItem: iconBgView, attribute: .bottom,
                               multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contentImgV, attribute: .leading, relatedBy: .equal, toItem: iconBgView, attribute: .leading,
                               multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contentImgV, attribute: .trailing, relatedBy: .equal, toItem: iconBgView, attribute: .trailing,
                               multiplier: 1, constant: 0)]
        
        iconBgView.addSubview(contentImgV)
        iconBgView.addConstraints(constImgV)
        contentImgV.contentMode = .scaleAspectFill
        contentImgV.layer.cornerRadius = 36
        contentImgV.layer.borderWidth = 2
        contentImgV.layer.borderColor = UIColor.black.cgColor
        contentImgV.clipsToBounds = true
        contentImgV.backgroundColor = .clear
        contentImgV.isUserInteractionEnabled = true
        
        let addImageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addImageGesture))
        contentImgV.addGestureRecognizer(addImageGestureRecognizer)
        
        //MARK: titleLabel
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let constTitleLB : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: stackBox, attribute: .top,
                               multiplier: 1, constant: 0),
            NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal, toItem: contentImgV, attribute: .height,
                               multiplier: 0.5, constant: 0),
            NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: stackBox, attribute: .leading,
                               multiplier: 1, constant: 0),
            NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: contentImgV, attribute: .leading,
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
        
    }
}

extension WriteViewController {
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
            contents.frame.size.height = contents.frame.size.height - keyboardFrame.height
            keyboardShown = true
        }
    }
    
    fileprivate func adjustingHide(notification : NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        let keyboardFrame: CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        print(keyboardFrame.height)
        let height = self.contents.frame.height
        self.contents.frame.size.height = height + keyboardFrame.height
        keyboardShown = false
    }
}

extension WriteViewController {
    @objc fileprivate func addImageGesture() {
        if !isImageLoadingFromiCloud {
            let photoViewController = PhotosViewController(nibName: nil, bundle: nil, photosViewControllerDelegate: self)
            self.navigationController?.pushViewController(photoViewController, animated: true)
        }
    }
}

// MARK: setupLocationManager
extension WriteViewController: CLLocationManagerDelegate {
    
    fileprivate func setupLocationManager() {
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(locations.first!) {[weak self] (placeMark, error) in
            if let error = error {
                log.error(error)
            } else {
//                self?.currentPlace = placeMark?.first?.administrativeArea
                self?.coordinate = placeMark?.first?.location?.coordinate
//                log.debug(placeMark?.first?.name)
//                log.debug(placeMark?.first?.locality)
//                log.debug(placeMark?.first!.subLocality)
            }
        }
        locationManager.stopUpdatingLocation()
    }
}
