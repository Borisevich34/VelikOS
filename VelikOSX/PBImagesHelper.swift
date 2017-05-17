//
//  PBImagesHelper.swift
//  VelikOSX
//
//  Created by Pavel Borisevich on 24.02.17.
//  Copyright © 2017 Pavel Borisevich. All rights reserved.
//

import Cocoa
class PBImagesHelper {
    
    static private let imageNames = ["firstImage.png", "secondImage.png", "thirdImage.png"]
    
    static func removeImages(_ directoryPath: String) {
        var fault : Fault? = nil
        PBBackendlessAPI.shared.backendless?.fileService.removeDirectory(directoryPath, error: &fault)
    }
    
   static func downloadImagesOfCycle(_ cycle: Cycle?) -> [Int : NSImage?] {
        guard let cycleId = (cycle?.objectId as String?), let storeId = (cycle?.storeId as String?) else { return [:] }
        let pathToDirectory = createPathToDirectory(storeId: storeId, cycleId: cycleId)
        var result = [Int : NSImage?]()
        for i in 0...2 {
            result[i] = loadImageWithDirectoryPath(pathToDirectory, andImageName: imageNames[i])
        }
        return result
    }
    
    static private func createPathToDirectory(storeId: String, cycleId: String) -> String {
        let pathToFiles = "https://api.backendless.com/204914E5-38EB-6319-FF36-0C1EE7666C00/v1/files/"
        return pathToFiles.appending("images/store_\(storeId)/cycle_\(cycleId)/")
    }
    
    static private func loadImageWithDirectoryPath(_ path: String, andImageName name: String) -> NSImage? {
        var image: NSImage? = nil
        let url = URL(string: path.appending(name))
        let request = URLRequest(url: url!)
        let semaphore = DispatchSemaphore(value: 0)
        let downloadTask = URLSession.shared.downloadTask(with: request, completionHandler: { (location, response, error) in
            if error == nil, let locationPath = location?.relativePath {
                image = NSImage(contentsOfFile: locationPath)
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
        return image
    }
}
