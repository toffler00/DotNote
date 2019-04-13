//
//  ListTableViewCell.swift
//  Orbit
//
//  Created by SSY on 2018. 8. 31..
//  Copyright © 2018년 orbit. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {
    
    // MARK: propeties
    internal var dateLabel: UILabel = UILabel()
    internal var titleLabel: UILabel = UILabel()
    internal var contentType: UIImageView = UIImageView()
    internal var lineImageView : UIImageView = UIImageView()
    internal var trailingLineImageView : UIImageView = UIImageView()
    
    // MARK: - Life Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // UI
        self.setUpLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.dateLabel.text = nil
        self.titleLabel.text = nil
        self.contentType.image = nil
    }
    
    // MARK: method
    private func didChangeString(forDate date: Date?) -> String {
        // 여기서 Date?옵셔널로 설정해서 하느게 낫나?
        guard let date = date else { return "바꾸기 실패"}
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        let calendarComponent = dateFormatter.calendar.component(.weekday, from: date) - 1
        dateFormatter.dateFormat = dateFormatter.weekdaySymbols[calendarComponent]
        dateFormatter.dateFormat = "MM월dd일"
        return dateFormatter.string(from: date)
    }
}
// MARK: - extension ListTableViewCell
extension ListTableViewCell {
    // MARK: setUpLayout
    private func setUpLayout() {
        contentView.backgroundColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        
        // textAlignment
        self.dateLabel.textAlignment = .center
        self.titleLabel.textAlignment = .left
        self.contentType.contentMode = .scaleAspectFit
        
        // numberOfLines
        self.titleLabel.numberOfLines = 0
        
        // translatesAutoresizingMaskIntoConstraints
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentType.translatesAutoresizingMaskIntoConstraints = false
        self.lineImageView.translatesAutoresizingMaskIntoConstraints = false
        self.trailingLineImageView.translatesAutoresizingMaskIntoConstraints = false
        
        dateLabel.backgroundColor = .clear
        titleLabel.backgroundColor = .clear
        contentType.backgroundColor = .clear
        lineImageView.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 0.8)
        trailingLineImageView.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 0.8)
        
        // Constraint value
        let leadingDistance = self.frame.size.width * 0.08
        
        // date Label Constraints
        let dateLabelConstraints: [NSLayoutConstraint] = [
            NSLayoutConstraint(item: self.dateLabel, attribute: .top, relatedBy: .equal, toItem: self,
                               attribute: .top, multiplier: 1, constant: 2),
            NSLayoutConstraint(item: self.dateLabel, attribute: .leading, relatedBy: .equal, toItem: self,
                               attribute: .leading, multiplier: 1, constant: leadingDistance * 1.2),
            //            NSLayoutConstraint(item: self.dateLabel, attribute: .width, relatedBy: .equal, toItem: self,
            //                               attribute: .width, multiplier: 0.15, constant: 0),
            NSLayoutConstraint(item: dateLabel, attribute: .height, relatedBy: .equal, toItem: contentView,
                               attribute: .height, multiplier: 0.3, constant: 0)]
        
        self.addSubview(dateLabel)
        self.addConstraints(dateLabelConstraints)
        dateLabel.font = UIFont(name: "NanumBarunGothic", size: 14)
        dateLabel.textColor = .lightGray
        //            UIColor(red: 47/255, green: 36/255, blue: 34/255, alpha: 1)
        dateLabel.preferredMaxLayoutWidth = 150
        
        // lineImageView Constraints
        let lineImageviewConst : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: lineImageView, attribute: .leading, relatedBy: .equal, toItem: self,
                               attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: lineImageView, attribute: .centerY, relatedBy: .equal, toItem: dateLabel,
                               attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: lineImageView, attribute: .width, relatedBy: .equal, toItem: nil,
                               attribute: .width, multiplier: 1, constant: leadingDistance),
            NSLayoutConstraint(item: lineImageView, attribute: .height, relatedBy: .equal, toItem: nil,
                               attribute: .height, multiplier: 1, constant: 1.5)]
        self.addSubview(lineImageView)
        self.addConstraints(lineImageviewConst)
        
        // week label Constraints
        let weekLabelConstraints: [NSLayoutConstraint] = [
            NSLayoutConstraint(item: contentType, attribute: .centerY, relatedBy: .equal, toItem: dateLabel,
                               attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contentType, attribute: .leading, relatedBy: .equal, toItem: dateLabel,
                               attribute: .trailing, multiplier: 1, constant: 8),
            NSLayoutConstraint(item: contentType, attribute: .width, relatedBy: .equal, toItem: nil,
                               attribute: .width, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: contentType, attribute: .height, relatedBy: .equal, toItem: nil,
                               attribute: .height, multiplier: 1, constant: 20)]
        
        self.addSubview(contentType)
        self.addConstraints(weekLabelConstraints)
        
        // trailingLineImageView Constraints
        let spacing = leadingDistance * 0.2
        let trailngLineImageviewConst : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: trailingLineImageView, attribute: .leading, relatedBy: .equal, toItem: contentType,
                               attribute: .trailing, multiplier: 1, constant: spacing),
            NSLayoutConstraint(item: trailingLineImageView, attribute: .centerY, relatedBy: .equal, toItem: dateLabel,
                               attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: trailingLineImageView, attribute: .trailing, relatedBy: .equal, toItem: self,
                               attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: trailingLineImageView, attribute: .height, relatedBy: .equal, toItem: nil,
                               attribute: .height, multiplier: 1, constant: 1.5)]
        self.addSubview(trailingLineImageView)
        self.addConstraints(trailngLineImageviewConst)
        
        
        // title label Constraints
        let titleLabelConstraints: [NSLayoutConstraint] = [
            NSLayoutConstraint(item: self.titleLabel, attribute: .top, relatedBy: .equal, toItem: dateLabel,
                               attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.titleLabel, attribute: .bottom, relatedBy: .equal, toItem: self,
                               attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.titleLabel, attribute: .leading, relatedBy: .equal, toItem: dateLabel,
                               attribute: .leading, multiplier: 1, constant: leadingDistance),
            NSLayoutConstraint(item: self.titleLabel, attribute: .trailing, relatedBy: .equal, toItem: self,
                               attribute: .trailing,multiplier: 1, constant: 0)]
        // 중앙 먼저
        self.addSubview(titleLabel)
        self.addConstraints(titleLabelConstraints)
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.adjustsFontSizeToFitWidth = false
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.font = UIFont(name: "NanumBarunGothic", size: 16)
        
        
    }
    
    func addBottomBorderLine(to view : UIView ,height : CGFloat) {
        let border = CALayer()
        border.frame = CGRect(x: 0, y: view.bounds.height - height,
                              width: view.bounds.width, height: height)
        border.backgroundColor = UIColor(red: 235 / 255, green: 235 / 255, blue: 235 / 255, alpha: 1).cgColor
        view.layer.addSublayer(border)
    }
}
