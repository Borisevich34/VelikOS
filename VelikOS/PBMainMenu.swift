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
    @IBOutlet weak var sStoreInformation: NSTextField!
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
        sLongitude.stringValue = location.longitude.stringValue
    }
    
    @IBAction func userPressed(_ sender: NSButton) {

        PBBackendlessAPI.shared.userLogout()
        PBBackendlessAPI.shared.setNeedToStayLogged(needToStayLogged: false)
        
        let controller = PBUserIdentifier(windowNibName: "UserIdentifier")
        controller.loadWindow()
        
        self.window?.isReleasedWhenClosed = true
        self.window?.close()
        self.window = nil
    }
    @IBAction func sSetLocation(_ sender: Any) {

        let currentUser = PBBackendlessAPI.shared.currentUser()
        if let store = PBBackendlessAPI.shared.loadCurrentStore(userWithoutLoadedStore: currentUser, relations: nil) { //["store", "store.geopoint"]
            print(sLatitude.stringValue)
            guard let latitude = Double(sLatitude.stringValue) else {
                runSheetAlert(messageText: "Location error", informativeText: "Location fields should be double")
                retrieveCoordinates()
                return
            }
            guard let longitude = Double(sLongitude.stringValue) else {
                runSheetAlert(messageText: "Location error", informativeText: "Location fields should be double")
                retrieveCoordinates()
                return
            }
            if !PBCheckGeolocation.shared.checkGeolocation(latitude: latitude, longitude: longitude) {
                runSheetAlert(messageText: "Location error", informativeText: "Your location isn't in availible area")
                retrieveCoordinates()
                return
            }
            
            var fault : Fault? = nil
            store.geopoint = GeoPoint(point: GEO_POINT(latitude: latitude, longitude: longitude), categories: ["Default"], metadata: ["store": store])
            if (PBBackendlessAPI.shared.backendless?.persistenceService.update(store, error: &fault)) == nil {
                retrieveCoordinates()
                runSheetAlert(messageText: "Location error", informativeText: (fault?.message ?? "Fault"))
            }
            else {
                geopoint = store.geopoint
            }
        }
    }
    
    @IBAction func sChange(_ sender: Any) {
    }

    private func runSheetAlert(messageText: String, informativeText: String) {
        if let windowForSheet = window {
            let alert = NSAlert()
            alert.messageText = messageText
            alert.informativeText = informativeText
            alert.addButton(withTitle: "OK")
            alert.beginSheetModal(for: windowForSheet, completionHandler: nil)
        }
    }
    
    private func retrieveCoordinates() {
        if let latitude : String = geopoint?.latitude.stringValue {
            sLatitude.stringValue = latitude
        }
        if let longitude : String = geopoint?.longitude.stringValue {
            sLongitude.stringValue = longitude
        }
    }
}

extension PBMainMenu : MKMapViewDelegate {
    
}
