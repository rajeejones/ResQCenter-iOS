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
import ClusterKit

let kClusterItemCount = 10000
var kCameraLatitude = -33.8
var kCameraLongitude = 151.2

class RequestsMapViewController: UIViewController {

    var ref: DatabaseReference!
    
    @IBOutlet weak var mapView: GMSMapView!
    var clusterManager: GMUClusterManager!
    var userAnnotations:[CKAnnotation] = [CKAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Rescue"
        ref = Database.database().reference()
        
        // Register self to listen to both GMUClusterManagerDelegate and GMSMapViewDelegate events.
//        clusterManager.setDelegate(self, mapDelegate: self)
        
        
        if #available(iOS 11.0, *) {
            //self.navigationController?.navigationItem.largeTitleDisplayMode = .never
        } else {
            // Fallback on earlier versions
        }
        
        // Add loading sspinner
        createMapView()
    }
    
    @IBAction func didTapMapType(_ sender: Any) {
        let actionSheet = UIAlertController(title: "", message: "Select Map Type:", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let normalMapTypeAction = UIAlertAction(title: "Normal", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            self.mapView.mapType = .normal
            
        }
        
        let terrainMapTypeAction = UIAlertAction(title: "Terrain", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            self.mapView.mapType = .terrain
            
        }
        
        let hybridMapTypeAction = UIAlertAction(title: "Hybrid", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            self.mapView.mapType = .hybrid
            
        }
        
        let cancelAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel) { (alertAction) -> Void in
            
        }
        
        actionSheet.addAction(normalMapTypeAction)
        actionSheet.addAction(terrainMapTypeAction)
        actionSheet.addAction(hybridMapTypeAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    func setupClusterManager() {
        // Set up the cluster manager with the supplied icon generator and
        // renderer.
//        let iconGenerator = GMUDefaultClusterIconGenerator()
        //let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        mapView.dataSource = self
        mapView.delegate = self
        mapView.settings.compassButton = true
        mapView.mapType = .normal
        
        let algorithm = CKGridBasedAlgorithm()
        algorithm.cellSize = 100
        mapView.clusterManager.algorithm = algorithm
        mapView.clusterManager.marginFactor = 1
        self.getUserMarkers()
    }
    
    /// Randomly generates cluster items within some extent of the camera and
    /// adds them to the cluster manager.
//    private func generateClusterItems() {
//        let extent = 0.2
//        for index in 1...kClusterItemCount {
//            let lat = kCameraLatitude + extent * randomScale()
//            let lng = kCameraLongitude + extent * randomScale()
//            let name = "Item \(index)"
//            let item =
//                UserClusterItem(position: CLLocationCoordinate2DMake(lat, lng), name: name)
//            clusterManager.add(item)
//        }
//    }
    
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
                    self.setupClusterManager()
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
                self.mapView.clusterManager.annotations = self.userAnnotations
                //self.mapView.clusterManager.addAnnotations(self.userAnnotations)
            }
        })
    }
    
    func addMarkerForUser(_ user: REQUser?) {
        guard let _ = user?.latitude, let _ = user?.longitude else { return }
//
//        let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long))
//        marker.title = user?.name
//        marker.snippet = user?.status
//        marker.map = mapView
        
        let annotation = UserAnnotation(user: user)
        userAnnotations.append(annotation)
    }


}

//class UserCKAnnotation: NSObject, CKAnnotation {
//    var cluster: CKCluster?
//    var coordinate: CLLocationCoordinate2D
//
//    init(cluster:CKCluster!, coordinate:CLLocationCoordinate2D!) {
//        self.cluster = cluster
//        self.coordinate = coordinate
//    }
//}

extension RequestsMapViewController: GMSMapViewDataSource, GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, markerFor cluster: CKCluster) -> GMSMarker {
        let marker = GMSMarker(position: cluster.coordinate)
        
        let customMarkerView = REQClusterMarkerImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        switch cluster.count {
        case 0,1:
            break
        case 2:
            customMarkerView.imageView.image = #imageLiteral(resourceName: "m1")
            customMarkerView.label.text = String(cluster.count)
            marker.iconView = customMarkerView
            
            break
        case 3:
            customMarkerView.imageView.image = #imageLiteral(resourceName: "m2")
            customMarkerView.label.text = String(cluster.count)
            marker.iconView = customMarkerView
            break
        case 4:
            customMarkerView.imageView.image = #imageLiteral(resourceName: "m3")
            customMarkerView.label.text = String(cluster.count)
            marker.iconView = customMarkerView
            break
        case 5:
            customMarkerView.imageView.image = #imageLiteral(resourceName: "m4")
            customMarkerView.label.text = String(cluster.count)
            marker.iconView = customMarkerView
            break
        default:
            customMarkerView.imageView.image = #imageLiteral(resourceName: "m5")
            customMarkerView.label.text = String(cluster.count)
            marker.iconView = customMarkerView
            break
        }
        
        if cluster.count <= 1 {
           //marker.icon = UIImage(named: "marker")
            if let customCluster = cluster.firstAnnotation as? UserAnnotation {
                marker.title = customCluster.user.name
                if customCluster.user.location_comments != "null" {
                    marker.snippet = customCluster.user.location_comments
                }
            }
            
            marker.isDraggable = true
        }
        
        return marker;
    }
    
    // MARK: How To Update Clusters
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        mapView.clusterManager.updateClustersIfNeeded()
    }
    
    // MARK: How To Handle Selection/Deselection
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        if let cluster = marker.cluster, cluster.count > 1 {
            
            let padding = UIEdgeInsetsMake(40, 20, 44, 20)
            let cameraUpdate = GMSCameraUpdate.fit(cluster, with: padding)
            mapView.animate(with: cameraUpdate)
            return true
        }
        return false
    }
    
    public func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
        if let annotation = marker.cluster?.firstAnnotation {
            mapView.clusterManager.selectAnnotation(annotation, animated: false)
        }
        return nil
    }
    
    func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
        
        if let annotation = marker.cluster?.firstAnnotation {
            mapView.clusterManager.deselectAnnotation(annotation, animated: false)
        }
    }
}


//extension RequestsMapViewController: GMUClusterManagerDelegate, GMSMapViewDelegate {
//    // MARK: - GMUClusterManagerDelegate
//
//    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
//        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
//                                                 zoom: mapView.camera.zoom + 1)
//        let update = GMSCameraUpdate.setCamera(newCamera)
//        mapView.moveCamera(update)
//        return false
//    }
//
//    // MARK: - GMUMapViewDelegate
//
//    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
//        if let poiItem = marker.userData as? UserClusterItem {
//            NSLog("Did tap marker for cluster item \(poiItem.name)")
//        } else {
//            NSLog("Did tap a normal marker")
//        }
//        return false
//    }
//}

