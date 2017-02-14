//
//  PBMainMenu.swift
//  VelikOS
//
//  Created by Pavel Borisevich on 14.02.17.
//  Copyright © 2017 Pavel Borisevich. All rights reserved.
//

import Cocoa

class PBMainMenu: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()

        if let oldFrame = PBPrevFrame.shared.frame {
            window?.setFrame(oldFrame, display: true)
        }
    }
    
    @IBAction func userPressed(_ sender: NSButton) {
        
        let controller = PBUserIdentifier(windowNibName: "UserIdentifier")
        
        PBPrevFrame.shared.frame = window?.frame
        
        controller.loadWindow()
        
        self.window?.isReleasedWhenClosed = true
        self.window?.close()
        self.window = nil
    }
    
}
