//
//  Area.swift
//  ResQ Center
//
//  Created by Rajeé Jones on 8/29/17.
//  Copyright © 2017 rajeejones. All rights reserved.
//

import Foundation
import ObjectMapper

struct Area: Mappable {
    
    var city: String?
    var latitude: Float?
    var longitude: Float?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        city <- map["city"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
    }
}
