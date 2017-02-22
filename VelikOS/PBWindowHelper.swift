//
//  PBPrevFrame.swift
//  VelikOS
//
//  Created by Pavel Borisevich on 14.02.17.
//  Copyright © 2017 Pavel Borisevich. All rights reserved.
//

import Cocoa

class PBWindowHelper {
    
    static var shared = PBWindowHelper()
    weak var window: NSWindow?
    
    public func openFromHelpWindow(sheetWindow: NSWindow) {
        window?.beginSheet(sheetWindow, completionHandler: nil)
    }
    
}
