//
//  PageMasterVC.swift
//  Orbit
//
//  Created by ilhan won on 25/04/2019.
//  Copyright © 2019 orbit. All rights reserved.
//

import UIKit

class PageMasterVC: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
   
    @IBOutlet var masterView: UIView!
    
    let screenSize = UIScreen.main.bounds.height
    var closePage : UIImageView!
    var currentIdx : Int = 0
    var chooseIdx : Int = 0
    var pageImages : Array<String>!
    private var pageVC : UIPageViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        let screenSize = UIScreen.main.bounds.height
        self.masterView.backgroundColor = .white
        switch screenSize {
        case ...736:
            pageImages = ["tutorial5","tutorial6","tutorial7","tutorial8"]
        default:
            pageImages = ["tutorial1","tutorial2","tutorial3","tutorial4"]
        }
        pageImages = ["tutorial5","tutorial6","tutorial7","tutorial8"]
        pageVC = UIStoryboard(name: "TutorialPageView", bundle: nil).instantiateViewController(withIdentifier: "PageViewController") as? UIPageViewController
        pageVC.delegate = self
        pageVC.dataSource = self
       
        let startVC = self.viewControllerAtIndex(index: chooseIdx)
        let viewControllers = NSArray(object: startVC)
        
        pageVC.setViewControllers(viewControllers as? [UIViewController], direction: .forward, animated: true, completion: nil)
    
        self.addChild(pageVC)
        self.masterView.addSubview(pageVC.view)
        self.didMove(toParent: self)
    
        setLayout()
        // Do any additional setup after loading the view.
    }
    
    func viewControllerAtIndex(index : Int) -> PageContentVC {
        let vc = UIStoryboard(name: "TutorialPageView", bundle: nil).instantiateViewController(withIdentifier: "Content") as! PageContentVC
        vc.index = index
        vc.imgName = pageImages[index]
        return vc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let currentViewController = pageVC.viewControllers![0] as? PageContentVC {
                currentIdx = currentViewController.index
            }
        }
    }
    
    @objc func closeTutorial() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    //현재페이지의 이전 뷰를 미리 로드
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! PageContentVC
        var index = vc.index as Int
        
        if (index == 0 || index == NSNotFound) {
            return nil
        }
        index -= 1
        return viewControllerAtIndex(index: index)
    }
    
    //현재페이지의 다음 뷰를 미리 로드
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! PageContentVC
        var index = vc.index as Int
        
        if ( index == NSNotFound) {
            return nil
        }
        index += 1
        
        if (index == pageImages.count) {
            return nil
        }
        return viewControllerAtIndex(index: index)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pageImages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return chooseIdx
    }

    func setLayout() {
        
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        let const : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: pageVC.view, attribute: .top, relatedBy: .equal,
                               toItem: masterView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: pageVC.view, attribute: .leading, relatedBy: .equal,
                               toItem: masterView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: pageVC.view, attribute: .trailing, relatedBy: .equal,
                               toItem: masterView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: pageVC.view, attribute: .bottom, relatedBy: .equal,
                               toItem: masterView, attribute: .bottom, multiplier: 1, constant: 0)]
        
        pageVC.view.backgroundColor = .white
        self.masterView.addConstraints(const)
        
        closePage = UIImageView()
        self.masterView.addSubview(closePage)
        closePage.translatesAutoresizingMaskIntoConstraints = false
        
        switch screenSize {
        case ...736:
            closePage.trailingAnchor.constraint(equalTo: masterView.trailingAnchor, constant: -12).isActive = true
            closePage.bottomAnchor.constraint(equalTo: masterView.bottomAnchor, constant: -24).isActive = true
            closePage.widthAnchor.constraint(equalToConstant: 26).isActive = true
            closePage.heightAnchor.constraint(equalToConstant: 26).isActive = true
        default:
            closePage.trailingAnchor.constraint(equalTo: masterView.trailingAnchor, constant: -12).isActive = true
            closePage.bottomAnchor.constraint(equalTo: masterView.bottomAnchor, constant: -60).isActive = true
            closePage.widthAnchor.constraint(equalToConstant: 26).isActive = true
            closePage.heightAnchor.constraint(equalToConstant: 26).isActive = true
        }
        closePage.trailingAnchor.constraint(equalTo: masterView.trailingAnchor, constant: -16).isActive = true
        closePage.bottomAnchor.constraint(equalTo: masterView.bottomAnchor, constant: -24).isActive = true
        closePage.widthAnchor.constraint(equalToConstant: 26).isActive = true
        closePage.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        closePage.image = UIImage(named: "cancel")
        closePage.contentMode = .scaleAspectFit
        closePage.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(closeTutorial))
        closePage.addGestureRecognizer(gesture)
    }
}
