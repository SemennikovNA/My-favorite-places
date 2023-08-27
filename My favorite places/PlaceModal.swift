//
//  PlaceModal.swift
//  My favorite places
//
//  Created by Nikita on 23.08.2023.
//

import RealmSwift

class Place: Object {
    
    @objc dynamic var name: String = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var imageData = Data()
    @objc dynamic var date = Date()
    
    convenience init(name: String, location: String? = nil, type: String? = nil, imageData: Data = Data(), date: Date = Date()) {
        self.init()
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
        self.date = date
    }
    
}
