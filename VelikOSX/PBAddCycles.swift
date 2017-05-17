//
//  PBAddCycle.swift
//  VelikOSX
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
        
        if let cycle = PBAddCyclesHelper.shared.cycle {
            let images : [Int : NSImage?] = PBImagesHelper.downloadImagesOfCycle(cycle)
            
            if let firstImageFromDictionary = images[0] {
                firstImage.image = firstImageFromDictionary
            }
            if let secondImageFromDictionary = images[1] {
                firstImage.image = secondImageFromDictionary
            }
            if let thirdImageFromDictionary = images[2] {
                firstImage.image = thirdImageFromDictionary
            }
            if let info = cycle.information as String? {
                information.stringValue = info
            }
            if let price = cycle.pricePerHour?.stringValue {
                pricePerHour.stringValue = price
            }
            if let cycleName = cycle.name as String? {
                name.stringValue = cycleName
            }
        }
        if let unwrappedWindow = window {
            PBAddCyclesHelper.shared.openFromHelperWindow(sheetWindow: unwrappedWindow)
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
        
        if let cycle = PBAddCyclesHelper.shared.cycle {
            if let cycleId = cycle.objectId as String?, let storeId = PBAddCyclesHelper.shared.storeId {
                let directoryPath = "images/store_".appending(storeId).appendingFormat("/cycle_%@", cycleId)
                PBImagesHelper.removeImages(directoryPath)
                
                let cycleName = name.stringValue.trimmingCharacters(in: [" "])
                let info = information.stringValue.trimmingCharacters(in: [" "])
                if cycleName == "" || info == "" {
                    return
                }
                guard let price = Double(pricePerHour.stringValue) else {
                    return
                }
                cycle.name = cycleName as NSString
                cycle.information = info as NSString
                cycle.pricePerHour = NSNumber(value: price)
                
                var fault : Fault? = nil
                if let tiffData = firstImage.image?.tiffRepresentation {
                    if let pngData = NSBitmapImageRep(data: tiffData)?.representation(using: .PNG, properties: [:]) {
                        let pathToImage = directoryPath.appending("/firstImage.png")
                        _ = PBBackendlessAPI.shared.backendless?.fileService.upload(pathToImage, content: pngData, error: &fault)
                    }
                }
                if let tiffData = secondImage.image?.tiffRepresentation {
                    if let pngData = NSBitmapImageRep(data: tiffData)?.representation(using: .PNG, properties: [:]) {
                        let pathToImage = directoryPath.appending("/secondImage.png")
                        _ = PBBackendlessAPI.shared.backendless?.fileService.upload(pathToImage, content: pngData, error: &fault)
                    }
                }
                if let tiffData = thirdImage.image?.tiffRepresentation {
                    if let pngData = NSBitmapImageRep(data: tiffData)?.representation(using: .PNG, properties: [:]) {
                        let pathToImage = directoryPath.appending("/thirdImage.png")
                        _ = PBBackendlessAPI.shared.backendless?.fileService.upload(pathToImage, content: pngData, error: &fault)
                    }
                }
                _ = PBBackendlessAPI.shared.backendless?.persistenceService.update(cycle, error: &fault)
            }
        }
        else {
            addNewCycle()
        }
        
        PBAddCyclesHelper.shared.table?.reloadData()
        
        self.window?.isReleasedWhenClosed = true
        self.window?.close()
        self.window = nil
    }
    
    private func addNewCycle() {
        
        let cycleName = name.stringValue.trimmingCharacters(in: [" "])
        let info = information.stringValue.trimmingCharacters(in: [" "])
        if cycleName == "" || info == "" {
            return
        }
        guard let price = Double(pricePerHour.stringValue) else {
            return
        }
        
        let user = PBBackendlessAPI.shared.currentUser()
        guard let store = PBBackendlessAPI.shared.loadCurrentStore(user, relations: ["store", "store.geopoint", "store.cycles"]) else {
            return
        }
        
        let location = "\(store.geopoint?.latitude.intValue ?? 0) \(store.geopoint?.longitude.intValue ?? 0)"
        let cycleNotCreated = Cycle(cycleName, info: info, price: price, location: location, storeId: (store.objectId as String?) ?? "")
        var fault : Fault? = nil
        guard let cycleCreated = PBBackendlessAPI.shared.backendless?.persistenceService.create(cycleNotCreated, error: &fault) as? Cycle else {
            return
        }
        
        let path = "images/store_\((store.objectId ?? ""))/cycle_\((cycleCreated.objectId ?? ""))/"
        if let tiffData = firstImage.image?.tiffRepresentation {
            if let pngData = NSBitmapImageRep(data: tiffData)?.representation(using: .PNG, properties: [:]) {
                let pathToImage = path.appending("firstImage.png")
                _ = PBBackendlessAPI.shared.backendless?.fileService.upload(pathToImage, content: pngData, error: &fault)
            }
        }
        if let tiffData = secondImage.image?.tiffRepresentation {
            if let pngData = NSBitmapImageRep(data: tiffData)?.representation(using: .PNG, properties: [:]) {
                let pathToImage = path.appending("secondImage.png")
                _ = PBBackendlessAPI.shared.backendless?.fileService.upload(pathToImage, content: pngData, error: &fault)
            }
        }
        if let tiffData = thirdImage.image?.tiffRepresentation {
            if let pngData = NSBitmapImageRep(data: tiffData)?.representation(using: .PNG, properties: [:]) {
                let pathToImage = path.appending("thirdImage.png")
                _ = PBBackendlessAPI.shared.backendless?.fileService.upload(pathToImage, content: pngData, error: &fault)
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
        PBCyclesResponder.shared.cycles = store.cycles ?? NSMutableArray()
        print(fault?.message ?? "Success update store")
    }
}
