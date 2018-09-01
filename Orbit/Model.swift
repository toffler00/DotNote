//
//  Model.swift
//  Orbit
//
//  Created by ilhan won on 2018. 8. 30..
//  Copyright © 2018년 orbit. All rights reserved.
//

import UIKit

struct Model {}

extension Model {
    struct User {
        var id : String
        var createdAt : String
        var dayOfWeek : String
        var contentTitle : String
        var weather : String
    }
    
    struct contentsModel {
        var id : String
        var createAt : Date
        var contentTielt : String
        var weather : String
        var contents : String
        var contentImg : UIImage
        var dayOfWeek : String
    }
}

extension Model.contentsModel {
    
}
