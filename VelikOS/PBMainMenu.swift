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
    
    //Store
    @IBOutlet weak var mapView: MKMapView!
    var geopoint : GeoPoint?
    var wrappedStore : Store?
    @IBOutlet weak var sLatitude: NSTextField!
    @IBOutlet weak var sLongitude: NSTextField!
    var sPrevStoreInformation: String?
    @IBOutlet weak var sStoreInformation: NSTextField!
    
    //Cycles
    let cCycles = NSMutableArray(objects: "Aist 1020", "Stels Black", "BMX-10")
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func loadCustomElements() {
        
        if let user = PBBackendlessAPI.shared.currentUser() {
            userName.stringValue = user.name as String
            wrappedStore = PBBackendlessAPI.shared.loadCurrentStore(userWithoutLoadedStore: user, relations: ["store", "store.geopoint"])
            if let storeGeopoint = wrappedStore?.geopoint {
                geopoint = storeGeopoint
            }
            if let info = (wrappedStore?.information as? String)?.trimmingCharacters(in: [" "]) {
                sStoreInformation.stringValue = info
                sPrevStoreInformation = info
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
    
    //MARK - Store methods
    @IBAction func sSetLocation(_ sender: Any) {

        if let store = wrappedStore {
            var theFault : Fault? = nil
            PBBackendlessAPI.shared.backendless?.geoService.remove(store.geopoint, error: &theFault)
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
            wrappedStore = PBBackendlessAPI.shared.backendless?.persistenceService.update(store, error: &fault) as? Store
            if wrappedStore == nil {
                retrieveCoordinates()
                runSheetAlert(messageText: "Location error", informativeText: (fault?.message ?? "Fault"))
            }
            else {
                geopoint = store.geopoint
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
        }
        else {
            let currentUser = PBBackendlessAPI.shared.currentUser()
            wrappedStore = PBBackendlessAPI.shared.loadCurrentStore(userWithoutLoadedStore: currentUser, relations: ["store", "store.geopoint"])
            runSheetAlert(messageText: "Please try again", informativeText: "Need to load some data")
            retrieveCoordinates()
        }
    }
    
    @IBAction func sChange(_ sender: Any) {
        if let store = wrappedStore {
            store.information = sStoreInformation.stringValue as NSString?
            var fault : Fault? = nil
            wrappedStore = PBBackendlessAPI.shared.backendless?.persistenceService.update(store, error: &fault) as? Store
            if wrappedStore == nil {
                runSheetAlert(messageText: "Setting information error", informativeText: fault?.message ?? "Setting information error")
                sStoreInformation.stringValue = sPrevStoreInformation ?? ""
            }
            else {
                sPrevStoreInformation = sStoreInformation.stringValue
            }
        }
        else {
            let currentUser = PBBackendlessAPI.shared.currentUser()
            wrappedStore = PBBackendlessAPI.shared.loadCurrentStore(userWithoutLoadedStore: currentUser, relations: ["store", "store.geopoint"])
            runSheetAlert(messageText: "Please try again", informativeText: "Need to load some data")
            sStoreInformation.stringValue = sPrevStoreInformation ?? ""
        }
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
    
    //Cycles
    @IBAction func cAdd(_ sender: NSButton) {
        if let unwrappedWindow = window {
            PBHelper.shared.window = unwrappedWindow
        }
        let controller = PBAddCycles(windowNibName: "AddCycles")
        controller.loadWindow()
    }
    
}

extension PBMainMenu : MKMapViewDelegate {
    
}

extension PBMainMenu : NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return cCycles.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var cellView: NSTableCellView? = nil
        if tableColumn?.identifier == "AutomaticTableColumnIdentifier.0" {
            cellView = tableView.make(withIdentifier: "Cycle", owner: self) as? NSTableCellView
            cellView?.textField?.stringValue = (cCycles.object(at: row) as? String) ?? "Cycle"
        }
        if tableColumn?.identifier == "AutomaticTableColumnIdentifier.1" {
            cellView = tableView.make(withIdentifier: "State", owner: self) as? NSTableCellView
        }
        return cellView
    }
}
