//
//  DBModel.swift
//  Orbit
//
//  Created by David Koo on 01/09/2018.
//  Copyright © 2018 orbit. All rights reserved.
//

import RealmSwift

class User: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var name: String = ""
    let contents: List<Content> = List<Content>()
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

class Content: Object {
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var createdAtMonth : String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var weather: String = ""
    @objc dynamic var body: String = ""
    @objc dynamic var image: Data? = nil
    
    convenience init(createdAt : Date, createdAtMonth : String, title : String, weather : String, body : String, image : Data) {
        self.init()
        self.createdAt = createdAt
        self.createdAtMonth = createdAtMonth
        self.title = title
        self.weather = weather
        self.body = body
        self.image = image
    }
    
}
