//
//  WriteDoneDelegate.swift
//  Orbit
//
//  Created by David Koo on 25/08/2018.
//  Copyright © 2018 orbit. All rights reserved.
//

import UIKit
import Photos

extension ListViewController: WriteDoneDelegate {
    func writeDone() {
        // MARK: - ToDo
        contentDate.removeAll()
        guard let contentDate = realmManager.objects(Content.self).value(forKey: "createdAt") as? [Date] else {return}
        for i in contentDate {
            let date = dateToString(in: i, dateFormat: "yyyyMMdd")
            self.contentDate.append(date)
        }
        calendarView.reloadData()
        print("writeDone")
    }
}

extension WriteViewController: PhotosViewControllerDelegate {
    func imageSelected(phAsset: PHAsset) {
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true
        
        options.progressHandler = {[weak self] (progress, error, _, _) in
            guard let `self` = self else { return }
            
            if !self.isImageLoadingFromiCloud {
                self.isImageLoadingFromiCloud = true
            }
            
            log.debug(progress)
            
        }
        
        PHImageManager().requestImageData(for: phAsset, options: options) { [weak self] (imageData, _, _, _) in
            guard let `self` = self else { return }
            guard let imageData = imageData else { return }
            
            self.selectedImageData = imageData
            self.contentImgV.contentMode = .scaleAspectFill
            self.contentImgV.image = UIImage(data: imageData)
            self.transformContentImgV(view: self.contentImgV)
        }
    }
}
