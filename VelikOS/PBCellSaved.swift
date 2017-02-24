//
//  PBCellSaved.swift
//  VelikOS
//
//  Created by Pavel Borisevich on 22.02.17.
//  Copyright © 2017 Pavel Borisevich. All rights reserved.
//

import Cocoa

class PBCellSaved: NSTableCellView {

    var isSaved : Bool {
        get {
            if let string = label?.stringValue {
                return string == "Yes"
            }
            else {
                return true
            }
        }
        set {
            if newValue {
                label?.stringValue = "Yes"
                label?.textColor = colors.green
            }
            else {
                label?.stringValue = "No"
                label?.textColor = colors.red
                
            }
        }
    }
    var colors : (green : NSColor, red : NSColor) = (NSColor.green, NSColor.red)
    @IBOutlet weak var label: NSTextField?
    
}
