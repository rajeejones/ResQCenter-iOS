//
//  RequestsMapViewController.swift
//  ResQ Center
//
//  Created by Rajee Jones on 8/29/17.
//  Copyright © 2017 rajeejones. All rights reserved.
//

import UIKit
import GoogleMaps
import FirebaseDatabase
import ObjectMapper

class RequestsMapViewController: UIViewController {

    var ref: DatabaseReference!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Rescue"
        ref = Database.database().reference()
        
        if #available(iOS 11.0, *) {
            //self.navigationController?.navigationItem.largeTitleDisplayMode = .never
        } else {
            // Fallback on earlier versions
        }
        
        // Add loading sspinner
        createMapView()
    }
    
    
    func createMapView() {
        
        let currentAreaChild = ref.child("area")
        currentAreaChild.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                guard let snapshotData = snapshot.value as? [String: Any] else { return }
                if let area = Mapper<Area>().map(JSON: snapshotData), let lat = area.latitude, let long = area.longitude {
                    
                    self.mapView.camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long), zoom: 8.0)
                    self.getUserMarkers()
                }
                
            }
        })
    }
    
    func getUserMarkers() {

        ref.child("users").observeSingleEvent(of:.value, with: { (snapshot) in
            if snapshot.exists() {
                // for each child, get the lat/long to add a marker with the details
                guard let snapshotData = snapshot.value as? [String: AnyObject] else {
                    return
                }
                for childObject in snapshotData as [String: Any] {
                    let user = Mapper<REQUser>().map(JSON: childObject.value as! [String : Any])
                    self.addMarkerForUser(user)
                }
            }
        })
    }
    
    func addMarkerForUser(_ user: REQUser?) {
        guard let lat = user?.latitude, let long = user?.longitude else { return }
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long))
        marker.title = user?.name
        marker.snippet = user?.status
        marker.map = mapView
    }


}
