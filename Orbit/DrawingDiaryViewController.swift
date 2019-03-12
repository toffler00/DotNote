//
//  DrawingDiaryViewController.swift
//  Orbit
//
//  Created by ilhan won on 07/02/2019.
//  Copyright © 2019 orbit. All rights reserved.
//

import UIKit
import NXDrawKit
import RSKImageCropper
import AVFoundation
import MobileCoreServices

class DrawingDiaryViewController : UIViewController {
    
    var containerScrollView: UIScrollView!
    var containerView : UIView!
    var innerContainerView : UIView!
    var stateStackView : UIStackView!
    var dateContainerView : UIView!
    var selectedDate : Date!
    var selectDateTextField : CustomTextFiled!
    var creationDate : UILabel!
    var dateLabel : UILabel!
    var weatherContainerView : UIView!
    var selectWeatherTextField : CustomTextFiled!
    var weatherLabel : UILabel!
    var weatherState : UIImageView!
    var titleLabel : UILabel!
    var contentTitle : UITextField!
    var drawingImage : UIImageView!
    var contents : UITextView!
    var writeDoneIcon : UIImageView!
    var weatherItem : Int = 0
    var weatherName : String = ""
    var weatherPicker : UIPickerView!
    let pickerData : [String] = [ "맑음", "천둥번개", "이슬비", "비","눈","눈,비","진눈깨비", "안개", "구름", "구름조금"]
    var datePicker : UIDatePicker!
    
    weak var canvasView : Canvas?
    weak var palletView : Palette?
    weak var toolBar : ToolBar?
    weak var bottomView : UIView?
    
