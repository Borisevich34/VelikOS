//
//  Cycle.swift
//  VelikOSX
//
//  Created by Pavel Borisevich on 16.02.17.
//  Copyright © 2017 Pavel Borisevich. All rights reserved.
//

import Foundation
import Cocoa

enum CycleState: Int {
    case unavailible
    case free
    case waiting
    case inUse
}

class Cycle: NSObject {
    
    var state : NSNumber?
    var objectId : NSString?
    
    var timePeriod : NSNumber?
    var orderTime : NSString?
    
    var name : NSString?
    var information : NSString?
    var pricePerHour : NSNumber?
    var userEmail : NSString?
    
    var location : NSString?
    var storeId : NSString?
    
    override init() {
        super.init()
        state = 0
    }
    
    init(_ cycleName: String, info: String, price: Double, location: String, storeId: String) {
        
        self.state = 0
        self.name = cycleName as NSString
        self.information = info as NSString
        self.pricePerHour = NSNumber(value: price)
        self.location = location as NSString
        self.storeId = storeId as NSString
        
        super.init()
    }
    
}
