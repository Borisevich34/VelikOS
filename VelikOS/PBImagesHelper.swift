//
//  PBImagesHelper.swift
//  VelikOS
//
//  Created by Pavel Borisevich on 24.02.17.
//  Copyright © 2017 Pavel Borisevich. All rights reserved.
//

import Cocoa
class PBImagesHelper {
    
    
//    static func removeImages(_ cycle: Cycle?) {
//        var fault : Fault? = nil
//        
//        if let firstPath = cycle?.firstImage {
//            PBBackendlessAPI.shared.backendless?.fileService.remove(firstPath as String, error: &fault)
//        }
//        if let secondPath = cycle?.secondImage {
//            PBBackendlessAPI.shared.backendless?.fileService.remove(secondPath as String, error: &fault)
//        }
//        if let thirdPath = cycle?.thirdImage {
//            PBBackendlessAPI.shared.backendless?.fileService.remove(thirdPath as String, error: &fault)
//        }
//    }
    
    static func removeImages(_ directoryPath: String) {
        var fault : Fault? = nil
        PBBackendlessAPI.shared.backendless?.fileService.removeDirectory(directoryPath, error: &fault)
    }
    
    static func downloadImages(_ cycle: Cycle?) -> [Int : NSImage?] {
        var result = [Int : NSImage?]()
        if let firstPath = cycle?.firstImage,
            let url = URL(string: "https://api.backendless.com/204914E5-38EB-6319-FF36-0C1EE7666C00/v1/files/".appending(firstPath as String)) {
            let request = URLRequest(url: url)
            let semaphore = DispatchSemaphore(value: 0)
            let downloadTask = URLSession.shared.downloadTask(with: request, completionHandler: { (location, response, error) in
                if error == nil, let locationPath = location?.relativePath {
                    
                    result[0] = NSImage(contentsOfFile: locationPath)
                    do {
                        try FileManager.default.removeItem(atPath: locationPath)
                    }
                    catch { print("Download image error!") }
                }
                else {
                    print(error.debugDescription)
                }
                semaphore.signal()
            })
            downloadTask.resume()
            semaphore.wait()
        }
        if let secondPath = cycle?.secondImage,
            let url = URL(string: "https://api.backendless.com/204914E5-38EB-6319-FF36-0C1EE7666C00/v1/files/".appending(secondPath as String)) {
            let request = URLRequest(url: url)
            let semaphore = DispatchSemaphore(value: 0)
            let downloadTask = URLSession.shared.downloadTask(with: request, completionHandler: { (location, response, error) in
                if error == nil, let locationPath = location?.relativePath {
                    result[1] = NSImage(contentsOfFile: locationPath)
                    do {
                        try FileManager.default.removeItem(atPath: locationPath)
                    }
                    catch { print("Download image error!") }
                }
                semaphore.signal()
            })
            downloadTask.resume()
            semaphore.wait()
        }
        if let thirdPath = cycle?.thirdImage,
            let url = URL(string: "https://api.backendless.com/204914E5-38EB-6319-FF36-0C1EE7666C00/v1/files/".appending(thirdPath as String)) {
            let request = URLRequest(url: url)
            let semaphore = DispatchSemaphore(value: 0)
            let downloadTask = URLSession.shared.downloadTask(with: request, completionHandler: { (location, response, error) in
                if error == nil, let locationPath = location?.relativePath {
                    result[2] = NSImage(contentsOfFile: locationPath)
                    do {
                        try FileManager.default.removeItem(atPath: locationPath)
                    }
                    catch { print("Download image error!") }
                }
                semaphore.signal()
            })
            downloadTask.resume()
            semaphore.wait()
        }
        return result
    }
}
