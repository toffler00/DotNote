//
//  PhotosViewControllerDelegate.swift
//  Orbit
//
//  Created by ilhan won on 14/01/2019.
//  Copyright © 2019 orbit. All rights reserved.
//

import UIKit
import Photos
import RSKImageCropper

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

            guard let image = UIImage(data: imageData) else {return}
            let imageCropper = RSKImageCropViewController(image: image, cropMode: .custom)
            imageCropper.delegate = self
            imageCropper.dataSource = self
            self.present(imageCropper, animated: true, completion: nil)
        }
    }
    
    func photoLibraryAuthorizationStatus() {
        
        showAlertForImagePickerPermission()
        
    }
    
    func openSettings() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
    
    func showAlertForImagePickerPermission() {
        let title : String = "앨범접근권한이 없습니다. \n 설정에서 권한을 허용해야 합니다."
        showAlert(title: title,
                  message: "접근을 허용하면 Dot Note 가 사용자의 앨범에 있는 사진을 불러오고 저장할 수 있습니다. 허용하지 않는다면 일부 기능을 사용할 수 없습니다.",
                  actionStyle: .default,
                  cancelBtn: false,
                  buttonTitle: "승인",
                  onView: self) { (action) in
                    self.openSettings()
        }
    }
    
}


