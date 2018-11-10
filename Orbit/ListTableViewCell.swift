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
    internal var weekLabel: UILabel = UILabel()
    var model: Model.Contents? {
        didSet {
            // ToDo
            // 아니면 여기서 옵셔널 바인딩 하는 게 나은 걸까?
            self.dateLabel.text = self.didChangeString(forDate: model?.createdAt)
            self.titleLabel.text = model?.title
//            self.weekLabel.text = self.getWeekday(of: model?.createdAt)
        }
    }
    // MARK: - Life Cycle
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
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
        self.weekLabel.text = nil
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
    
//    private func getWeekday(of date: Date?) -> String {
//        guard let date = date else { return "바꾸기 실패"}
//        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale(identifier: "ko_KR")
//        let calendar = Calendar(identifier: .gregorian)
//        let calendarComponent = calendar.component(.weekday, from: date) - 1
//        dateFormatter.dateFormat = dateFormatter.weekdaySymbols[calendarComponent]
//        return dateFormatter.string(from: date)
//    }
}
// MARK: - extension ListTableViewCell
extension ListTableViewCell {
    // MARK: setUpLayout
    private func setUpLayout() {
        contentView.backgroundColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        
        // textAlignment
        self.dateLabel.textAlignment = .center
        self.titleLabel.textAlignment = .left
        self.weekLabel.textAlignment = .center
        
        // numberOfLines
        self.titleLabel.numberOfLines = 0
        
        // translatesAutoresizingMaskIntoConstraints
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.weekLabel.translatesAutoresizingMaskIntoConstraints = false
        
        dateLabel.backgroundColor = .clear
        titleLabel.backgroundColor = .clear
        weekLabel.backgroundColor = .clear
        
        // NSLayoutConstraint
        
        // week label Constraints
        let weekLabelConstraints: [NSLayoutConstraint] = [
            NSLayoutConstraint(item: weekLabel, attribute: .top, relatedBy: .equal, toItem: self,
                               attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: weekLabel, attribute: .leading, relatedBy: .equal, toItem: self,
                               attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: weekLabel, attribute: .width, relatedBy: .equal, toItem: self,
                               attribute: .width, multiplier: 0.15, constant: 0),
            NSLayoutConstraint(item: weekLabel, attribute: .height, relatedBy: .equal, toItem: self,
                               attribute: .height, multiplier: 0.3, constant: 0)]
        
        self.addSubview(weekLabel)
        self.addConstraints(weekLabelConstraints)
        weekLabel.backgroundColor = .clear
        print(weekLabel.frame.size.width)
        addBottomBorderLine(to: weekLabel, height: 1)
    
        // date Label Constraints
        let dateLabelConstraints: [NSLayoutConstraint] = [
            NSLayoutConstraint(item: self.dateLabel, attribute: .top, relatedBy: .equal, toItem: weekLabel,
                               attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.dateLabel, attribute: .bottom, relatedBy: .equal, toItem: self,
                               attribute: .bottom ,multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.dateLabel, attribute: .leading, relatedBy: .equal, toItem: self,
                               attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.dateLabel, attribute: .width, relatedBy: .equal, toItem: self,
                               attribute: .width, multiplier: 0.15, constant: 0),
            NSLayoutConstraint(item: dateLabel, attribute: .height, relatedBy: .equal, toItem: contentView,
                               attribute: .height, multiplier: 0.7, constant: 0)]
        
        self.addSubview(dateLabel)
        self.addConstraints(dateLabelConstraints)
        dateLabel.font = UIFont.boldSystemFont(ofSize: 28)
        dateLabel.textColor = UIColor(red: 47/255, green: 36/255, blue: 34/255, alpha: 1)
        addBottomBorderLine(to: dateLabel, height: 0.5)
        
        
        // title label Constraints
        let titleLabelConstraints: [NSLayoutConstraint] = [
            NSLayoutConstraint(item: self.titleLabel, attribute: .top, relatedBy: .equal, toItem: self,
                               attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.titleLabel, attribute: .bottom, relatedBy: .equal, toItem: self,
                               attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.titleLabel, attribute: .leading, relatedBy: .equal, toItem: dateLabel,
                               attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.titleLabel, attribute: .trailing, relatedBy: .equal, toItem: self,
                               attribute: .trailing,multiplier: 1, constant: 0)]
        // 중앙 먼저
        self.addSubview(titleLabel)
        self.addConstraints(titleLabelConstraints)
        
        
    }
    
    func addBottomBorderLine(to view : UIView ,height : CGFloat) {
        let border = CALayer()
        print(view.frame.width)
        border.frame = CGRect(x: 0, y: view.bounds.height - height,
                              width: view.bounds.width, height: height)
        border.backgroundColor = UIColor(red: 235 / 255, green: 235 / 255, blue: 235 / 255, alpha: 1).cgColor
        view.layer.addSublayer(border)
    }
}
