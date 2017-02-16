//
//  PBMainMenu.swift
//  VelikOS
//
//  Created by Pavel Borisevich on 14.02.17.
//  Copyright © 2017 Pavel Borisevich. All rights reserved.
//

import Cocoa
import MapKit

class PBMainMenu: NSWindowController {

    @IBOutlet weak var userName: NSTextField!
    @IBOutlet weak var mapView: MKMapView!
    var geopoint : GeoPoint?
    
    
    @IBOutlet weak var sLatitude: NSTextField!
    @IBOutlet weak var sLongitude: NSTextField!
    
    override func windowDidLoad() {
        super.windowDidLoad()

//        if let oldFrame = PBPrevFrame.shared.frame {
//            window?.setFrame(oldFrame, display: true)
//        }
    }
    
    func loadCustomElements() {
        
        if let user = PBBackendlessAPI.shared.currentUser() {
            userName.stringValue = user.name as String
            var fault : Fault? = nil
            _ = PBBackendlessAPI.shared.backendless?.persistenceService.load(user, relations: ["store", "store.geopoint"], error: &fault)
            if let userGeopoint = (user.getProperty("store") as? Store)?.geopoint {
                geopoint = userGeopoint
            }
            else {
                print(fault?.message ?? "Optional")
            }
        }
        
        guard let location = geopoint else {
            return
        }
        
        let annotation = MKPointAnnotation()
        annotation.title = "Your store location"
        annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude.doubleValue, longitude: location.longitude.doubleValue)
        
        mapView.showAnnotations([annotation], animated: true)
        mapView.selectAnnotation(annotation, animated: true)
        
        sLatitude.stringValue = location.latitude.stringValue
        sLongitude.stringValue = location.latitude.stringValue
    }
    
    @IBAction func userPressed(_ sender: NSButton) {

        PBBackendlessAPI.shared.userLogout()
        PBBackendlessAPI.shared.setNeedToStayLogged(needToStayLogged: false)
        
        let controller = PBUserIdentifier(windowNibName: "UserIdentifier")
        
        //PBPrevFrame.shared.frame = window?.frame
        
        controller.loadWindow()
        
        self.window?.isReleasedWhenClosed = true
        self.window?.close()
        self.window = nil
    }
}

extension PBMainMenu : MKMapViewDelegate {
    
}
