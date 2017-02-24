//
//  PBCyclesResponder.swift
//  VelikOS
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
//        updateCycles()
        delegate?.tableOfCycles.reloadData()
        return nil
    }
    
    func errorHandler(_ fault: Fault!) {
        print(fault.message ?? "Fault")
    }
    
    func cancelSubscribe() {
        subscription?.cancel()
    }
    
//    func updateCycles() {
//        guard let user = PBBackendlessAPI.shared.currentUser(),
//            let store = PBBackendlessAPI.shared.loadCurrentStore(user, relations:  ["store", "store.cycles"]) else { return }
//        cycles = store.cycles ?? NSMutableArray()
//    }
}