    fileprivate var backButton : UIImageView = UIImageView()
    fileprivate var keyboardShown : Bool = false
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .automatic
        self.navigationItem.title = "Drawing Diary"
        self.navigationItem.hidesBackButton = true
        self.view.backgroundColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        registerForKeyboardNotification()
        setUpWriteDoneIcon(bool: true)
        setNavigationBackButton(onView: self, in: backButton, bool: true)
    }
    
    override func viewWillLayoutSubviews() {
        if drawingImage == nil {
            addsubView()
            setupUI()
            setInfomation()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        setNavigationBackButton(onView: self, in: backButton, bool: false)
        unregisterForKeyboardNotification()
        setUpWriteDoneIcon(bool: false)
    }
    
    private func setInfomation() {
        let date = getDate(dateFormat: "yyyy MM dd eee hh mm ss")
        let create = stringToDate(in: date, dateFormat: "yyyy MM dd eee hh mm ss")
        let createDate = dateToString(in: create, dateFormat: "yyyy.M.dd.eee")
        self.creationDate.text = createDate
        self.selectedDate = create
        setWeather(id: weatherItem)
        changeWeatherIcon(weather: weatherName)
    }
    
    func setWeather(id : Int) {
        switch id {
        case 200...299:
            weatherName = "천둥번개"
        case 300...399:
            weatherName = "이슬비"
        case 500...599:
            weatherName = "비"
        case 600, 601, 602, 620, 621, 622 :
            weatherName = "눈"
        case 611, 612:
            weatherName = "진눈깨비"
        case 615, 616:
            weatherName = "눈,비"
        case 700...799:
            weatherName = "안개"
        case 800:
            weatherName = "맑음"
        case 801, 802:
            weatherName = "구름"
        case 803, 804:
            weatherName = "구름조금"
        default:
            weatherName = "날씨를 선택하세요"
        }
    }
    
    @objc func changeWeatherIcon(weather : String) {
        switch weather {
        case "맑음" :
            self.weatherState.image = UIImage(named: "sun")
        case "안개" :
            self.weatherState.image = UIImage(named: "haze")
        case "구름", "구름조금" :
            self.weatherState.image = UIImage(named: "cloudy")
        case "이슬비" :
            self.weatherState.image = UIImage(named: "hail")
        case "비" :
            self.weatherState.image = UIImage(named: "rainy")
        case "눈","진눈깨비", "눈,비" :
            self.weatherState.image = UIImage(named: "snow")
        case "천둥번개" :
            self.weatherState.image = UIImage(named: "storm")
        default:
            self.weatherState.backgroundColor = .clear
        }
    }
    private func addsubView() {
        containerScrollView = UIScrollView()
        containerView = UIView()
        stateStackView = UIStackView()
        dateContainerView = UIView()
        selectDateTextField = CustomTextFiled()
        creationDate = UILabel()
        dateLabel = UILabel()
        weatherContainerView = UIView()
        selectWeatherTextField = CustomTextFiled()
        weatherLabel = UILabel()
        weatherState = UIImageView()
        titleLabel = UILabel()
        contentTitle = UITextField()
        innerContainerView = UIView()
        drawingImage = UIImageView()
        contents = UITextView()
        
        containerScrollView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        stateStackView.translatesAutoresizingMaskIntoConstraints = false
        dateContainerView.translatesAutoresizingMaskIntoConstraints = false
        selectDateTextField.translatesAutoresizingMaskIntoConstraints = false
        creationDate.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        weatherContainerView.translatesAutoresizingMaskIntoConstraints = false
        selectWeatherTextField.translatesAutoresizingMaskIntoConstraints = false
        weatherLabel.translatesAutoresizingMaskIntoConstraints = false
        weatherState.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentTitle.translatesAutoresizingMaskIntoConstraints = false
        innerContainerView.translatesAutoresizingMaskIntoConstraints = false
        drawingImage.translatesAutoresizingMaskIntoConstraints = false
        contents.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        containerView.addSubview(containerScrollView)
        containerScrollView.addSubview(innerContainerView)
        innerContainerView.addSubview(drawingImage)
        innerContainerView.addSubview(contents)
        containerView.addSubview(stateStackView)
        dateContainerView.addSubview(selectDateTextField)
        dateContainerView.addSubview(creationDate)
        weatherContainerView.addSubview(selectWeatherTextField)
        weatherContainerView.addSubview(weatherState)
        stateStackView.addArrangedSubview(dateLabel)
        stateStackView.addArrangedSubview(dateContainerView)
        stateStackView.addArrangedSubview(weatherLabel)
        stateStackView.addArrangedSubview(weatherContainerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(contentTitle)
        
    }
    
    private func setupUI(){
        let height = self.navigationController?.navigationBar.bounds.height
        let window = UIApplication.shared.keyWindow
        let safePadding = window?.safeAreaInsets.top
        let heightPadding = CGFloat(height!) + CGFloat(safePadding!)
        let stackViewHeight : CGFloat = 36
        
        containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: heightPadding).isActive = true
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        stateStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
        stateStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0).isActive = true
        stateStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0).isActive = true
        stateStackView.axis = .horizontal
        
        dateLabel.backgroundColor = .clear
        dateLabel.heightAnchor.constraint(equalToConstant: stackViewHeight).isActive = true
        dateLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.1).isActive = true
        dateLabel.text = "날짜"
        dateLabel.textAlignment = .center
        
        dateContainerView.heightAnchor.constraint(equalToConstant: stackViewHeight).isActive = true
        dateContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        
        selectDateTextField.topAnchor.constraint(equalTo: dateContainerView.topAnchor, constant: 0).isActive = true
        selectDateTextField.leadingAnchor.constraint(equalTo: dateContainerView.leadingAnchor, constant: 0).isActive = true
        selectDateTextField.trailingAnchor.constraint(equalTo: dateContainerView.trailingAnchor, constant: 0).isActive = true
        selectDateTextField.bottomAnchor.constraint(equalTo: dateContainerView.bottomAnchor, constant: 0).isActive = true
        
        creationDate.backgroundColor = .clear
        creationDate.topAnchor.constraint(equalTo: dateContainerView.topAnchor, constant: 0).isActive = true
        creationDate.leadingAnchor.constraint(equalTo: dateContainerView.leadingAnchor, constant: 0).isActive = true
        creationDate.trailingAnchor.constraint(equalTo: dateContainerView.trailingAnchor, constant: 0).isActive = true
        creationDate.bottomAnchor.constraint(equalTo: dateContainerView.bottomAnchor, constant: 0).isActive = true
        creationDate.textAlignment = .left
        let creationDateGeusture = UITapGestureRecognizer(target: self, action: #selector(touchUpInsideDateLabel))
        creationDate.addGestureRecognizer(creationDateGeusture)
        creationDate.isUserInteractionEnabled = true
        
        weatherLabel.backgroundColor = .clear
        weatherLabel.heightAnchor.constraint(equalToConstant: stackViewHeight).isActive = true
        weatherLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.2).isActive = true
        weatherLabel.text = "날씨"
        weatherLabel.textAlignment = .center
        
        weatherContainerView.heightAnchor.constraint(equalToConstant: stackViewHeight).isActive = true
        weatherContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.2).isActive = true
        
        selectWeatherTextField.topAnchor.constraint(equalTo: weatherContainerView.topAnchor, constant: 0).isActive = true
        selectWeatherTextField.leadingAnchor.constraint(equalTo: weatherContainerView.leadingAnchor, constant: 0).isActive = true
        selectWeatherTextField.trailingAnchor.constraint(equalTo: weatherContainerView.trailingAnchor, constant: 0).isActive = true
        selectWeatherTextField.bottomAnchor.constraint(equalTo: weatherContainerView.bottomAnchor, constant: 0).isActive = true
        
        weatherState.backgroundColor = .clear
        weatherState.topAnchor.constraint(equalTo: weatherContainerView.topAnchor, constant: 4).isActive = true
        weatherState.leadingAnchor.constraint(equalTo: weatherContainerView.leadingAnchor, constant: 4).isActive = true
        weatherState.trailingAnchor.constraint(equalTo: weatherContainerView.trailingAnchor, constant: -4).isActive = true
        weatherState.bottomAnchor.constraint(equalTo: weatherContainerView.bottomAnchor, constant: -4).isActive = true
        let weatherPickerGesture = UITapGestureRecognizer(target: self, action: #selector(weatherTextFieldReconiger))
        weatherState.addGestureRecognizer(weatherPickerGesture)
        weatherState.isUserInteractionEnabled = true
        weatherState.contentMode = .scaleAspectFit
        
        titleLabel.backgroundColor = .clear
        titleLabel.text = "제목"
        titleLabel.textAlignment = .center
        titleLabel.topAnchor.constraint(equalTo: stateStackView.bottomAnchor, constant: 0).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: stackViewHeight).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.1).isActive = true
        
        contentTitle.backgroundColor = .clear
        contentTitle.placeholder = "은 여기에"
        contentTitle.topAnchor.constraint(equalTo: stateStackView.bottomAnchor, constant: 0).isActive = true
        contentTitle.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 0).isActive = true
        contentTitle.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0).isActive = true
        contentTitle.heightAnchor.constraint(equalToConstant: stackViewHeight).isActive = true
        let titleGestureReconizer = UITapGestureRecognizer(target: self, action: #selector(addToolBarToTextFieldKeyboard))
        contentTitle.addGestureRecognizer(titleGestureReconizer)
        contentTitle.isUserInteractionEnabled = true
        
        containerScrollView.topAnchor.constraint(equalTo: contentTitle.bottomAnchor, constant: 0).isActive = true
        containerScrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0).isActive = true
        containerScrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0).isActive = true
        containerScrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0).isActive = true
        containerScrollView.showsVerticalScrollIndicator = true
        
        innerContainerView.topAnchor.constraint(equalTo: contentTitle.bottomAnchor, constant: 0).isActive = true
        innerContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0).isActive = true
        innerContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0).isActive = true
        innerContainerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0).isActive = true

        drawingImage.backgroundColor = .white
        drawingImage.topAnchor.constraint(equalTo: innerContainerView.topAnchor, constant: 0).isActive = true
        drawingImage.leadingAnchor.constraint(equalTo: innerContainerView.leadingAnchor, constant: 0).isActive = true
        drawingImage.trailingAnchor.constraint(equalTo: innerContainerView.trailingAnchor, constant: 0).isActive = true
        drawingImage.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75).isActive = true
        drawingImage.layer.borderWidth = 0.5
        drawingImage.layer.borderColor = UIColor(red: 47/255, green: 36/255, blue: 34/255, alpha: 1).cgColor
        let drawingImgGesture = UITapGestureRecognizer(target: self, action: #selector(pushDrawingView))
        drawingImage.addGestureRecognizer(drawingImgGesture)
        drawingImage.isUserInteractionEnabled = true
        
        contents.backgroundColor = UIColor(red: 246/255, green: 252/255, blue: 226/255, alpha: 1)
        contents.topAnchor.constraint(equalTo: drawingImage.bottomAnchor, constant: 0).isActive = true
        contents.leadingAnchor.constraint(equalTo: innerContainerView.leadingAnchor, constant: 0).isActive = true
        contents.trailingAnchor.constraint(equalTo: innerContainerView.trailingAnchor, constant: 0).isActive = true
        contents.bottomAnchor.constraint(equalTo: innerContainerView.bottomAnchor, constant: 0).isActive = true
        let contentsGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(textViewKeyboardAddToolBar))
        contents.isUserInteractionEnabled = true
        contents.addGestureRecognizer(contentsGestureRecognizer)
        contents.text = "글을 입력하세요"
        contents.tintColor = .gray
        contents.textColor = UIColor(red: 208/255, green: 207/255, blue: 208/255, alpha: 1)
        
    }
    
}

