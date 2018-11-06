//
//  PhotoCollectionViewCell.swift
//  Orbit
//
//  Created by David Koo on 01/09/2018.
//  Copyright © 2018 orbit. All rights reserved.
//

import UIKit
import Photos

class PhotoCollectionViewCell: UICollectionViewCell {
    
    fileprivate var imageView: UIImageView!
    var imageManager: PHCachingImageManager!
    var phAsset: PHAsset! {
        didSet {
            let synchronous = PHImageRequestOptions()
            synchronous.isSynchronous = false
            synchronous.isNetworkAccessAllowed = true
            
            imageManager.requestImage(for: phAsset, targetSize: frame.size, contentMode: .aspectFill, options: synchronous, resultHandler: {[weak self] image, _ in
                self?.imageView.image = image
                self?.imageView.clipsToBounds = true
            })
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageViewConsts = [
            NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: contentView,
                               attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: contentView,
                               attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: contentView,
                               attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: contentView,
                               attribute: .centerY, multiplier: 1, constant: 0)]
        
        addSubview(imageView)
        addConstraints(imageViewConsts)
        imageView.contentMode = .redraw
        
    }
    override func prepareForReuse() {
        imageView.image = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
