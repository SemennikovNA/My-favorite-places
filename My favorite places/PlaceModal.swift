//
//  PlaceModal.swift
//  My favorite places
//
//  Created by Nikita on 23.08.2023.
//

import Foundation


struct Place {
    
    var name: String
    var location: String
    var type: String
    var image: String
    
   static var listOfPlaces = [ "ЖК 'Alpamys'", "Mega Silk Way", "Zebra coffee", "Ботанический сад", "The Saint Regis Astana"]
    
   static func getPalces() -> [Place] {
        var places = [Place]()
        for place in listOfPlaces {
            places.append(Place(name: place, location: "Астана", type: "Избраное", image: place))
        }
        return places
    }
}