//MARK: save button and method
extension DrawingDiaryViewController {
    func setUpWriteDoneIcon(bool : Bool) {
        if bool {
            writeDoneIcon = UIImageView()
            writeDoneIcon.translatesAutoresizingMaskIntoConstraints = false
            
            let constWrtieDoneIcon : [NSLayoutConstraint] = [
                NSLayoutConstraint(item: writeDoneIcon, attribute: .width, relatedBy: .equal, toItem: nil,
                                   attribute: .width, multiplier: 1, constant: 32),
                NSLayoutConstraint(item: writeDoneIcon, attribute: .height, relatedBy: .equal, toItem: nil,
                                   attribute: .height, multiplier: 1, constant: 32),
                NSLayoutConstraint(item: writeDoneIcon, attribute: .trailing, relatedBy: .equal, toItem: self.navigationController?.navigationBar, attribute: .trailing, multiplier: 1, constant: -8),
                NSLayoutConstraint(item: writeDoneIcon, attribute: .bottom, relatedBy: .equal, toItem: self.navigationController?.navigationBar, attribute: .bottom, multiplier: 1, constant: -8)]
            navigationController?.navigationBar.addSubview(writeDoneIcon)
            navigationController?.navigationBar.addConstraints(constWrtieDoneIcon)
            
            writeDoneIcon.image = UIImage(named: "checked")
            writeDoneIcon.layer.cornerRadius = 16
            writeDoneIcon.clipsToBounds = true
            let tapWriteDonIcon = UITapGestureRecognizer(target: self, action: #selector(writeDone))
            writeDoneIcon.addGestureRecognizer(tapWriteDonIcon)
            writeDoneIcon.isUserInteractionEnabled = true
        } else {
            writeDoneIcon.isHidden = true
        }
    }
    
    //MARK: SaveContents
    @objc fileprivate func writeDone() {
        
    }
}


//MARK: Notification keyboard
extension DrawingDiaryViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if keyboardShown == true {
            view.endEditing(true)
            keyboardShown = false
        }
    }
    
    @objc fileprivate func cleanTextView() {
        contents.text = ""
        contents.textColor = .black
    }
    
    @objc fileprivate func textViewState() {
        if contents.text == "" {
            contents.text = ""
            contents.textColor = UIColor(red: 208/255, green: 207/255, blue: 208/255, alpha: 1)
        }
    }
    fileprivate func registerForTextViewNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(cleanTextView),
                                               name: NSNotification.Name.UITextViewTextDidBeginEditing, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textViewState),
                                               name: NSNotification.Name.UITextViewTextDidEndEditing, object: nil)
    }
    
    fileprivate func unregisterForTextViewNotification() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidBeginEditing, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidEndEditing, object: nil)
    }
    
    fileprivate func registerForKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillshow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    fileprivate func unregisterForKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc fileprivate func keyboardWillshow(notification : Notification) {
        adjustHeight(notification: notification)
    }
    
    @objc fileprivate func keyboardWillHide(notification : Notification) {
        adjustHide(notification: notification)
    }
    
    fileprivate func adjustHeight(notification : Notification) {
        guard let userInfo = notification.userInfo else {return}
        let keyboardFrame : CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let keyboardHeight = contents.frame.size.height
        if keyboardFrame.height == 0 || keyboardShown {
            return
        } else {
            keyboardShown = true
            UITextView.animate(withDuration: 0.5) {
                self.contents.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
            }
        }
        }
    
    fileprivate func adjustHide(notification : Notification) {
        keyboardShown = false
        UITextView.animate(withDuration: 0.5) {
            self.contents.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }
    
    @objc fileprivate func textViewKeyboardAddToolBar() {
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
    
    @objc func pushDrawingView() {
        let drawingView = DrawingView()
        drawingView.sendDrawingImageDelegate = self
        if drawingImage.image == nil {
            self.navigationController?.pushViewController(drawingView, animated: true)
        }else {
           print("change image?")
        }
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
        let leftAlignGestureReconizer = UITapGestureRecognizer(target: self, action: #selector(alignLeft))
        leftAlignment.addGestureRecognizer(leftAlignGestureReconizer)
        leftAlignment.isUserInteractionEnabled = true
        
        centerAlignment.leadingAnchor.constraint(equalTo: leftAlignment.trailingAnchor, constant: 20).isActive = true
        centerAlignment.topAnchor.constraint(equalTo: viewBox.topAnchor, constant: 0).isActive = true
        centerAlignment.bottomAnchor.constraint(equalTo: viewBox.bottomAnchor, constant: 0).isActive = true
        centerAlignment.widthAnchor.constraint(equalToConstant: 26).isActive = true
        centerAlignment.image = UIImage(named: "center-align")
        centerAlignment.contentMode = .scaleAspectFit
        let centerAlignGestureReconizer = UITapGestureRecognizer(target: self, action: #selector(alignCenter))
        centerAlignment.addGestureRecognizer(centerAlignGestureReconizer)
        centerAlignment.isUserInteractionEnabled = true
        
        rightAlignment.leadingAnchor.constraint(equalTo: centerAlignment.trailingAnchor, constant: 20).isActive = true
        rightAlignment.topAnchor.constraint(equalTo: viewBox.topAnchor, constant: 0).isActive = true
        rightAlignment.bottomAnchor.constraint(equalTo: viewBox.bottomAnchor, constant: 0).isActive = true
        rightAlignment.widthAnchor.constraint(equalToConstant: 26).isActive = true
        rightAlignment.image = UIImage(named: "right-align")
        rightAlignment.contentMode = .scaleAspectFit
        let rightAlignGestureReconizer = UITapGestureRecognizer(target: self, action: #selector(alignRight))
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
        
        downArrow.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 6).isActive = true
        downArrow.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 6).isActive = true
        downArrow.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -6).isActive = true
        downArrow.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -6).isActive = true
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
    
    @objc fileprivate func alignLeft() {
        self.contents.textAlignment = .left
    }
    
    @objc fileprivate func alignCenter() {
        self.contents.textAlignment = .center
    }
    
    @objc fileprivate func alignRight() {
        self.contents.textAlignment = .right
    }
    
    @objc func weatherTextFieldReconiger() {
        weatherPicker = UIPickerView()
        weatherPicker.delegate = self
        weatherPicker.dataSource = self
        selectWeatherTextField.inputView = weatherPicker
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
//        let doneBtn = UIBarButtonItem(title: "완료", style: .plain, target: self,
//                                      action: #selector(changeWeather))
        let flexibleBtn = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width / 3, height: 36))
        label.text = "날씨 변경하기"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 14)
        
        let flexibleLB = UIBarButtonItem(customView: flexibleLabel)
        let labelBtn = UIBarButtonItem(customView: label)
        toolBar.setItems([flexibleLB,flexibleBtn,labelBtn,flexibleBtn,doneBtn], animated: true)
        toolBar.isTranslucent = true
        selectWeatherTextField.inputAccessoryView = toolBar
        selectWeatherTextField.becomeFirstResponder()
    }
    
    @objc func changeWeather() {
        selectWeatherTextField.resignFirstResponder()
    }
    //MARK: WeatherPickerview Delegate, Datasource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let number = pickerData.count
        return number
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedWeather = pickerData[row]
        changeWeatherIcon(weather: selectedWeather)
    }
    
    @objc fileprivate func touchUpInsideDateLabel(sender : UILabel) {
        let width = self.view.frame.size.width
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.minimumDate = stringToDate(in: "20170101", dateFormat: "yyyyMMdd")
        datePicker.maximumDate = stringToDate(in: "20251231", dateFormat: "yyyyMMdd")
        selectDateTextField.inputView = datePicker
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
        selectDateTextField.inputAccessoryView = toolBar
        selectDateTextField.becomeFirstResponder()
        //            datePicker.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
    }
    
    @objc fileprivate func changedDate(sender : UIBarButtonItem) {
        let date = datePicker.date
        let pickerDate = dateToString(in: date, dateFormat: "yyyy MM dd eee hh mm ss")
        let creationDate = stringToDate(in: pickerDate, dateFormat: "yyyy MM dd eee hh mm ss")
        let selectedDate = dateToString(in: date, dateFormat: "yyyy.MM.dd.eee")
        self.creationDate.text = selectedDate
        self.selectedDate = creationDate
        selectDateTextField.resignFirstResponder()
    }
    
    @objc fileprivate func dismissDatePciker(sender : UIBarButtonItem) {
        selectDateTextField.resignFirstResponder()
    }
}
