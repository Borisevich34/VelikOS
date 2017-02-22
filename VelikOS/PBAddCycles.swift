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
    
    @IBOutlet weak var firstImage: NSImageView!
    @IBOutlet weak var secondImage: NSImageView!
    @IBOutlet weak var thirdImage: NSImageView!
    
    @IBOutlet weak var name: NSTextField!
    @IBOutlet weak var pricePerHour: NSTextField!
    @IBOutlet weak var information: NSTextField!
    
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

    @IBAction func saveAllPressed(_ sender: NSButton) {
        
        //directory of images = store_objectId/cycle_objectId/
        let cycleName = name.stringValue.trimmingCharacters(in: [" "])
        if cycleName == "" {
            return
        }
        let info = information.stringValue.trimmingCharacters(in: [" "])
        if info == "" {
            return
        }
        guard let price = Double(pricePerHour.stringValue) else {
            return
        }
        
        
        let user = PBBackendlessAPI.shared.currentUser()
        guard let store = PBBackendlessAPI.shared.loadCurrentStore(user, relations: ["store", "store.geopoint", "store.cycles"]) else {
            return
        }
        
        let cycleNotCreated = Cycle(cycleName, info: info, price: price, firstUrl: nil, secondUrl: nil, thirdUrl: nil)
        var fault : Fault? = nil
        guard let cycleCreated = PBBackendlessAPI.shared.backendless?.persistenceService.create(cycleNotCreated, error: &fault) as? Cycle else {
            return
        }
        
        let path = "images/store_\((store.objectId ?? ""))/cycle_\((cycleCreated.objectId ?? ""))/"
        if let tiffData = firstImage.image?.tiffRepresentation {
            if let pngData = NSBitmapImageRep(data: tiffData)?.representation(using: .PNG, properties: [:]) {
                let pathToImage = path.appending("firstImage.png")
                _ = PBBackendlessAPI.shared.backendless?.fileService.upload(pathToImage, content: pngData, error: &fault)
                cycleCreated.firstImage = pathToImage as NSString
                
            }
        }
        if let tiffData = secondImage.image?.tiffRepresentation {
            if let pngData = NSBitmapImageRep(data: tiffData)?.representation(using: .PNG, properties: [:]) {
                let pathToImage = path.appending("secondImage.png")
                _ = PBBackendlessAPI.shared.backendless?.fileService.upload(pathToImage, content: pngData, error: &fault)
                cycleCreated.secondImage = pathToImage as NSString
            }
        }
        if let tiffData = thirdImage.image?.tiffRepresentation {
            if let pngData = NSBitmapImageRep(data: tiffData)?.representation(using: .PNG, properties: [:]) {
                let pathToImage = path.appending("thirdImage.png")
                _ = PBBackendlessAPI.shared.backendless?.fileService.upload(pathToImage, content: pngData, error: &fault)
                cycleCreated.thirdImage = pathToImage as NSString
            }
        }
        
        if store.cycles == nil {
            store.cycles = NSMutableArray(object: cycleCreated)
        }
        else {
            store.cycles?.add(cycleCreated)
        }
        
        fault = nil
        _ = PBBackendlessAPI.shared.backendless?.persistenceService.update(store, error: &fault)
        print(fault?.message ?? "Fault")
        print(fault?.faultCode ?? "Fault")
        
    }
}
