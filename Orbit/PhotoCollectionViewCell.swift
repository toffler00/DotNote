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
            })
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageViewConsts = [NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
                               NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
                               NSLayoutConstraint(item: imageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0),
                               NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)]
        
        addSubview(imageView)
        addConstraints(imageViewConsts)
        
    }
    override func prepareForReuse() {
        imageView.image = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
