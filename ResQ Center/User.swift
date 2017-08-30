//
//  User.swift
//  ResQ Center
//
//  Created by Rajeé Jones on 8/29/17.
//  Copyright © 2017 rajeejones. All rights reserved.
//

import Foundation
import ObjectMapper
import ClusterKit

struct REQUser: Mappable {
    
    var name: String?
    var additional_comments: String?
    var address: String?
    var city: String?
    var created_date: Date?
    var facebook: String?
    var id: String?
    var latitude: Float?
    var location_comments: String?
    var longitude: Float?
    var number_people: Int?
    var number_pets: Int?
    var phone: String?
    var priority: String?
    var special_considerations: String?
    var state: String?
    var status: String?
    var twitter: String?
    var updated_date: Date?
    var zip: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        name <- map["name"]
        additional_comments <- map["additional_comments"]
        address <- map["address"]
        city <- map["city"]
        created_date <- (map["created_date"], DateTransform())
        facebook <- map["facebook"]
        id <- map["id"]
        latitude <- map["latitude"]
        location_comments <- map["location_comments"]
        longitude <- map["longitude"]
        number_people <- map["number_people"]
        number_pets <- map["number_pets"]
        phone <- map["phone"]
        priority <- map["priority"]
        special_considerations <- map["special_considerations"]
        state <- map["state"]
        status <- map["status"]
        twitter <- map["twitter"]
        updated_date <- (map["updated_date"], DateTransform())
        zip <- map["zip"]
    }
    
    func getCoordinates() -> CLLocationCoordinate2D? {
        if let lat = self.latitude, let long = self.longitude {
            return CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long))
        } else {
            return nil
        }
    }
}

class UserClusterItem: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var name: String!
    
    init(position: CLLocationCoordinate2D, name: String) {
        self.position = position
        self.name = name
    }
}

class UserAnnotation: NSObject, CKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var cluster: CKCluster?
    var user: REQUser!
    
    init(user:REQUser!) {
        self.user = user
        self.coordinate = user.getCoordinates()!
    }

}
