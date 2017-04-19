//
//  PBCyclesResponder.swift
//  VelikOSX
//
//  Created by Pavel Borisevich on 22.02.17.
//  Copyright © 2017 Pavel Borisevich. All rights reserved.
//

import Foundation
class PBCyclesResponder : NSObject, IResponder {
    
    static var shared = PBCyclesResponder()
    var cycles = NSMutableArray()
    weak var delegate: PBMainMenu?
    var subscription : BESubscription?
    
    override init() {
        super.init()
    }
    
    func responseHandler(_ response: Any!) -> Any! {
        if let messages = response as? [Message], !messages.isEmpty {
            print(messages.first?.data ?? "Message from channel hasn't data")
            if let user = PBBackendlessAPI.shared.currentUser() {
                if let storeCycles = PBBackendlessAPI.shared.loadCurrentStore(user, relations: ["store.geopoint", "store.cycles.user"])?.cycles {
                    cycles = storeCycles
                    delegate?.tableOfCycles.reloadData()
                }
            }
        }
        return nil
    }
    
    func errorHandler(_ fault: Fault!) {
        print(fault.message ?? "Fault")
    }
    
    func cancelSubscribe() {
        subscription?.cancel()
    }
}
