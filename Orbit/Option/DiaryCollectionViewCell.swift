//
//  DiaryCollectionViewCell.swift
//  Orbit
//
//  Created by ilhan won on 06/04/2019.
//  Copyright © 2019 orbit. All rights reserved.
//

import UIKit

class DiaryCollectionViewCell: UICollectionViewCell {
    
    var createAtContainerStackV : UIView!
    var createdAtLabel : UILabel!
    var weatherIcon : UIImageView!
    var leadingDistanceLine : UIImageView!
    var trailingDistanceLine : UIImageView!
    var titleLabel : UILabel!
    var contents : UITextView!
    var contentsImg : UIImageView!
    var contentType : String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        createdAtLabel.text = nil
        weatherIcon.image = nil
        titleLabel.text = nil
        contents.text = nil
        contentsImg.image = nil
    }
    
    func setUpLayout() {
        let widthBounds = contentView.frame.size.width
        
        createAtContainerStackV = UIView()
        createdAtLabel = UILabel()
        weatherIcon = UIImageView()
        leadingDistanceLine = UIImageView()
        trailingDistanceLine = UIImageView()
        titleLabel = UILabel()
        contents = UITextView()
        contentsImg = UIImageView()
        
        createAtContainerStackV.translatesAutoresizingMaskIntoConstraints = false
        createdAtLabel.translatesAutoresizingMaskIntoConstraints = false
        weatherIcon.translatesAutoresizingMaskIntoConstraints = false
        leadingDistanceLine.translatesAutoresizingMaskIntoConstraints = false
        trailingDistanceLine.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentsImg.translatesAutoresizingMaskIntoConstraints = false
        contents.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(createAtContainerStackV)
        createAtContainerStackV.addSubview(leadingDistanceLine)
        createAtContainerStackV.addSubview(createdAtLabel)
        createAtContainerStackV.addSubview(weatherIcon)
        createAtContainerStackV.addSubview(trailingDistanceLine)
        contentView.addSubview(titleLabel)
        contentView.addSubview(contentsImg)
        contentView.addSubview(contents)
       
        createAtContainerStackV.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        createAtContainerStackV.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true
        createAtContainerStackV.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0).isActive = true
        createAtContainerStackV.heightAnchor.constraint(equalToConstant: 32).isActive = true
        createAtContainerStackV.backgroundColor = .clear
        
        leadingDistanceLine.centerYAnchor.constraint(equalTo: createAtContainerStackV.centerYAnchor, constant: 0).isActive = true
        leadingDistanceLine.leadingAnchor.constraint(equalTo: createAtContainerStackV.leadingAnchor, constant: 0).isActive = true
        leadingDistanceLine.widthAnchor.constraint(equalToConstant: widthBounds * 0.1).isActive = true
        leadingDistanceLine.heightAnchor.constraint(equalToConstant: 1.2).isActive = true
        leadingDistanceLine.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 0.8)
        
        createdAtLabel.centerYAnchor.constraint(equalTo: createAtContainerStackV.centerYAnchor, constant: 0).isActive = true
        createdAtLabel.leadingAnchor.constraint(equalTo: leadingDistanceLine.trailingAnchor, constant: 4).isActive = true
        createdAtLabel.heightAnchor.constraint(equalToConstant: 32).isActive = true
        createdAtLabel.backgroundColor = .clear
        createdAtLabel.preferredMaxLayoutWidth = 150
        
        weatherIcon.centerYAnchor.constraint(equalTo: createdAtLabel.centerYAnchor, constant: 0).isActive = true
        weatherIcon.leadingAnchor.constraint(equalTo: createdAtLabel.trailingAnchor, constant: 4).isActive = true
        weatherIcon.widthAnchor.constraint(equalToConstant: 26).isActive = true
        weatherIcon.heightAnchor.constraint(equalToConstant: 26).isActive = true
        weatherIcon.backgroundColor = .clear
        
        trailingDistanceLine.centerYAnchor.constraint(equalTo: leadingDistanceLine.centerYAnchor, constant: 0).isActive = true
        trailingDistanceLine.leadingAnchor.constraint(equalTo: weatherIcon.trailingAnchor, constant: 4).isActive = true
        trailingDistanceLine.trailingAnchor.constraint(equalTo: createAtContainerStackV.trailingAnchor, constant: 0).isActive = true
        trailingDistanceLine.heightAnchor.constraint(equalToConstant: 1.2).isActive = true
        trailingDistanceLine.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 0.8)
        
        titleLabel.leadingAnchor.constraint(equalTo: leadingDistanceLine.centerXAnchor, constant: 0).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        titleLabel.topAnchor.constraint(equalTo: createAtContainerStackV.bottomAnchor, constant: 2).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 28).isActive = true
        titleLabel.backgroundColor = .clear
        
        contentsImg.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0).isActive = true
        contentsImg.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0).isActive = true
        contentsImg.widthAnchor.constraint(equalToConstant: widthBounds).isActive = true
        contentsImg.heightAnchor.constraint(equalToConstant: widthBounds * 0.75).isActive = true
        contentsImg.backgroundColor = .clear
        contentsImg.contentMode = .scaleAspectFill
        contentsImg.clipsToBounds = true
        
        
        contents.topAnchor.constraint(equalTo: contentsImg.bottomAnchor, constant: 4).isActive = true
        contents.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4).isActive = true
        contents.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4).isActive = true
        contents.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        contents.backgroundColor = UIColor(red: 246/255, green: 252/255, blue: 226/255, alpha: 1)
        contents.isEditable = false
    }
}
