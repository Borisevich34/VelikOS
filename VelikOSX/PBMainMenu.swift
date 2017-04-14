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
    @IBOutlet weak var tableOfCycles: NSTableView!

    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func loadCustomElements() {
        
        if let user = PBBackendlessAPI.shared.currentUser() {
            
            userName.stringValue = user.name as String
            wrappedStore = PBBackendlessAPI.shared.loadCurrentStore(user, relations: ["store", "store.geopoint", "store.cycles"])
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
        annotation.title = "Your Store"
        annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude.doubleValue, longitude: location.longitude.doubleValue)
        
        mapView.showAnnotations([annotation], animated: true)
        mapView.selectAnnotation(annotation, animated: true)
        
        sLatitude.stringValue = location.latitude.stringValue
        sLongitude.stringValue = location.longitude.stringValue
        if let cycles = wrappedStore?.cycles {
            var fault : Fault?
            for cycle in cycles {
                fault = nil
                let unwrappedCycle = cycle as! Cycle
                unwrappedCycle.user = (PBBackendlessAPI.shared.backendless?.persistenceService.load(unwrappedCycle, relations: ["cycle.user"], error: &fault) as? Cycle)?.user
            }
            PBCyclesResponder.shared.cycles = cycles
            tableOfCycles.reloadData()
        }
        
        //MARK - Messaging subscribe
        guard let storeChannel = wrappedStore?.objectId as String? else {
            return
        }
        let subscriptionOptions = SubscriptionOptions()
        var fault : Fault? = nil
        PBCyclesResponder.shared.delegate = self
        PBCyclesResponder.shared.subscription = PBBackendlessAPI.shared.backendless?.messagingService.subscribe(storeChannel, subscriptionResponder: PBCyclesResponder.shared, subscriptionOptions: subscriptionOptions, error: &fault)
        print(fault?.message ?? "Success subscription for updates")
    }
    
    //MARK - cancel subscribe
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
                runSheetAlert(messageText: "Location error", informativeText: (fault?.message ?? "Location is not saved"))
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
            wrappedStore = PBBackendlessAPI.shared.loadCurrentStore(currentUser, relations: ["store", "store.geopoint"])
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
            wrappedStore = PBBackendlessAPI.shared.loadCurrentStore(currentUser, relations: ["store", "store.geopoint"])
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
        PBAddCyclesHelper.shared.cycle = nil
        PBAddCyclesHelper.shared.table = tableOfCycles
        //MARK - should be guard!
        if let unwrappedWindow = window {
            PBAddCyclesHelper.shared.window = unwrappedWindow
        }
        let controller = PBAddCycles(windowNibName: "AddCycles")
        controller.loadWindow()
    }
    
    @IBAction func saveChanges(_ sender: NSButton) {
        guard let user = PBBackendlessAPI.shared.currentUser(),
            let store = PBBackendlessAPI.shared.loadCurrentStore(user, relations:  ["store", "store.geopoint"])
            else { return }
        
        var fault : Fault? = nil
        let cycles = PBCyclesResponder.shared.cycles
        tableOfCycles.enumerateAvailableRowViews { (view, row) in
            if let cellState = view.view(atColumn: 1) as? PBCellState, let selectedIndex = cellState.comboBox?.indexOfSelectedItem {
                let cycle = cycles.object(at: row) as! Cycle
                let oldState = cycle.state
                cycle.state = NSNumber(value: selectedIndex)
                guard (PBBackendlessAPI.shared.backendless?.persistenceService.update(cycle, error: &fault)) != nil else {
                    cycle.state = oldState
                    store.cycles = cycles
                    tableOfCycles.reloadData()
                    runSheetAlert(messageText: "Save error", informativeText: fault?.message ?? "No fault")
                    return
                }
            }
        }
        store.cycles = cycles
        tableOfCycles.reloadData()
    }
    
    @IBAction func removeCycle(_ sender: NSButton) {
        let selectedRow = tableOfCycles.selectedRow
        if selectedRow != -1 {
            guard let user = PBBackendlessAPI.shared.currentUser(),
                let store = PBBackendlessAPI.shared.loadCurrentStore(user, relations:  ["store", "store.geopoint"])
                else { return }
            
            let cycles = PBCyclesResponder.shared.cycles
            let cycle = cycles.object(at: selectedRow) as! Cycle
            //MARK - needs alert before return in guard
            guard let cycleId = cycle.objectId, let storeId = store.objectId else { return }
            let path = "images/store_".appending(storeId as String).appendingFormat("/cycle_%@", cycleId as String)
            PBImagesHelper.removeImages(path)
            cycles.removeObject(at: selectedRow)
            store.cycles = cycles
            var fault : Fault? = nil
            _ = PBBackendlessAPI.shared.backendless?.persistenceService.remove(cycle, error: &fault)
            _ = PBBackendlessAPI.shared.backendless?.persistenceService.update(store, error: &fault)
            print(fault?.message ?? "No fault")
            tableOfCycles.reloadData()
        }
    }
    @IBAction func editCycleFromRow(_ sender: NSButton) {
        //MARK - needs alert before return in guard
        guard let user = PBBackendlessAPI.shared.currentUser(),
            let store = PBBackendlessAPI.shared.loadCurrentStore(user, relations:  ["store", "store.geopoint"]),
            let storeId = store.objectId as? String
            else { return }
        PBAddCyclesHelper.shared.storeId = storeId
        PBAddCyclesHelper.shared.table = tableOfCycles
        let selectedRow = tableOfCycles.selectedRow
        if selectedRow != -1 {
            let cycles = PBCyclesResponder.shared.cycles
            let cycle = cycles.object(at: selectedRow) as! Cycle
            if let unwrappedWindow = window {
                PBAddCyclesHelper.shared.cycle = cycle
                PBAddCyclesHelper.shared.window = unwrappedWindow
            }
            let controller = PBAddCycles(windowNibName: "AddCycles")
            controller.loadWindow()
        }
    }
    
}

