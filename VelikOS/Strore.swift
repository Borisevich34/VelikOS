//
//  Strore.swift
//  VelikOS
//
//  Created by Pavel Borisevich on 16.02.17.
//  Copyright © 2017 Pavel Borisevich. All rights reserved.
//



//  53.84746343692341 27.50530242919922

import Foundation
class Store: NSObject {
    
    var objectId : NSString?
    var cycles : NSMutableArray?
    var geopoint : GeoPoint?
    
    override init() {
        super.init()
    }
}
