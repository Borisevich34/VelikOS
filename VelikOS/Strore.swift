//
//  Strore.swift
//  VelikOS
//
//  Created by Pavel Borisevich on 16.02.17.
//  Copyright © 2017 Pavel Borisevich. All rights reserved.
//

import Foundation
class Store: NSObject {
    
    var cycles : NSMutableArray?
    var geopoint : GeoPoint?
    
    override init() {
        super.init()
    }
    
    init(latitude: Double, longitude: Double) {
        super.init()
        geopoint = GeoPoint(point: GEO_POINT(latitude: latitude, longitude: longitude))
    }
}
