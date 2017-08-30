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

let kClusterItemCount = 10000
var kCameraLatitude = -33.8
var kCameraLongitude = 151.2

class RequestsMapViewController: UIViewController {

    var ref: DatabaseReference!
    
    @IBOutlet weak var mapView: GMSMapView!
    var clusterManager: GMUClusterManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Rescue"
        ref = Database.database().reference()
        
        // Register self to listen to both GMUClusterManagerDelegate and GMSMapViewDelegate events.
        clusterManager.setDelegate(self, mapDelegate: self)
        
        
        if #available(iOS 11.0, *) {
            //self.navigationController?.navigationItem.largeTitleDisplayMode = .never
        } else {
            // Fallback on earlier versions
        }
        
        // Add loading sspinner
        createMapView()
        setupClusterManager()
    }
    
    func setupClusterManager() {
        // Set up the cluster manager with the supplied icon generator and
        // renderer.
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView,
                                                 clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm,
                                           renderer: renderer)
        
        // Generate and add random items to the cluster manager.
        generateClusterItems()
        
        // Call cluster() after items have been added to perform the clustering
        // and rendering on map.
        clusterManager.cluster()
    }
    
    /// Randomly generates cluster items within some extent of the camera and
    /// adds them to the cluster manager.
    private func generateClusterItems() {
        let extent = 0.2
        for index in 1...kClusterItemCount {
            let lat = kCameraLatitude + extent * randomScale()
            let lng = kCameraLongitude + extent * randomScale()
            let name = "Item \(index)"
            let item =
                UserClusterItem(position: CLLocationCoordinate2DMake(lat, lng), name: name)
            clusterManager.add(item)
        }
    }
    
    /// Returns a random value between -1.0 and 1.0.
    private func randomScale() -> Double {
        return Double(arc4random()) / Double(UINT32_MAX) * 2.0 - 1.0
    }
    
    
    func createMapView() {
        
        let currentAreaChild = ref.child("area")
        currentAreaChild.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                guard let snapshotData = snapshot.value as? [String: Any] else { return }
                if let area = Mapper<Area>().map(JSON: snapshotData), let lat = area.latitude, let long = area.longitude {
                    
                    self.mapView.camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long), zoom: 8.0)
                    kCameraLatitude = Double(lat)
                    kCameraLongitude = Double(long)
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

extension RequestsMapViewController: GMUClusterManagerDelegate, GMSMapViewDelegate {
    // MARK: - GMUClusterManagerDelegate
    
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
                                                 zoom: mapView.camera.zoom + 1)
        let update = GMSCameraUpdate.setCamera(newCamera)
        mapView.moveCamera(update)
        return false
    }
    
    // MARK: - GMUMapViewDelegate
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let poiItem = marker.userData as? UserClusterItem {
            NSLog("Did tap marker for cluster item \(poiItem.name)")
        } else {
            NSLog("Did tap a normal marker")
        }
        return false
    }
}