extension PBMainMenu : MKMapViewDelegate {
    
}

extension PBMainMenu : NSTableViewDelegate, NSTableViewDataSource {
    
    //Cycles
    func numberOfRows(in tableView: NSTableView) -> Int {
        return PBCyclesResponder.shared.cycles.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let columnIdentifier = tableColumn?.identifier else {
            return nil
        }
        guard let cycle = PBCyclesResponder.shared.cycles.object(at: row) as? Cycle else {
            return nil
        }
        
        guard let name = cycle.name, let state = cycle.state?.intValue else {
            return nil
        }
        
        var columnView : NSView? = nil
        switch columnIdentifier {
        case "AutomaticTableColumnIdentifier.0":
            let cellView = tableView.make(withIdentifier: "Name", owner: self) as? PBCellName
            cellView?.label?.stringValue = name as String
            columnView = cellView
            break
        case "AutomaticTableColumnIdentifier.1":
            let cellView = tableView.make(withIdentifier: "State", owner: self) as? PBCellState
            cellView?.savedState = state
            cellView?.table = tableOfCycles
            cellView?.comboBox?.selectItem(at: state)
            cellView?.rowInTable = row
            columnView = cellView
            break
        case "AutomaticTableColumnIdentifier.2":
            let cellView = tableView.make(withIdentifier: "Period", owner: self) as? PBCellPeriod
            cellView?.label?.stringValue = (cycle.timePeriod as String?) ?? "---------------"
            columnView = cellView
            break
        case "AutomaticTableColumnIdentifier.3":
            let cellView = tableView.make(withIdentifier: "Order", owner: self) as? PBCellOrder
            cellView?.label?.stringValue = (cycle.orderTime as String?) ?? "--------"
            columnView = cellView
            break
        case "AutomaticTableColumnIdentifier.4":
            let cellView = tableView.make(withIdentifier: "User", owner: self) as? PBCellUser
            cellView?.label?.stringValue = (cycle.user?.email as String?) ?? "--------------------"
            columnView = cellView
            break
        case "AutomaticTableColumnIdentifier.5":
            let cellView = tableView.make(withIdentifier: "Saved", owner: self) as? PBCellSaved
            cellView?.isSaved = true
            columnView = cellView
            break
            
        default:
            break
        }
        return columnView
    }
}
