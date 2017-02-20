//
//  PBAddCycle.swift
//  VelikOS
//
//  Created by Pavel Borisevich on 20.02.17.
//  Copyright © 2017 Pavel Borisevich. All rights reserved.
//

import Foundation
import Cocoa

class PBAddCycles: NSWindowController {
    
    @IBOutlet weak var pricePerHour: NSTextField!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        if let unwrappedWindow = window {
            PBHelper.shared.openFromHelpWindow(sheetWindow: unwrappedWindow)
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func cancelPressed(_ sender: NSButton) {
        self.window?.isReleasedWhenClosed = true
        self.window?.close()
        self.window = nil
    }

}
