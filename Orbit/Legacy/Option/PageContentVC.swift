//
//  PageContentVC.swift
//  Orbit
//
//  Created by ilhan won on 25/04/2019.
//  Copyright © 2019 orbit. All rights reserved.
//

import UIKit

class PageContentVC: UIViewController {
    
    @IBOutlet weak var tutorialImg: UIImageView!
    
    var index : Int!
    var imgName : String!
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        tutorialImg.contentMode = .scaleAspectFit
        tutorialImg.image = UIImage(named: imgName)
    }
    
    func setLayout() {
        tutorialImg.translatesAutoresizingMaskIntoConstraints = false

        tutorialImg.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        tutorialImg.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        tutorialImg.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        tutorialImg.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
