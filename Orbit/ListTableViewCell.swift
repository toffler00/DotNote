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
        
        // NSLayoutConstraint
        // date Label Constraints
        let dateLabelConstraints: [NSLayoutConstraint] = [
            NSLayoutConstraint(item: self.dateLabel, attribute: .top, relatedBy: .equal, toItem: self,
                               attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.dateLabel, attribute: .bottom, relatedBy: .equal, toItem: self,
                               attribute: .bottom ,multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.dateLabel, attribute: .leading, relatedBy: .equal, toItem: self,
                               attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.dateLabel, attribute: .width, relatedBy: .equal, toItem: self,
                               attribute: .width, multiplier: 0.15, constant: 0),
            NSLayoutConstraint(item: dateLabel, attribute: .height, relatedBy: .equal, toItem: nil,
                               attribute: .height, multiplier: 1, constant: 48)]
        
        self.addSubview(dateLabel)
        self.addConstraints(dateLabelConstraints)
        dateLabel.backgroundColor = .yellow
        
        
        // title label Constraints
        let titleLabelConstraints: [NSLayoutConstraint] = [
            NSLayoutConstraint(item: self.titleLabel, attribute: .top, relatedBy: .equal, toItem: self,
                               attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.titleLabel, attribute: .bottom, relatedBy: .equal, toItem: self,
                               attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.titleLabel, attribute: .leading, relatedBy: .equal, toItem: dateLabel,
                               attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.titleLabel, attribute: .width, relatedBy: .equal, toItem: self,
                               attribute: .width,multiplier: 0.70, constant: 0)]
        // 중앙 먼저
        self.addSubview(titleLabel)
        self.addConstraints(titleLabelConstraints)

        
        // week label Constraints
        let weekLabelConstraints: [NSLayoutConstraint] = [
            NSLayoutConstraint(item: self.weekLabel, attribute: .top, relatedBy: .equal, toItem: self,
                               attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.weekLabel, attribute: .bottom, relatedBy: .equal, toItem: self,
                               attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.weekLabel, attribute: .leading, relatedBy: .equal, toItem: titleLabel,
                               attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.weekLabel, attribute: .trailing, relatedBy: .equal, toItem: self,
                               attribute: .trailing, multiplier: 1, constant: 0)]

        self.addSubview(weekLabel)
        self.addConstraints(weekLabelConstraints)
        weekLabel.backgroundColor = .green
        
    }
}
