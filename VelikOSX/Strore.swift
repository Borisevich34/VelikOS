//
//  Strore.swift
//  VelikOSX
//
//  Created by Pavel Borisevich on 16.02.17.
//  Copyright © 2017 Pavel Borisevich. All rights reserved.
//

import Foundation
class Store: NSObject {
    
    var objectId : NSString?
    var cycles : NSMutableArray?
    var geopoint : GeoPoint?
    var information : NSString?
    
    override init() {
        super.init()
    }
}
