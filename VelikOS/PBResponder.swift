//
//  PBResponder.swift
//  VelikOS
//
//  Created by Pavel Borisevich on 14.02.17.
//  Copyright © 2017 Pavel Borisevich. All rights reserved.
//

import Foundation
class PBResponder: NSObject, IResponder {
    
    var settingHandler : (Any!) -> Any! = { (response) in
        let theResponse = (response as AnyObject)
        print(theResponse.description)
        return response
    }
    
    func responseHandler(_ response: Any!) -> Any! {
        return settingHandler(response)
    }
    
    func errorHandler(_ fault: Fault!) {
        print(fault.faultCode)
        print(fault.detail)
        print(fault.message)
    }
}
