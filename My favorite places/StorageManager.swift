//
//  StorageManager.swift
//  My favorite places
//
//  Created by Nikita on 26.08.2023.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveObject(place: Place) {
        try! realm.write {
            realm.add(place)
        }
    }
    
    static func deleteObject(place: Place) {
        try! realm.write {
            realm.delete(place)
        }
    }
    
}
