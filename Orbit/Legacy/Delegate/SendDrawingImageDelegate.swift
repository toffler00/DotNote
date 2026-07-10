//
//  SendDrawingImageDelegate.swift
//  Orbit
//
//  Created by ilhan won on 12/03/2019.
//  Copyright © 2019 orbit. All rights reserved.
//

import UIKit
import Photos
import NXDrawKit

extension DrawingDiaryViewController : SendDrawingImageDelegate {
    func sendDrawingImageDelegate(_ image: UIImage) {
        let pngImage = image.asPNGImage()
        self.drawingImage.image = pngImage
        self.drawingImageData = pngImage?.asPNGData()
    }
}
