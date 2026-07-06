//
//  LegacyRealmModels.swift
//  Orbit
//
//  Minimal Realm object schema used only for importing the pre-rebuild database.
//

#if canImport(RealmSwift)
import Foundation
import RealmSwift

final class User: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var name: String = ""
    let contents: List<Content> = List<Content>()
    let settingData: List<Settings> = List<Settings>()

    override class func primaryKey() -> String? {
        "id"
    }
}

final class Content: Object {
    @objc dynamic var type: String = ""
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var createdAtMonth: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var weather: String = ""
    @objc dynamic var body: String = ""
    @objc dynamic var contentsAlignment: String = ""
    @objc dynamic var image: Data?
}

final class Settings: Object {
    @objc dynamic var naviTitleFont: String = ""
    @objc dynamic var contentTitleFont: String = ""
    @objc dynamic var contentsFont: String = ""
    @objc dynamic var contentsFontSize: Int = 0
    @objc dynamic var collectionFilter: Int = 0
}
#endif

