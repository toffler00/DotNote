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
            //ToDo
            // 아니면 여기서 옵셔널 바인딩 하는 게 나은 걸까?
            self.dateLabel.text = self.didChangeString(forDate: model?.createdAt)
            self.titleLabel.text = model?.title
        }
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // UI
        self.setUpLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        // ToDo
    }
    
    // MARK: method
    func didChangeString(forDate date: Date?) -> String {
        // 여기서 Date?옵셔널로 설정해서 하느게 낫나?
        guard let date = date else { return "바꾸기 실패"}
        let dateFomatter = DateFormatter()
        dateFomatter.dateFormat = "yyyy년MM월dd일"
       return dateFomatter.string(from: date)
    }
}
// MARK: - extension ListTableViewCell
extension ListTableViewCell {
    // MARK: setUpLayout
    private func setUpLayout() {
        
        // textAlignment
        self.dateLabel.textAlignment = .center
        self.titleLabel.textAlignment = .center
        self.weekLabel.textAlignment = .center
        
        // numberOfLines
        self.titleLabel.numberOfLines = 0
        
        // translatesAutoresizingMaskIntoConstraints
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.weekLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // NSLayoutConstraint
        // title label Constraints
        let titleLabelConstraints: [NSLayoutConstraint] = [NSLayoutConstraint(item: self.titleLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),NSLayoutConstraint(item: self.titleLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0),NSLayoutConstraint(item: self.titleLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50),NSLayoutConstraint(item: self.titleLabel, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.55, constant: 0)]
        // 중앙 먼저
        self.addSubview(titleLabel)
        self.addConstraints(titleLabelConstraints)
        
        // date Label Constraints
        let dateLabelConstraints: [NSLayoutConstraint] = [NSLayoutConstraint(item: self.dateLabel, attribute: .centerX, relatedBy: .equal, toItem: self.titleLabel, attribute: .centerX, multiplier: 0.5, constant: 0),NSLayoutConstraint(item: self.dateLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0),NSLayoutConstraint(item: self.dateLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50),NSLayoutConstraint(item: self.dateLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 5),NSLayoutConstraint(item: self.dateLabel, attribute: .trailing, relatedBy: .equal, toItem: self.titleLabel, attribute: .leading, multiplier: 1, constant: 0),NSLayoutConstraint(item: self.dateLabel, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.25, constant: 0)]

        self.addSubview(dateLabel)
        self.addConstraints(dateLabelConstraints)

        // week label Constraints
        let weekLabelConstraints: [NSLayoutConstraint] = [NSLayoutConstraint(item: self.weekLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.5, constant: 0),NSLayoutConstraint(item: self.weekLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0),NSLayoutConstraint(item: self.weekLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50),NSLayoutConstraint(item: self.weekLabel, attribute: .leading, relatedBy: .equal, toItem: self.titleLabel, attribute: .trailing, multiplier: 1, constant: 0),NSLayoutConstraint(item: self.weekLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 5),NSLayoutConstraint(item: self.weekLabel, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.25, constant: 0)]
        
        self.addSubview(weekLabel)
        self.addConstraints(weekLabelConstraints)

    }
}
