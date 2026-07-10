//
//  RealmManager.swift
//  Orbit
//
//  Created by ilhan won on 20/10/2018.
//  Copyright © 2018 orbit. All rights reserved.
//

import Foundation
import RealmSwift

class RealmManager {
    
    private init() {}
    static let shared = RealmManager()
    
    var realm = try! Realm()
    
    func creat(object : Object) {
        do {
            try realm.write {
                realm.add(object)
            }
        } catch {
            post(error: error)
        }
    }
    
    func update(object : Object, for dictionnary : [String : Any?]) {
        do {
            try realm.write {
                for (key, value) in dictionnary {
                    object.setValue(value, forKey: key)
                }
            }
        } catch  {
            post(error: error)
        }
    }
    
    func delete(object : Object) {
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch  {
            post(error: error)
        }
    }
    
    func deletedAll(object : Results<Content>) {
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch  {
            post(error: error)
        }
    }
    
    func arrayDate() -> [String] {
        let dates : [String] = []
        
        return dates
    }
    
    func post(error : Error) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RealmError"), object: error)
    }
    
    func observeRealmErrors(in vc : UIViewController, completion : @escaping (Error?) -> Void) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "RealmError"), object: nil, queue: nil) { (notification) in
            completion(notification.object as? Error)
        }
    }
}
