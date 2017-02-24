//
//  PBPrevFrame.swift
//  VelikOS
//
//  Created by Pavel Borisevich on 14.02.17.
//  Copyright © 2017 Pavel Borisevich. All rights reserved.
//

import Cocoa

class PBAddCyclesHelper {
    
    static var shared = PBAddCyclesHelper()
    weak var table : NSTableView?
    var storeId : String?
    
    weak var window: NSWindow?
    
    var cycle : Cycle?
    
    public func openFromHelperWindow(sheetWindow: NSWindow) {
        window?.beginSheet(sheetWindow, completionHandler: nil)
    }
    
}

