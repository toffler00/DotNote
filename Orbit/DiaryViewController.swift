//
//  DiaryViewController.swift
//  Orbit
//
//  Created by ilhan won on 2018. 8. 11..
//  Copyright © 2018년 orbit. All rights reserved.
//

import UIKit
import RealmSwift

class DiaryViewController: UIViewController {
   

    fileprivate var dateLabel : UILabel!
    fileprivate var dayOfWeek : UILabel!
    fileprivate var weatherImgV : UIImageView!
    fileprivate var titleLabel : UILabel!
    fileprivate var contents : UITextView!
    fileprivate var contentImgView : UIImageView!
    fileprivate var containerView : UIView!
    fileprivate var dateCollectionView : UICollectionView!
    var datasource : Model.Contents!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

//        writeButton.addTarget(self, action: #selector(pushWriteViewController), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillLayoutSubviews() {
       
             setupLayout()
             dataUpdate()
    }
    
}

////MARK: collectionView datasource
//extension DiaryViewController : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 10
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
//        cell.backgroundColor = .yellow
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 1
//    }
//}
extension DiaryViewController {
    fileprivate func setupLayout() {
        self.view.backgroundColor = .white
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.itemSize = CGSize(width: (self.view.frame.width / 7) - 1, height: 60)
//
//        dateCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
//        dateCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
//        dateCollectionView.dataSource = self
//        dateCollectionView.delegate = self
//
//        dateCollectionView.translatesAutoresizingMaskIntoConstraints = false
//
//        let constDateCV : [NSLayoutConstraint] = [NSLayoutConstraint(item: dateCollectionView, attribute: .top,
//                                                                     relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 0),
//                                                  NSLayoutConstraint(item: dateCollectionView, attribute: .leading,
//                                                                     relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .leading, multiplier: 1, constant: 0),
//                                                  NSLayoutConstraint(item: dateCollectionView, attribute: .trailing,
//                                                                     relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .trailing, multiplier: 1, constant: 0),
//                                                  NSLayoutConstraint(item: dateCollectionView, attribute: .height,
//                                                                     relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 63)]
//        view.addSubview(dateCollectionView)
//        view.addConstraints(constDateCV)
//        dateCollectionView.backgroundColor = .green
//
        
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
        containerView.backgroundColor = #colorLiteral(red: 0.5563425422, green: 0.9793455005, blue: 0, alpha: 1)
        
        weatherImgV = UIImageView()
        weatherImgV.translatesAutoresizingMaskIntoConstraints = false
        
        let consWeather : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: weatherImgV, attribute: .top, relatedBy: .equal, toItem: containerView
                , attribute: .top, multiplier: 1, constant: 8),
            NSLayoutConstraint(item: weatherImgV, attribute: .width, relatedBy: .equal, toItem: containerView,
                               attribute: .width, multiplier: 0.1, constant: 0),
            NSLayoutConstraint(item: weatherImgV, attribute: .height, relatedBy: .equal, toItem: weatherImgV,
                               attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: weatherImgV, attribute: .centerX, relatedBy: .equal, toItem: containerView,
                               attribute: .centerX, multiplier: 1, constant: 0)]
        
        containerView.addSubview(weatherImgV)
        containerView.addConstraints(consWeather)
        weatherImgV.backgroundColor = .white
        
        dayOfWeek = UILabel()
        dayOfWeek.translatesAutoresizingMaskIntoConstraints = false
        
        let consDayofWeek : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: dayOfWeek, attribute: .leading, relatedBy: .equal, toItem: containerView,
                               attribute: .leading, multiplier: 1, constant: 8),
            NSLayoutConstraint(item: dayOfWeek, attribute: .trailing, relatedBy: .equal, toItem: weatherImgV,
                               attribute: .leading, multiplier: 1, constant: -8),
            NSLayoutConstraint(item: dayOfWeek, attribute: .height, relatedBy: .equal, toItem: nil,
                               attribute: .height, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: dayOfWeek, attribute: .bottom, relatedBy: .equal, toItem: weatherImgV,
                               attribute: .bottom, multiplier: 1, constant: 0)]
        
        containerView.addSubview(dayOfWeek)
        containerView.addConstraints(consDayofWeek)
        dayOfWeek.backgroundColor = .white
        
        dateLabel = UILabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let consDateLabel : [NSLayoutConstraint] = [NSLayoutConstraint(item: dateLabel, attribute: .leading,
                                                                       relatedBy: .equal, toItem: weatherImgV, attribute: .trailing, multiplier: 1, constant: 8),
                                                    NSLayoutConstraint(item: dateLabel, attribute: .trailing,
                                                                       relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1, constant: -8),
                                                    NSLayoutConstraint(item: dateLabel, attribute: .height,
                                                                       relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 20),
                                                    NSLayoutConstraint(item: dateLabel, attribute: .bottom,
                                                                       relatedBy: .equal, toItem: weatherImgV, attribute: .bottom, multiplier: 1, constant: 0)]
        containerView.addSubview(dateLabel)
        containerView.addConstraints(consDateLabel)
        dateLabel.backgroundColor = .white
        
        contentImgView = UIImageView()
        contentImgView.translatesAutoresizingMaskIntoConstraints = false
        
        let consContentImgV : [NSLayoutConstraint] = [NSLayoutConstraint(item: contentImgView, attribute: .top,
                                                                         relatedBy: .equal, toItem: weatherImgV, attribute: .bottom, multiplier: 1, constant: 8),
                                                      NSLayoutConstraint(item: contentImgView, attribute: .width,
                                                                         relatedBy: .equal, toItem: containerView, attribute: .width, multiplier: 0.5, constant: 0),
                                                      NSLayoutConstraint(item: contentImgView, attribute: .height,
                                                                         relatedBy: .equal, toItem: containerView, attribute: .width, multiplier: 0.5, constant: 0),
                                                      NSLayoutConstraint(item: contentImgView, attribute: .centerX,
                                                                         relatedBy: .equal, toItem: containerView, attribute: .centerX, multiplier: 1, constant: 0)]
        containerView.addSubview(contentImgView)
        containerView.addConstraints(consContentImgV)
        contentImgView.backgroundColor = .white
        
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let consTitleLabel : [NSLayoutConstraint] = [NSLayoutConstraint(item: titleLabel, attribute: .top,
                                                                        relatedBy: .equal, toItem: contentImgView, attribute: .bottom, multiplier: 1, constant: 8),
                                                     NSLayoutConstraint(item: titleLabel, attribute: .leading,
                                                                        relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1, constant: 8),
                                                     NSLayoutConstraint(item: titleLabel, attribute: .trailing,
                                                                        relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1, constant: -8),
                                                     NSLayoutConstraint(item: titleLabel, attribute: .height,
                                                                        relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 30)]
        containerView.addSubview(titleLabel)
        containerView.addConstraints(consTitleLabel)
        titleLabel.backgroundColor = .white
        
        contents = UITextView()
        contents.translatesAutoresizingMaskIntoConstraints = false
        
        let consContents : [NSLayoutConstraint] = [NSLayoutConstraint(item: contents, attribute: .top,
                                                                      relatedBy: .equal, toItem: titleLabel, attribute: .bottom, multiplier: 1, constant: 0),
                                                   NSLayoutConstraint(item: contents, attribute: .leading,
                                                                      relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1, constant: 8),
                                                   NSLayoutConstraint(item: contents, attribute: .trailing,
                                                                      relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1, constant: -8),
                                                   NSLayoutConstraint(item: contents, attribute: .bottom,
                                                                      relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1, constant: 0)]
        containerView.addSubview(contents)
        containerView.addConstraints(consContents)
        contents.backgroundColor = .yellow
        contents.isEditable = false
    }
}

extension DiaryViewController {
    @objc fileprivate func pushWriteViewController() {
        let writeViewController = WriteViewController(delegate: self)
        navigationController?.pushViewController(writeViewController, animated: true)
    }
    
    func dataUpdate() {
        self.titleLabel.text = datasource.title
        self.contents.text = datasource.content
    }
}
