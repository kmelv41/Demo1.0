//
//  LocationModel.swift
//  Demo1.0
//
//  Created by User on 2016-08-13.
//  Copyright © 2016 Jolt. All rights reserved.
//

import Foundation

class LocationModel: NSObject {
    
    //properties
    
    var name: String?
    var address: String?
    var latitude: String?
    var longitude: String?
    var category: String?
    var city: String?
    
    
    //empty constructor
    
    override init()
    {
        
    }
    
    //construct with @name, @address, @latitude, and @longitude parameters
    
    init(name: String, address: String, latitude: String, longitude: String, category: String, city: String) {
        
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.category = category
        self.city = city
        
    }
    
    
    //prints object's current state
    
    override var description: String {
        return "Name: \(name), Address: \(address), Latitude: \(latitude), Longitude: \(longitude), Category: \(category), City: \(city)"
        
    }
    
    
}
