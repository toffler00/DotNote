//
//  ListTableViewCell.swift
//  Orbit
//
//  Created by SSY on 2018. 8. 31..
//  Copyright © 2018년 orbit. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {
    internal var dateLabel: UILabel = UILabel()
    internal var titleLabel: UILabel = UILabel()
    internal var weekLabel: UILabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // UI
        self.setUpLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
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
        
        // test
//        self.titleLabel.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        
        // translatesAutoresizingMaskIntoConstraints
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.weekLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // NSLayoutConstraint
        
        // title label Constraints
        let titleLabelConstraints: [NSLayoutConstraint] = [NSLayoutConstraint(item: self.titleLabel, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0),NSLayoutConstraint(item: self.titleLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0),NSLayoutConstraint(item: self.titleLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50),NSLayoutConstraint(item: self.titleLabel, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: 0.5, constant: 0)]
        // 중앙 먼저
        self.contentView.addSubview(titleLabel)
        self.contentView.addConstraints(titleLabelConstraints)
        
        // date Label Constraints
        let dateLabelConstraints: [NSLayoutConstraint] = [NSLayoutConstraint(item: self.dateLabel, attribute: .centerX, relatedBy: .equal, toItem: self.titleLabel, attribute: .centerX, multiplier: 0.5, constant: 0),NSLayoutConstraint(item: self.dateLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0),NSLayoutConstraint(item: self.dateLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50),NSLayoutConstraint(item: self.dateLabel, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 10),NSLayoutConstraint(item: self.dateLabel, attribute: .trailing, relatedBy: .equal, toItem: self.titleLabel, attribute: .leading, multiplier: 1, constant: 0)]
        
        self.contentView.addSubview(dateLabel)
        self.contentView.addConstraints(dateLabelConstraints)
        
        // week label Constraints
        let weekLabelConstraints: [NSLayoutConstraint] = [NSLayoutConstraint(item: self.weekLabel, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.5, constant: 0),NSLayoutConstraint(item: self.weekLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0),NSLayoutConstraint(item: self.weekLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50),NSLayoutConstraint(item: self.weekLabel, attribute: .leading, relatedBy: .equal, toItem: self.titleLabel, attribute: .trailing, multiplier: 1, constant: 0),NSLayoutConstraint(item: self.weekLabel, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: 10)]
        
        self.contentView.addSubview(weekLabel)
        self.contentView.addConstraints(weekLabelConstraints)
    }
}
