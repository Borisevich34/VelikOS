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
        if let messages = response as? [Message], !messages.isEmpty {
            print(messages.first?.data ?? "Hasn't data")
            delegate?.tableOfCycles.reloadData()
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
