//
//  DrawingView.swift
//  Orbit
//
//  Created by ilhan won on 11/03/2019.
//  Copyright © 2019 orbit. All rights reserved.
//

import UIKit
import Photos
import NXDrawKit
import RSKImageCropper
import AVFoundation
import MobileCoreServices

protocol SendDrawingImageDelegate : class{
    func sendDrawingImageDelegate(_ image : UIImage)
}

class DrawingView : UIViewController, CanvasDelegate, PaletteDelegate{
    
    //MARK : Delegate
    weak var sendDrawingImageDelegate : SendDrawingImageDelegate!
    
    var canvasView: Canvas!
    var paletteView: Palette!
    var toolBar: ToolBar!
    var bottomView: UIView!
    var isImageLoadingFromiCloud: Bool = false
    var writeDoneIcon : UIImageView!
    var drawingImage : UIImage!
    
    fileprivate var backButton : UIImageView = UIImageView()
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .automatic
        self.navigationItem.title = "Drawing"
        self.navigationItem.hidesBackButton = true
        self.view.backgroundColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        initiallize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationBackButton(onView: self, in: backButton, bool: true)
        setUpWriteDoneIcon(bool: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        setNavigationBackButton(onView: self, in: backButton, bool: false)
        setUpWriteDoneIcon(bool: false)
    }
    
