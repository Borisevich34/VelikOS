//
//  PBBackendless.swift
//  VelikOS
//
//  Created by Pavel Borisevich on 14.02.17.
//  Copyright © 2017 Pavel Borisevich. All rights reserved.
//

import Foundation
class PBBackendlessAPI {
    
    let APP_ID = "204914E5-38EB-6319-FF36-0C1EE7666C00"
    let SECRET_KEY = "A70D8623-F44E-D1B6-FF27-4132A62F6900"
    let VERSION_NUM = "v1"
    
    var userProperties : [String]?
    
    var backendless = Backendless.sharedInstance()
    static var shared = PBBackendlessAPI()
    
    init() {
        backendless?.initApp(APP_ID, secret: SECRET_KEY, version: VERSION_NUM)
        
        //backendless?.userService.registering(user)
        
        // If you plan to use Backendless Media Service, uncomment the following line (iOS ONLY!)
        // backendless.mediaService = MediaService()
    }
    
    func registerUserWithEmail(nickname: String, email: String, password: String) -> Bool {
        
        let user: BackendlessUser = BackendlessUser()
        user.email = email as NSString
        user.password = password as NSString
        
        return true
    }

    func retrieveUserEntityProperties() {
        let responder = PBResponder()
        responder.settingHandler = { (response) in
            if let properties = response as? NSArray {
                print(properties)
            }
            return response
        }
        
        //userProperties
        
        backendless?.userService.describeUserClass(responder)
        
        //    -(id)responseHandler:(id)response;
        //    {
        //    NSArray *properties = (NSArray *)response;
        //    NSLog(@"properties = %@, properties);
        //    return properties;
        //}
        
    }
    
}
