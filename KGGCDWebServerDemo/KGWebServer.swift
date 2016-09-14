//
//  KGWebServer.swift
//  KGGCDWebServerDemo
//
//  Created by Kevin Guo on 2016-09-12.
//  Copyright © 2016 Kevin Guo. All rights reserved.
//

import Foundation
import GCDWebServer
import Photos

typealias fetchPhotoIdCompletionHandler = (success: Bool, url: NSURL?) -> Void

class KGWebServer {
    
    var webServer : GCDWebServer!
    let port : UInt = 8089
    
    private static let _sharedWebServer = KGWebServer()
    
    static func getWebServer() -> KGWebServer{
        return KGWebServer._sharedWebServer
    }
    
    private init() {
        self.webServer = GCDWebServer()
        
        // /photos/
        self.webServer.addHandlerForMethod("GET", pathRegex: "^/photos(/)*$", requestClass: GCDWebServerRequest.self) { (request, completionBlock) in
            print("CASE /photos")
            completionBlock(GCDWebServerDataResponse(HTML:"<html><body><h1>CASE /photos</h1></body></html>"))

        }
        
        // /photos/{id}/
        self.webServer.addHandlerForMethod("GET", pathRegex: "^/photos/((\\w|\\d)-?)+(/)*$", requestClass: GCDWebServerRequest.self) { (request, completionBlock) in
            print("CASE /photos/id")
            
            // TODO: NSRegular Expressions
            var photoPath : String? = nil
            do {
                //let regex = try NSRegularExpression(pattern: "/(\\w+)\\/(.+/*)\\/(.*)", options: .CaseInsensitive)
                let regex = try NSRegularExpression(pattern: "/(photos)\\/(((\\w|\\d)-?)+)", options: .CaseInsensitive)
                let result = regex.matchesInString(request.path, options: .Anchored, range: NSMakeRange(0, request.path.characters.count))
                
                for match in result {
                    let matchRange = match.rangeAtIndex(2)
                    let matchString = (request.path as NSString).substringWithRange(matchRange)
                    print(matchString)
                    photoPath = matchString
                }
                
                
            } catch {
                print("Error in processing url using regular expressions")
            }
           
            if let photoPath = photoPath {
                let options = PHFetchOptions()
                options.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: false)]
                let set = PHAsset.fetchAssetsWithLocalIdentifiers([photoPath], options: options)
                if set.count > 0 {
                    (set.firstObject as! PHAsset).requestContentEditingInputWithOptions(.None, completionHandler: { (input, info) in
                        if let url = input?.fullSizeImageURL {
                            print(url)
                            completionBlock(GCDWebServerDataResponse(data: NSData(contentsOfURL: url), contentType: "image/jpeg"))
                        }
                    })
                } else {
                    print("photo not found")
                    completionBlock(GCDWebServerDataResponse(HTML:"<html><body><h1>Sorry, your requested photo isn't found</h1></body></html>"))
                }
            }
            //completionBlock(GCDWebServerDataResponse(HTML:"<html><body><h1>CASE /photos/id</h1></body></html>"))
        }
        
        
        // /photos/{id}/thumbnails
        self.webServer.addHandlerForMethod("GET", pathRegex: "^/photos/((\\w|\\d)-?)+/thumbnails$", requestClass: GCDWebServerRequest.self) { (request, completionBlock) in
            print("CASE /photos/id/thumbnails")
            
            var photoPath : String? = nil
            do {
                let regex = try NSRegularExpression(pattern: "/(photos)\\/(((\\w|\\d)-?)+)\\/", options: .CaseInsensitive)
                let result = regex.matchesInString(request.path, options: .Anchored, range: NSMakeRange(0, request.path.characters.count))
                
                for match in result {
                    let matchRange = match.rangeAtIndex(2)
                    let matchString = (request.path as NSString).substringWithRange(matchRange)
                    print(matchString)
                    photoPath = matchString
                }
                
                
            } catch {
                print("Error in processing url using regular expressions")
            }

            if let photoPath = photoPath {
                let options = PHFetchOptions()
                options.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: false)]
                let set = PHAsset.fetchAssetsWithLocalIdentifiers([photoPath], options: options)
                if set.count > 0 {
                    let option = PHImageRequestOptions()
                    option.synchronous = true
                    PHImageManager.defaultManager().requestImageForAsset(set.firstObject as! PHAsset, targetSize: CGSizeMake(150, 150), contentMode: .AspectFit, options: option, resultHandler: { (image :UIImage?, info :[NSObject : AnyObject]?) in
                        if let image = image {
                            print("************************************* \(image)")
                            let data = UIImageJPEGRepresentation(image, 1.0)!
                            completionBlock(GCDWebServerDataResponse(data:data, contentType: "image/jpeg"))
                        }
                    })
                } else {
                    print("photo not found")
                    completionBlock(GCDWebServerDataResponse(HTML:"<html><body><h1>Sorry, your requested thumbnail isn't found</h1></body></html>"))
                }
            }
            //completionBlock(GCDWebServerDataResponse(HTML:"<html><body><h1>CASE /photos/id/thumbnails</h1></body></html>"))
        }

        self.webServer.startWithPort(self.port, bonjourName: "GCD Web Server")
        print("Visit \(self.webServer.serverURL) in your web browser")

    }
    
}

