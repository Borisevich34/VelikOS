//
//  AppDelegate.swift
//  VelikOS
//
//  Created by Pavel Borisevich on 14.02.17.
//  Copyright © 2017 Pavel Borisevich. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
        guard let isNeedToStayLogged = PBBackendlessAPI.shared.isNeedToStayLogged() else {
            return
        }
        if !isNeedToStayLogged {
            PBBackendlessAPI.shared.userLogout()
        }
    }
}

