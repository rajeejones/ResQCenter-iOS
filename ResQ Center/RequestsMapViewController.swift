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

        if #available(iOS 11.0, *) {
            //self.navigationController?.navigationItem.largeTitleDisplayMode = .never
        } else {
            // Fallback on earlier versions
        }
        
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

        let annotation = UserAnnotation(user: user)
        userAnnotations.append(annotation)
    }


}

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
