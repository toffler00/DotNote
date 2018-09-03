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
    struct Contents {
        var createdAt : Date?
        var title : String?
        var weather : String?
        var content : String?
        var image : Data?
    }
    struct User {
        var id : UUID?
        var contents : Model.Contents?
    }
}
