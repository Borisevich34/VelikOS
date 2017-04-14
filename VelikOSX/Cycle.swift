//
//  Cycle.swift
//  VelikOS
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
    
    var timePeriod : NSString?
    var orderTime : NSString?
    
    var name : NSString?
    var information : NSString?
    var pricePerHour : NSNumber?
    var user : BackendlessUser?
    
    var firstImage : NSString?
    var secondImage : NSString?
    var thirdImage : NSString?
    
    override init() {
        super.init()
        state = 0
    }
    
    init(_ cycleName: String, info: String, price: Double, firstUrl: String?, secondUrl: String?, thirdUrl: String?) {
        state = 0
        
        name = cycleName as NSString
        information = info as NSString
        pricePerHour = NSNumber(value: price)
        
        firstImage = firstUrl as NSString?
        secondImage = secondUrl as NSString?
        thirdImage = thirdUrl as NSString?
        
        super.init()
    }
    
}
