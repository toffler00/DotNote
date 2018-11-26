//
//  PhotosViewController.swift
//  Orbit
//
//  Created by David Koo on 01/09/2018.
//  Copyright © 2018 orbit. All rights reserved.
//

import UIKit
import Photos

protocol PhotosViewControllerDelegate: class {
    func imageSelected(phAsset: PHAsset)
}

class PhotosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    var backButton = UIImageView()
    var photosViewControllerDelegate: PhotosViewControllerDelegate!
    
    fileprivate let photoCollectionViewCellIdentifier: String = "PhotoCollectionViewCell"
    
    lazy var imageManager = PHCachingImageManager()
    var fetchResult: PHFetchResult<PHAsset>!
    
    var photoCollectionView: UICollectionView!
    
    init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil, photosViewControllerDelegate: PhotosViewControllerDelegate) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.photosViewControllerDelegate = photosViewControllerDelegate
        //        switch PHPhotoLibrary.authorizationStatus() {
        //        case .notDetermined:
        //        case .denied:
        //        case .authorized:
        //        case .restricted:
        //        }
        
        view.backgroundColor = .white
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        navigationItem.title = "나의 사진"
        navigationItem.hidesBackButton = true
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        options.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: false) ]
        options.includeAssetSourceTypes = [.typeUserLibrary, .typeiTunesSynced]
        
        fetchResult = PHAsset.fetchAssets(with: options)
    }
    override func viewWillAppear(_ animated: Bool) {
        setNavigationBackButton(onView: self, in: backButton, bool: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        setNavigationBackButton(onView: self, in: backButton, bool: false)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if photoCollectionView == nil {
            let photoCollectionViewLayout = UICollectionViewFlowLayout()
            photoCollectionViewLayout.scrollDirection = .vertical
            
            photoCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: photoCollectionViewLayout)
            photoCollectionView.translatesAutoresizingMaskIntoConstraints = false
            photoCollectionView.backgroundColor = .clear
            
            let photoCollectionViewConsts = [NSLayoutConstraint(item: photoCollectionView, attribute: .top, relatedBy: .equal,
                                                                toItem: view.safeAreaLayoutGuide,
                                                                attribute: .top, multiplier: 1, constant: 0),
                                             NSLayoutConstraint(item: photoCollectionView, attribute: .leading, relatedBy: .equal,
                                                                toItem: view.safeAreaLayoutGuide,
                                                                attribute: .leading, multiplier: 1, constant: 0),
                                             NSLayoutConstraint(item: photoCollectionView, attribute: .trailing, relatedBy: .equal,
                                                                toItem: view.safeAreaLayoutGuide,
                                                                attribute: .trailing, multiplier: 1, constant: 0),
                                             NSLayoutConstraint(item: photoCollectionView, attribute: .bottom, relatedBy: .equal,
                                                                toItem: view,
                                                                attribute: .bottom, multiplier: 1, constant: 0)]
            
            view.addSubview(photoCollectionView)
            view.addConstraints(photoCollectionViewConsts)
            
            photoCollectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: photoCollectionViewCellIdentifier)
            photoCollectionView.dataSource = self
            photoCollectionView.delegate = self
            
            PHPhotoLibrary.shared().register(self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCollectionViewCellIdentifier, for: indexPath) as? PhotoCollectionViewCell {
            
            cell.imageManager = imageManager
            cell.phAsset = fetchResult[indexPath.row]
            
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.width / 3 - 1
        return CGSize(width: size, height: size)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