    private func initiallize() {
        self.setupCanvas()
        self.setupPalette()
        self.setupToolBar()
    }
    
    
    private func setupCanvas() {
        let height = self.navigationController?.navigationBar.bounds.height
        let window = UIApplication.shared.keyWindow
        let safePadding = window?.safeAreaInsets.top
        let heightPadding = CGFloat(height!) + CGFloat(safePadding!)
        
        canvasView = Canvas()
        canvasView?.delegate = self
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(canvasView)
        
        canvasView.backgroundColor = .white
        canvasView.topAnchor.constraint(equalTo: view.topAnchor, constant: heightPadding).isActive = true
        canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        canvasView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75).isActive = true
        canvasView.layer.borderWidth = 0.5
        canvasView.layer.borderColor = UIColor(red: 47/255, green: 36/255, blue: 34/255, alpha: 1).cgColor
    }
    
    private func setupPalette() {
        let window = UIApplication.shared.keyWindow
        let safePadding = window?.safeAreaInsets.top
        paletteView = Palette()
        paletteView.delegate = self
        paletteView.setup()
        view.addSubview(paletteView)
        paletteView.translatesAutoresizingMaskIntoConstraints = false
        
        let paletteHeight = paletteView.paletteHeight()
        paletteView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        paletteView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        paletteView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        paletteView.heightAnchor.constraint(equalToConstant: paletteHeight).isActive = true
        
        bottomView = UIView()
        view.addSubview(bottomView)
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.topAnchor.constraint(equalTo: paletteView.bottomAnchor, constant: 0).isActive = true
        bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        bottomView.heightAnchor.constraint(equalToConstant: safePadding!).isActive = true
    }
    
    private func setupToolBar() {
        toolBar = ToolBar()
        view.addSubview(toolBar)
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        
        toolBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        toolBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        toolBar.bottomAnchor.constraint(equalTo: paletteView.topAnchor, constant: 0).isActive = true
        toolBar.heightAnchor.constraint(equalTo: paletteView.heightAnchor, multiplier: 0.25).isActive = true
        
        toolBar.undoButton?.addTarget(self, action: #selector(self.onClickUndoButton), for: .touchUpInside)
        toolBar.redoButton?.addTarget(self, action: #selector(self.onClickRedoButton), for: .touchUpInside)
        toolBar.saveButton?.addTarget(self, action: #selector(self.onClickSaveButton), for: .touchUpInside)
        toolBar.saveButton?.setImage(UIImage(named: "share"), for: UIControl.State())
        toolBar.saveButton?.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        toolBar.loadButton?.addTarget(self, action: #selector(self.onClickLoadButton), for: .touchUpInside)
        toolBar.loadButton?.isEnabled = true
        toolBar.loadButton?.setImage(UIImage(named: "camera-white"), for: UIControl.State())
        toolBar.loadButton?.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        toolBar.clearButton?.addTarget(self, action: #selector(self.onClickClearButton), for: .touchUpInside)
        toolBar.clearButton?.setImage(UIImage(named: "refresh"), for: UIControl.State())
        toolBar.clearButton?.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    private func updateToolBarButtonStatus(_ canvas: Canvas) {
        self.toolBar?.undoButton?.isEnabled = canvas.canUndo()
        self.toolBar?.redoButton?.isEnabled = canvas.canRedo()
        self.toolBar?.saveButton?.isEnabled = canvas.canSave()
        self.toolBar?.clearButton?.isEnabled = canvas.canClear()
    }
    
    @objc func onClickUndoButton() {
        self.canvasView?.undo()
    }
    
    @objc func onClickRedoButton() {
        self.canvasView?.redo()
    }
    
    @objc func onClickLoadButton() {
        self.showActionSheetForPhotoSelection()
    }
    
    @objc func onClickSaveButton() {
        self.canvasView?.save()
    }
    
    @objc func onClickClearButton() {
        self.canvasView?.clear()
    }
    
    // MARK: - Image and Photo selection
    private func showActionSheetForPhotoSelection() {
        addImageGesture()
    }
    
    private func addImageGesture() {
        if !isImageLoadingFromiCloud {
            let photoViewController = PhotosViewController(nibName: nil, bundle: nil, photosViewControllerDelegate: self)
            self.navigationController?.pushViewController(photoViewController, animated: true)
        }
    }
    
}

//MARK : CanvasDelegate
extension DrawingView {
    func brush() -> Brush? {
        return self.paletteView?.currentBrush()
    }
    
    func canvas(_ canvas: Canvas, didUpdateDrawing drawing: Drawing, mergedImage image: UIImage?) {
        self.updateToolBarButtonStatus(canvas)
        if image != nil {
            drawingImage = image!
        }
    }
    
    func canvas(_ canvas: Canvas, didSaveDrawing drawing: Drawing, mergedImage image: UIImage?) {
        if let pngImage = image?.asPNGImage() {
            let activityViewController = UIActivityViewController(activityItems: [pngImage], applicationActivities: nil)
            activityViewController.completionWithItemsHandler =
                {(activityType: UIActivity.ActivityType?,
                    completed: Bool,
                    returnedItems: [Any]?, error: Error?) in
                    if !completed {
                        // User canceled
                        return
                    }
                    
                    if activityType == UIActivity.ActivityType.saveToCameraRoll {
                        let alert = UIAlertController(title: nil,
                                                      message: "앨범에 저장완료.",
                                                      preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "확인", style: .default))
                        self.present(alert, animated: true)
                    }
            }
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @objc func writeDone() {
        if drawingImage == nil {
            let message = "그려진 그림이 없습니다. \n 이전 화면으로 돌아갑니다."
            showAlert(title: nil, message: message, cancelBtn: true, buttonTitle: "승인", onView: self) { (action) in
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            sendDrawingImageDelegate.sendDrawingImageDelegate(drawingImage)
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
}

extension DrawingView : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        print(info)
    }
    
}


extension DrawingView : PhotosViewControllerDelegate , RSKImageCropViewControllerDelegate, RSKImageCropViewControllerDataSource {
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
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        self.canvasView?.update(croppedImage)
        controller.dismiss(animated: true, completion: nil)
    }
    
    func imageCropViewControllerCustomMaskRect(_ controller: RSKImageCropViewController) -> CGRect {
        let maskRect = self.canvasView.frame
        return maskRect
    }
    
    func imageCropViewControllerCustomMaskPath(_ controller: RSKImageCropViewController) -> UIBezierPath {
        let rect = controller.maskRect
        let point1 = CGPoint(x: rect.minX, y: rect.maxY)
        let point2 = CGPoint(x: rect.maxX, y: rect.maxY)
        let point3 = CGPoint(x: rect.maxX, y: rect.minY)
        let point4 = CGPoint(x: rect.minX, y: rect.minY)
        
        let rectangle = UIBezierPath()
        rectangle.move(to: point1)
        rectangle.addLine(to: point2)
        rectangle.addLine(to: point3)
        rectangle.addLine(to: point4)
        rectangle.close()
        return rectangle
    }
    
    func imageCropViewControllerCustomMovementRect(_ controller: RSKImageCropViewController) -> CGRect {
        let rect = controller.maskRect
        return rect
    }
    
    
}

extension DrawingView {
    func setUpWriteDoneIcon(bool : Bool) {
        if bool {
            //MARK: writeDoneIcon UIImageView
            writeDoneIcon = UIImageView()
            writeDoneIcon.translatesAutoresizingMaskIntoConstraints = false
            
            let constWrtieDoneIcon : [NSLayoutConstraint] = [
                NSLayoutConstraint(item: writeDoneIcon, attribute: .width, relatedBy: .equal, toItem: nil,
                                   attribute: .width, multiplier: 1, constant: 32),
                NSLayoutConstraint(item: writeDoneIcon, attribute: .height, relatedBy: .equal, toItem: nil,
                                   attribute: .height, multiplier: 1, constant: 32),
                NSLayoutConstraint(item: writeDoneIcon, attribute: .trailing, relatedBy: .equal, toItem: self.navigationController?.navigationBar, attribute: .trailing, multiplier: 1, constant: -8),
                NSLayoutConstraint(item: writeDoneIcon, attribute: .bottom, relatedBy: .equal, toItem: self.navigationController?.navigationBar, attribute: .bottom, multiplier: 1, constant: -8)]
            navigationController?.navigationBar.addSubview(writeDoneIcon)
            navigationController?.navigationBar.addConstraints(constWrtieDoneIcon)
            
            writeDoneIcon.image = UIImage(named: "checked")
            writeDoneIcon.layer.cornerRadius = 16
            writeDoneIcon.clipsToBounds = true
            let tapWriteDonIcon = UITapGestureRecognizer(target: self, action: #selector(writeDone))
            writeDoneIcon.addGestureRecognizer(tapWriteDonIcon)
            writeDoneIcon.isUserInteractionEnabled = true
        } else {
            writeDoneIcon.isHidden = true
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
