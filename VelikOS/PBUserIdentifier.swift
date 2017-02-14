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
        let permission = true
        if permission {
            tabView.selectTabViewItem(at: 0)
        }
    }
    
    @IBAction func lDone(_ sender: NSButton) {
        
        let permission = true
        if permission {
            let controller = PBMainMenu(windowNibName: "MainMenu")
            
            PBPrevFrame.shared.frame = window?.frame
            controller.loadWindow()
            
            self.window?.isReleasedWhenClosed = true
            self.window?.close()
            self.window = nil
        }
    }
    

    
    
}
