//
//  FontSettingCell.swift
//  Orbit
//
//  Created by ilhan won on 18/04/2019.
//  Copyright © 2019 orbit. All rights reserved.
//

import UIKit


class FontSettingCell: UITableViewCell {

    var fontNameLabel : UILabel!
    var containerView : UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        fontNameLabel.text = nil
    }
    
    func setupLayout() {
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        fontNameLabel = UILabel()
        fontNameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(fontNameLabel)
        
        containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true
        containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0).isActive = true
        
        fontNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
        fontNameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0).isActive = true
        fontNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 9).isActive = true
        fontNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0).isActive = true
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
