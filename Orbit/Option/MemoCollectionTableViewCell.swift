//
//  MemoCollectionTableViewCell.swift
//  Orbit
//
//  Created by ilhan won on 05/04/2019.
//  Copyright © 2019 orbit. All rights reserved.
//

import UIKit

class MemoCollectionTableViewCell: UITableViewCell {
    
    // MARK: propeties
    internal var dateLabel: UILabel = UILabel()
    internal var contents:  UITextView = UITextView()
    internal var contentType: UIImageView = UIImageView()
    internal var lineImageView : UIImageView = UIImageView()
    internal var trailingLineImageView : UIImageView = UIImageView()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
   
    
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
        self.contents.text = nil
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
extension MemoCollectionTableViewCell : UITextViewDelegate {
    // MARK: setUpLayout
    private func setUpLayout() {
        contentView.backgroundColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        
        // textAlignment
        self.dateLabel.textAlignment = .center
        self.contents.textAlignment = .left
        self.contentType.contentMode = .scaleAspectFit
        
        // translatesAutoresizingMaskIntoConstraints
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contents.translatesAutoresizingMaskIntoConstraints = false
        self.contentType.translatesAutoresizingMaskIntoConstraints = false
        self.lineImageView.translatesAutoresizingMaskIntoConstraints = false
        self.trailingLineImageView.translatesAutoresizingMaskIntoConstraints = false
        
        dateLabel.backgroundColor = .clear
        contents.backgroundColor = .clear
        contentType.backgroundColor = .clear
        lineImageView.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 0.8)
        trailingLineImageView.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 0.8)
        
        // Constraint value
        let leadingDistance = self.frame.size.width * 0.08
        
        // date Label Constraints
        let dateLabelConstraints: [NSLayoutConstraint] = [
            NSLayoutConstraint(item: self.dateLabel, attribute: .top, relatedBy: .equal, toItem: contentView,
                               attribute: .top, multiplier: 1, constant: 2),
            NSLayoutConstraint(item: self.dateLabel, attribute: .leading, relatedBy: .equal, toItem: contentView,
                               attribute: .leading, multiplier: 1, constant: leadingDistance * 1.2),
            //            NSLayoutConstraint(item: self.dateLabel, attribute: .width, relatedBy: .equal, toItem: self,
            //                               attribute: .width, multiplier: 0.15, constant: 0),
            NSLayoutConstraint(item: dateLabel, attribute: .height, relatedBy: .equal, toItem: nil,
                               attribute: .height, multiplier: 1, constant: 32)]
        
        contentView.addSubview(dateLabel)
        contentView.addConstraints(dateLabelConstraints)
        dateLabel.font = UIFont(name: "NanumBarunGothic", size: 14)
        dateLabel.textColor = .lightGray
        //            UIColor(red: 47/255, green: 36/255, blue: 34/255, alpha: 1)
        dateLabel.preferredMaxLayoutWidth = 150
        addBottomBorderLine(to: dateLabel, height: 0.5)
        
        // lineImageView Constraints
        let lineImageviewConst : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: lineImageView, attribute: .leading, relatedBy: .equal, toItem: contentView,
                               attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: lineImageView, attribute: .centerY, relatedBy: .equal, toItem: dateLabel,
                               attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: lineImageView, attribute: .width, relatedBy: .equal, toItem: nil,
                               attribute: .width, multiplier: 1, constant: leadingDistance),
            NSLayoutConstraint(item: lineImageView, attribute: .height, relatedBy: .equal, toItem: nil,
                               attribute: .height, multiplier: 1, constant: 1.5)]
        contentView.addSubview(lineImageView)
        contentView.addConstraints(lineImageviewConst)
        
        // week label Constraints
        let weekLabelConstraints: [NSLayoutConstraint] = [
            NSLayoutConstraint(item: contentType, attribute: .top, relatedBy: .equal, toItem: dateLabel,
                               attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contentType, attribute: .leading, relatedBy: .equal, toItem: dateLabel,
                               attribute: .trailing, multiplier: 1, constant: 1),
            NSLayoutConstraint(item: contentType, attribute: .height, relatedBy: .equal, toItem: nil,
                               attribute: .height, multiplier: 1, constant: 1),
            NSLayoutConstraint(item: contentType, attribute: .width, relatedBy: .equal, toItem: nil,
                               attribute: .height, multiplier: 1, constant: leadingDistance * 0.2)]
        
        contentView.addSubview(contentType)
        contentView.addConstraints(weekLabelConstraints)
        addBottomBorderLine(to: contentType, height: 1)
        
        // trailingLineImageView Constraints
        
        let trailngLineImageviewConst : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: trailingLineImageView, attribute: .leading, relatedBy: .equal, toItem: contentType,
                               attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: trailingLineImageView, attribute: .centerY, relatedBy: .equal, toItem: dateLabel,
                               attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: trailingLineImageView, attribute: .trailing, relatedBy: .equal, toItem: contentView,
                               attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: trailingLineImageView, attribute: .height, relatedBy: .equal, toItem: nil,
                               attribute: .height, multiplier: 1, constant: 1.5)]
        contentView.addSubview(trailingLineImageView)
        contentView.addConstraints(trailngLineImageviewConst)
        
        
        // title label Constraints
        let contentslConstraints: [NSLayoutConstraint] = [
            NSLayoutConstraint(item: self.contents, attribute: .top, relatedBy: .equal, toItem: dateLabel,
                               attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.contents, attribute: .bottom, relatedBy: .equal, toItem: contentView,
                               attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.contents, attribute: .leading, relatedBy: .equal, toItem: dateLabel,
                               attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.contents, attribute: .trailing, relatedBy: .equal, toItem: contentView,
                               attribute: .trailing,multiplier: 1, constant: -8)]
        // 중앙 먼저
        contentView.addSubview(contents)
        contentView.addConstraints(contentslConstraints)
        contents.font = UIFont(name: "NanumBarunGothic", size: 16)
        contents.isScrollEnabled = false
        contents.isEditable = false
        contents.sizeToFit()
        
    }
    
    func addBottomBorderLine(to view : UIView ,height : CGFloat) {
        let border = CALayer()
        border.frame = CGRect(x: 0, y: view.bounds.height - height,
                              width: view.bounds.width, height: height)
        border.backgroundColor = UIColor(red: 235 / 255, green: 235 / 255, blue: 235 / 255, alpha: 1).cgColor
        view.layer.addSublayer(border)
    }

    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame
    }
}
