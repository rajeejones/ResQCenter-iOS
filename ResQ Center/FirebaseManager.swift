//
//  FirebaseManager.swift
//  ResQ Center
//
//  Created by Rajeé Jones on 8/29/17.
//  Copyright © 2017 rajeejones. All rights reserved.
//

import Foundation
import FirebaseAuth

class FirebaseManager {
    
    static func setup() {
        
        //This function will create new anonymous user or sign in if alrady created user for this installation
        Auth.auth().signInAnonymously { (anonymousUser:User?, error: Error?) in
            if error == nil && anonymousUser != nil {
                debugPrint("Anonymous user signed in")
            } else {
                debugPrint("Error signing anonymous user in")
                // TODO: Handle Failure
            }
        }
        
    }
    
    static func getCurrentUser() -> User? {
        return Auth.auth().currentUser
    }
}
