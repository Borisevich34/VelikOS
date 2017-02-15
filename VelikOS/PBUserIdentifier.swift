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

        if let oldFrame = PBPrevFrame.shared.frame {
            window?.setFrame(oldFrame, display: true)
        }
        
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
    
    
    @IBAction func rDone(_ sender: NSButton) {
        
        if rPassword.stringValue != rRepeatPass.stringValue {
            if let windowForSheet = window {
                runSheetAlert(messageText: "Repeated password is wrong", informativeText: "Please try to input password again", windowForSheet: windowForSheet)
            }
        }
        else {
            var properties = [String : String]()
            properties["name"] = rName.stringValue
            properties["password"] = rPassword.stringValue
            properties["email"] = rEmail.stringValue
            properties["platform"] = "osx"
        
            guard let fault = PBBackendlessAPI.shared.syncRegisterUserWithProperties(properties: properties) else {
                tabView.selectTabViewItem(at: 0)
                return
            }
            
            if let windowForSheet = window {
                runSheetAlert(messageText: "Registration error", informativeText: fault.message ?? "Please try again", windowForSheet: windowForSheet)
            }
        }
    }
    
    @IBAction func lDone(_ sender: NSButton) {
        
        guard let fault = PBBackendlessAPI.shared.syncLoginUser(email: lEmail.stringValue, password: lPassword.stringValue, isNeedToRemember: lCheck.state == 0 ? false : true) else {
            openMainMenu()
            return
        }
        
        if let windowForSheet = window {
            runSheetAlert(messageText: "Login error", informativeText: fault.message ?? "Please try again", windowForSheet: windowForSheet)
        }
        
    }
    
    private func runSheetAlert(messageText: String, informativeText: String, windowForSheet: NSWindow) {
        let alert = NSAlert()
        alert.messageText = messageText
        alert.informativeText = informativeText
        alert.addButton(withTitle: "OK")
        alert.beginSheetModal(for: windowForSheet, completionHandler: nil)
    }
    
    private func openMainMenu() {
        let controller = PBMainMenu(windowNibName: "MainMenu")
        
        PBPrevFrame.shared.frame = window?.frame
        controller.loadWindow()
        
        self.window?.isReleasedWhenClosed = true
        self.window?.close()
        self.window = nil
    }
}
