//
//  PBCheckGeolocation.swift
//  VelikOSX
//
//  Created by Pavel Borisevich on 16.02.17.
//  Copyright © 2017 Pavel Borisevich. All rights reserved.
//

/*
    Class cheks geolocation,
    If coordinates are invoked in Minsk area, method returns true
*/

import Foundation
class PBCheckGeolocation {
    
    static var shared = PBCheckGeolocation()
    
    let minskArea = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 53.9, longitude: 27.56), radius: 13000, identifier: "Minsk")
    
    func checkGeolocation(latitude: Double, longitude: Double) -> Bool {
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        return minskArea.contains(location)
    }
}
