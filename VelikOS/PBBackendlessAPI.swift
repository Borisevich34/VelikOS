//
//  PBBackendless.swift
//  VelikOS
//
//  Created by Pavel Borisevich on 14.02.17.
//  Copyright © 2017 Pavel Borisevich. All rights reserved.
//

import Foundation
import Cocoa

class PBBackendlessAPI {
    
    let APP_ID = "204914E5-38EB-6319-FF36-0C1EE7666C00"
    let SECRET_KEY = "A70D8623-F44E-D1B6-FF27-4132A62F6900"
    let VERSION_NUM = "v1"
    
    var userProperties : [String]?
    
    var backendless = Backendless.sharedInstance()
    static var shared = PBBackendlessAPI()
    
    init() {
        backendless?.initApp(APP_ID, secret: SECRET_KEY, version: VERSION_NUM)
        
        // If you plan to use Backendless Media Service, uncomment the following line (iOS ONLY!)
        // backendless.mediaService = MediaService()
    }
    
    func syncRegisterUserWithProperties(_ properties: [String : Any], latitude: Double, longitude: Double) -> Fault? {

        var fault : Fault? = nil
        let user = BackendlessUser(properties: properties)
        let registredUser = backendless?.userService.registering(user, error: &fault)
        
        //---
        if let store = loadCurrentStore(userWithoutLoadedStore: registredUser, relations: nil) {
            var testFault : Fault? = nil
            store.geopoint = GeoPoint(point: GEO_POINT(latitude: latitude, longitude: longitude), categories: ["Default"], metadata: ["store": store])
            if (PBBackendlessAPI.shared.backendless?.persistenceService.update(store, error: &testFault)) == nil {
                print(testFault?.message ?? "Fault")
            }
        }
        //---

        return fault
    }

    func loadCurrentStore(userWithoutLoadedStore: BackendlessUser?, relations: [String]?) -> Store? {
        var fault : Fault? = nil
        let userWithLoadedStore = PBBackendlessAPI.shared.backendless?.persistenceService.load(userWithoutLoadedStore, relations: (relations ?? ["store"]), error: &fault) as? BackendlessUser
        return userWithLoadedStore?.getProperty("store") as? Store
    }

    //Нужно не сразу логинить а потом проверять платформу, а сначала проверить пользователя
    func syncLoginUser(email: String, password: String, isNeedToRemember: Bool) -> Fault? {
        var fault : Fault? = nil
        guard let user = backendless?.userService.login(email, password: password, error: &fault) else {
            return fault
        }
        guard let platform = user.getProperty("platform") as? String else {
            //MARK - need to logout
            var logoutFault : Fault? = nil
            _ = backendless?.userService.logoutError(&logoutFault)
            return Fault(message: "!!!!Paste later!!!!")   //MARK - to do
        }
        if platform != "osx" {
            //MARK - need to logout
            var logoutFault : Fault? = nil
            _ = backendless?.userService.logoutError(&logoutFault)
            fault = Fault(message: "!!!!Paste later!!!!")   //MARK - to do
        }
        else {
            backendless?.userService.setStayLoggedIn(isNeedToRemember)
        }
        return fault
    }
    
    func setNeedToStayLogged(needToStayLogged: Bool) {
        backendless?.userService.setStayLoggedIn(needToStayLogged)
    }
    
    func isNeedToStayLogged() -> Bool? {
        return backendless?.userService.isStayLoggedIn
    }
    
    func userLogout() {
        var logoutFault : Fault? = nil
        _ = backendless?.userService.logoutError(&logoutFault)
        print("breakpoint")
    }
    
    func currentUser() -> BackendlessUser? {
        let user = backendless?.userService.currentUser
        return user
    }
    
}
