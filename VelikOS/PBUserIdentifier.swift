//
//  UserIdentifier.swift
//  VelikOS
//
//  Created by Pavel Borisevich on 14.02.17.
//  Copyright © 2017 Pavel Borisevich. All rights reserved.
//

import Cocoa

class PBUserIdentifier: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()

        guard let isNeedToStayLogged = PBBackendlessAPI.shared.isNeedToStayLogged() else {
            return
        }
        if isNeedToStayLogged {
            openMainMenu()
        }
    }
    
    @IBOutlet weak var tabView: NSTabView!
    

    @IBOutlet weak var lEmail: NSTextField!
    @IBOutlet weak var lPassword: NSSecureTextField!
    @IBOutlet weak var lCheck: NSButton!
    
    @IBOutlet weak var rName: NSTextField!
    @IBOutlet weak var rEmail: NSTextField!
    @IBOutlet weak var rPassword: NSSecureTextField!
    @IBOutlet weak var rRepeatPass: NSSecureTextField!
    @IBOutlet weak var rLatitude: NSTextField!
    @IBOutlet weak var rLongitude: NSTextField!

    
    
    @IBAction func rDone(_ sender: NSButton) {
        
        guard let latitude = Double(rLatitude.stringValue) else {
            runSheetAlert(messageText: "Location error", informativeText: "Location fields should be double")
            return
        }
        guard let longitude = Double(rLongitude.stringValue) else {
            runSheetAlert(messageText: "Location error", informativeText: "Location fields should be double")
            return
        }
        if !PBCheckGeolocation.shared.checkGeolocation(latitude: latitude, longitude: longitude) {
            runSheetAlert(messageText: "Location error", informativeText: "Your location isn't in availible area")
            return
        }
        
        if rPassword.stringValue != rRepeatPass.stringValue {
            runSheetAlert(messageText: "Repeated password is wrong", informativeText: "Please try to input password again")
        }
        else {
            var properties = [String : Any]()
            properties["name"] = rName.stringValue
            properties["password"] = rPassword.stringValue
            properties["email"] = rEmail.stringValue
            properties["platform"] = "osx"
            properties["store"] = Store()
        
            guard let fault = PBBackendlessAPI.shared.syncRegisterUserWithProperties(properties, latitude: latitude, longitude: longitude) else {
                tabView.selectTabViewItem(at: 0)
                return
            }
            
            runSheetAlert(messageText: "Registration error", informativeText: fault.message ?? "Please try again")
        }
    }
    
    @IBAction func lDone(_ sender: NSButton) {
        
        guard let fault = PBBackendlessAPI.shared.syncLoginUser(email: lEmail.stringValue, password: lPassword.stringValue, isNeedToRemember: lCheck.state == 0 ? false : true) else {
            openMainMenu()
            return
        }
        
        runSheetAlert(messageText: "Login error", informativeText: fault.message ?? "Please try again")
        
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
    
    private func openMainMenu() {
        
        let controller = PBMainMenu(windowNibName: "MainMenu")
        controller.loadWindow()
        controller.loadCustomElements()
        
        self.window?.isReleasedWhenClosed = true
        self.window?.close()
        self.window = nil
    }
}
