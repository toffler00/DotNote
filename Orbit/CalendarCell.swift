//
//  CalendarCell.swift
//  Orbit
//
//  Created by ilhan won on 10/10/2018.
//  Copyright © 2018 orbit. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarCell: JTAppleCell {
    var todayView : UIView = UIView()
    var isSelectedImg : UIImageView = UIImageView()
    var isContentsImg : UIImageView = UIImageView()
    var dateLabel : UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame : frame)
        setUpLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpLayout() {
        
        let border = CALayer()
        border.frame = CGRect(x: 0, y: contentView.frame.height - 0.5,
                              width: contentView.frame.width, height: 0.5)
        border.backgroundColor = UIColor(red: 235 / 255, green: 235 / 255, blue: 235 / 255, alpha: 1).cgColor
        contentView.layer.addSublayer(border)
        contentView.backgroundColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        
        todayView.translatesAutoresizingMaskIntoConstraints = false
        let constToday : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: todayView, attribute: .width, relatedBy: .equal, toItem: contentView,
                               attribute: .width, multiplier: 0.5, constant: 0),
            NSLayoutConstraint(item: todayView, attribute: .height, relatedBy: .equal, toItem: contentView,
                               attribute: .width, multiplier: 0.5, constant: 0),
            NSLayoutConstraint(item: todayView, attribute: .centerX, relatedBy: .equal, toItem: contentView,
                               attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: todayView, attribute: .centerY, relatedBy: .equal, toItem: contentView,
                               attribute: .centerY, multiplier: 1, constant: 0)]
        contentView.addSubview(todayView)
        contentView.addConstraints(constToday)
        
        todayView.layer.cornerRadius = contentView.frame.size.width / 4
        todayView.clipsToBounds = false
        todayView.backgroundColor = .lightGray
        todayView.isHidden = false
        
        isSelectedImg.translatesAutoresizingMaskIntoConstraints = false
        let constIsSelect : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: isSelectedImg, attribute: .width, relatedBy: .equal, toItem: contentView,
                               attribute: .width, multiplier: 0.5, constant: 0),
            NSLayoutConstraint(item: isSelectedImg, attribute: .height, relatedBy: .equal, toItem: contentView,
                               attribute: .width, multiplier: 0.5, constant: 0),
            NSLayoutConstraint(item: isSelectedImg, attribute: .centerX, relatedBy: .equal, toItem: contentView,
                               attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: isSelectedImg, attribute: .centerY, relatedBy: .equal, toItem: contentView,
                               attribute: .centerY, multiplier: 1, constant: 0)]
        contentView.addSubview(isSelectedImg)
        contentView.addConstraints(constIsSelect)
        isSelectedImg.layer.cornerRadius = contentView.frame.size.width / 4
        isSelectedImg.backgroundColor = UIColor(red: 47/255, green: 36/255, blue: 34/255, alpha: 1)
        isSelectedImg.isHidden = false
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        let constDateLB : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: dateLabel, attribute: .width, relatedBy: .equal, toItem: contentView,
                               attribute: .width, multiplier: 0.5, constant: 0),
            NSLayoutConstraint(item: dateLabel, attribute: .height, relatedBy: .equal, toItem: contentView,
                               attribute: .width, multiplier: 0.5, constant: 0),
            NSLayoutConstraint(item: dateLabel, attribute: .centerX, relatedBy: .equal, toItem: contentView,
                               attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: dateLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView,
                               attribute: .centerY, multiplier: 1, constant: 0)]
        contentView.addSubview(dateLabel)
        contentView.addConstraints(constDateLB)
        dateLabel.textAlignment = .center
        dateLabel.textColor = UIColor(red: 47/255, green: 36/255, blue: 34/255, alpha: 1)
        dateLabel.font = UIFont.boldSystemFont(ofSize: 14)
        dateLabel.backgroundColor = .clear
        
        isContentsImg.translatesAutoresizingMaskIntoConstraints = false
        let constIsContent : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: isContentsImg, attribute: .top, relatedBy: .equal, toItem: dateLabel,
                               attribute: .bottom, multiplier: 1, constant: 4),
            NSLayoutConstraint(item: isContentsImg, attribute: .width, relatedBy: .equal, toItem: dateLabel,
                               attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: isContentsImg, attribute: .height, relatedBy: .equal, toItem: nil,
                               attribute: .height, multiplier: 1, constant: 4),
            NSLayoutConstraint(item: isContentsImg, attribute: .centerX, relatedBy: .equal, toItem: contentView,
                               attribute: .centerX, multiplier: 1, constant: 0)]
        contentView.addSubview(isContentsImg)
        contentView.addConstraints(constIsContent)
        isContentsImg.backgroundColor = UIColor(red: 191/255, green: 1, blue: 0, alpha: 1)
    }
}
