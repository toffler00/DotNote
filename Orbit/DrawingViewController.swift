//
//  DrawingViewController.swift
//  Orbit
//
//  Created by ilhan won on 24/01/2019.
//  Copyright © 2019 orbit. All rights reserved.
//

import UIKit
import Photos
import NXDrawKit
import RSKImageCropper
import AVFoundation
import MobileCoreServices

class DrawingViewController : UIViewController {
    
    var isImageLoadingFromiCloud: Bool = false
    var canvasView : Canvas!
    var paletteView : Palette!
    var toolBar : ToolBar!
    var bottomView : UIView!
    var selectedImage : UIImage?
    fileprivate var backButton : UIImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .automatic
        self.navigationItem.title = "Drawing"
        self.navigationItem.hidesBackButton = true
        setNavigationBackButton(onView: self, in: backButton, bool: true)
        addSubView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        setNavigationBackButton(onView: self, in: backButton, bool: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initialize()
    }
    
    private func initialize(){
        setupCanvasView()
    }
    
    override func viewWillLayoutSubviews() {
        
    }
    
    func addSubView() {
        
        canvasView = Canvas()
        canvasView?.translatesAutoresizingMaskIntoConstraints = false
        
        paletteView = Palette()
        paletteView?.translatesAutoresizingMaskIntoConstraints = false
        
        bottomView = UIView()
        bottomView?.translatesAutoresizingMaskIntoConstraints = false
        
        toolBar = ToolBar()
        toolBar?.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(canvasView)
        view.addSubview(paletteView)
        view.addSubview(bottomView)
        view.addSubview(toolBar)
    }
    
    func setupCanvasView() {
        let height = self.navigationController?.navigationBar.frame.size.height
        canvasView.topAnchor.constraint(equalTo: view.topAnchor, constant: height!).isActive = true
        canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        canvasView.heightAnchor.constraint(equalTo: view.widthAnchor, constant: 0).isActive = true
        
        canvasView.backgroundColor = .green
    }
}
