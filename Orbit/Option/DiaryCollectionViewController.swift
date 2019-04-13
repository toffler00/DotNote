//
//  DiaryCollectionViewController.swift
//  Orbit
//
//  Created by ilhan won on 17/03/2019.
//  Copyright © 2019 orbit. All rights reserved.
//

import UIKit
import RealmSwift

enum ContentsType : String {
    case diary = "diary"
    case drwaing = "drawing"
    case noneImg = "noneImg"
}

final class DiaryCollectionViewController : UIViewController {
    
    private var realmManager = RealmManager.shared.realm
    var datasourece : Results<Content>!
    var settingData : Results<Settings>!
    
    private var diaryCollection : UICollectionView!
    private var backButton : UIImageView = UIImageView()
    private var spacingView : UIView!
    private var spacingInnerView : UIView!
    
    override func viewDidLoad() {
        navigationController?.navigationBar.barTintColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.hidesBackButton = true
        navigationItem.title = "나의 일기"
        self.view.backgroundColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        datasourece = realmManager.objects(Content.self).sorted(byKeyPath: "createdAt", ascending: false).filter("type == 'drawing' OR type == 'diary'")
        print(datasourece)
        settingData = realmManager.objects(Settings.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationBackButton(onView: self, in: backButton, bool: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        setNavigationBackButton(onView: self, in: backButton, bool: false)
    }
    
    override func viewWillLayoutSubviews() {
        if diaryCollection == nil {
            setUpLayout()
        }
    }
    
    func setUpLayout() {
        let height = self.navigationController?.navigationBar.bounds.height
        let window = UIApplication.shared.keyWindow
        let safePadding = window?.safeAreaInsets.top
        let heightPadding = CGFloat(height!) + CGFloat(safePadding!)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
    
        spacingView = UIView()
        spacingView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(spacingView)
       
        spacingInnerView = UIView()
        spacingInnerView.translatesAutoresizingMaskIntoConstraints = false
        spacingView.addSubview(spacingInnerView)
        
        spacingView.topAnchor.constraint(equalTo: view.topAnchor, constant: heightPadding).isActive = true
        spacingView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        spacingView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        spacingView.heightAnchor.constraint(equalToConstant: 5).isActive = true
        
        spacingInnerView.topAnchor.constraint(equalTo: spacingView.topAnchor, constant: 0).isActive = true
        spacingInnerView.leadingAnchor.constraint(equalTo: spacingView.leadingAnchor, constant: 0).isActive = true
        spacingInnerView.trailingAnchor.constraint(equalTo: spacingView.trailingAnchor, constant: 0).isActive = true
        spacingInnerView.heightAnchor.constraint(equalToConstant: 5).isActive = true
        spacingInnerView.backgroundColor = #colorLiteral(red: 0.1843137255, green: 0.1411764706, blue: 0.1333333333, alpha: 0.199261582)
        
        diaryCollection = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        diaryCollection.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(diaryCollection)
        
        diaryCollection.topAnchor.constraint(equalTo: spacingView.bottomAnchor, constant: 0).isActive = true
        diaryCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        diaryCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        diaryCollection.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        diaryCollection.backgroundColor = .clear
        diaryCollection.allowsSelection = false
        
        diaryCollection.register(DiaryCollectionViewCell.self, forCellWithReuseIdentifier: "diaryCell")
        diaryCollection.register(DrawingDiaryCollectionViewCell.self, forCellWithReuseIdentifier: "drawingCell")
        diaryCollection.register(DiaryWithoutImageCell.self, forCellWithReuseIdentifier: "withoutImgCell")
        
        diaryCollection.dataSource = self
        diaryCollection.delegate = self
        
    }
}

extension DiaryCollectionViewController : UICollectionViewDelegateFlowLayout , UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = self.navigationController?.navigationBar.bounds.height
        let window = UIApplication.shared.keyWindow
        let safePadding = window?.safeAreaInsets.top
        let heightPadding = CGFloat(height!) + CGFloat(safePadding!)
        let itemWidth = self.view.bounds.width
        let itemHeight = self.view.bounds.height
        let itemSize = CGSize(width: itemWidth, height: itemHeight - heightPadding)
        return itemSize
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasourece.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = datasourece[indexPath.row]
        let type = data.type
        let contentImg = data.image
        let typeName = cellOfTheType(type: type, image: contentImg)
        
        switch typeName {
        case .diary :
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "diaryCell", for: indexPath)
                as! DiaryCollectionViewCell
            cell.titleLabel.text = data.title
            cell.contents.text = data.body
            cell.contents.textAlignment = contentsAlignment(alignment: data.contentsAlignment)
            cell.contents.font = applyFontSetting()
            if let imgData = data.image {
                cell.contentsImg.image = convertImageData(imgData)
            }
            cell.createdAtLabel.text = dateToString(in: data.createdAt, dateFormat: "yyyy.MM.dd eee")
            let weather = data.weather
            cell.weatherIcon.image = changeWeatherImg(weather: weather)
            return cell
        case .drwaing :
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "drawingCell", for: indexPath)
                as! DrawingDiaryCollectionViewCell
            cell.titleLabel.text = data.title
            cell.contents.text = data.body
            cell.contents.textAlignment = contentsAlignment(alignment: data.contentsAlignment)
            cell.contents.font = applyFontSetting()
            if let imgData = data.image {
                cell.contentsImg.image = convertImageData(imgData)
            }
            cell.createdAtLabel.text = dateToString(in: data.createdAt, dateFormat: "yyyy.MM.dd eee")
            let weather = data.weather
            cell.weatherIcon.image = changeWeatherImg(weather: weather)
            return cell
        case .noneImg :
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "withoutImgCell", for: indexPath)
                as! DiaryWithoutImageCell
            cell.titleLabel.text = data.title
            cell.contents.text = data.body
            cell.contents.textAlignment = contentsAlignment(alignment: data.contentsAlignment)
            cell.contents.font = applyFontSetting()
            if let imgData = data.image {
                cell.contentsImg.image = convertImageData(imgData)
            }
            cell.createdAtLabel.text = dateToString(in: data.createdAt, dateFormat: "yyyy.MM.dd eee")
            let weather = data.weather
            cell.weatherIcon.image = changeWeatherImg(weather: weather)
            return cell
        }
    }
    
    func convertImageData(_ data: Data) -> UIImage?{
        if let img = UIImage(data : data) {
            return img
        }
        return nil
    }
    
    func cellOfTheType(type : String, image : Data?) -> ContentsType {
        switch type {
        case "diary":
            if image == nil {
                return ContentsType.noneImg
            } else {
                return ContentsType.diary
            }
        default:
            return ContentsType.drwaing
        }
    }
    
    func changeWeatherImg(weather : String?) -> UIImage? {
        var image : UIImage?
        if let weather = weather {
            switch weather {
            case "맑음" :
                image = UIImage(named: "sun")
            case "안개" :
                image = UIImage(named: "haze")
            case "구름", "구름조금" :
                image = UIImage(named: "cloudy")
            case "이슬비" :
                image = UIImage(named: "hail")
            case "비" :
                image = UIImage(named: "rainy")
            case "눈","진눈깨비", "눈,비" :
                image = UIImage(named: "snow")
            case "천둥번개" :
                image = UIImage(named: "storm")
            default:
                image = nil
            }
        }
        return image
    }
    
    func contentsAlignment(alignment : String) -> NSTextAlignment {
        switch alignment {
        case "right":
            return NSTextAlignment.right
        case "left" :
            return NSTextAlignment.left
        case "center" :
            return NSTextAlignment.center
        default:
            return NSTextAlignment.left
        }
    }
    
    func applyFontSetting() -> UIFont {
        let fontName = settingData[0].contentsFont
        let fontSize = CGFloat(settingData[0].contentsFontSize)
        guard let font = UIFont(name: fontName, size: fontSize) else { return UIFont.systemFont(ofSize: 16) }
        return font
    }
    
}
