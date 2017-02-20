//
//  Cycle.swift
//  VelikOS
//
//  Created by Pavel Borisevich on 16.02.17.
//  Copyright © 2017 Pavel Borisevich. All rights reserved.
//

import Foundation

enum CycleState: Int {
    case waiting
    case inUse
    case free
    case unavailible
}

class Cycle: NSObject {
    
    var state : NSString? = "unavailible"
    var objectId : NSString?
    var startsUse : NSNumber?
    var endsUse : NSNumber?
    var info : NSString?
    var images : NSMutableArray?
    var priceForHouar : NSNumber?
    
    override init() {
        super.init()
    }
}
