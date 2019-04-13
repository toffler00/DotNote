//
//  PhotosViewControllerDelegate.swift
//  Orbit
//
//  Created by ilhan won on 14/01/2019.
//  Copyright © 2019 orbit. All rights reserved.
//

import UIKit
import Photos

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
    
    func photoLibraryAuthorizationStatus() {
        
        showAlertForImagePickerPermission()
        
    }
    
    func openSettings() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
    
    func showAlertForImagePickerPermission() {
        let message : String = "앨범접근권한이 없습니다. \n 설정에서 권한을 허용해야 합니다."
        showAlert(title: nil,
                  message: message,
                  actionStyle: .default,
                  cancelBtn: false,
                  buttonTitle: "승인",
                  onView: self) { (action) in
                    self.openSettings()
        }
    }
    
}


