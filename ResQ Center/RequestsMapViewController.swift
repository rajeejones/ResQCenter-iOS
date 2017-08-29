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
class RequestsMapViewController: UIViewController {

    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        print("View Did load Called")
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationItem.largeTitleDisplayMode = .never
        } else {
            // Fallback on earlier versions
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getUserMarkers() {
        
//        ref.child("users").observe(<#T##eventType: DataEventType##DataEventType#>, with: <#T##(DataSnapshot) -> Void#>)
//        
//        ref.observe(DataEventType.value) { (snapshot) in
//            let refDic = snapshot.value as? [String: AnyObject] ?? [:]
//            
//        }
    }
    
    override func loadView() {
        print("Load View Called")
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
