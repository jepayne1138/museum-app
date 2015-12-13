//
//  NetworkHandler.swift
//  MuseumApp
//
//  Created by James Payne on 12/12/15.
//  Copyright © 2015 James Payne. All rights reserved.
//
//  With much thanks to Sam Wang's tutorial at:
//  https://medium.com/swift-programming/learn-nsurlsession-using-swift-part-2-background-download-863426842e21#.1zvkhmzkv
//

import Foundation
import RealmSwift

struct SessionProperties {
    static let identifier: String = "com.payne.ios.MuseumApp.backgroundDownload"
}

//let backgroundConfig = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(SessionProperties.identifier)
//let backgroundSession = NSURLSession(configuration: backgroundConfig, delegate: self.delegate, delegateQueue: nil)

typealias CompleteHandlerBlock = () -> ()

class DownloadSessionDelegate : NSObject, NSURLSessionDelegate, NSURLSessionDownloadDelegate {
    
    var handlerQueue: [String : CompleteHandlerBlock]!
    class var sharedInstance: DownloadSessionDelegate {
        struct Static {
            static var instance : DownloadSessionDelegate?
            static var token : dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = DownloadSessionDelegate()
            Static.instance!.handlerQueue = [String : CompleteHandlerBlock]()
        }
        
        return Static.instance!
    }
    
    //MARK: session delegate
    func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
        print("session error: \(error?.localizedDescription).")
    }
    
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))
    }
    
    // Called with download is finished
    func URLSession(session: NSURLSession, downloadTask:NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        print("session \(session) has finished the download task \(downloadTask) of URL \(location).")
        
        // Move the temporary file at \(location) to a permanant location
//        saveDownloadedFile(downloadTask, location: location)
        
        // New realm as this is called asyncronously in an Alamofire response handling closure
        let realm = try! Realm()
        let resource = realm.objects(Resource).filter("taskIdentifier = %@", downloadTask.taskIdentifier)[0]
        let localPath = uniqueFilename(resource.url)
        
        // Move the temporary file to the permanant location
        print("Src: \(location.path!)")
        print("File exists? : \(NSFileManager.defaultManager().fileExistsAtPath(location.path!))")
        print("Dst: \(localPath)")
        try! NSFileManager.defaultManager().copyItemAtURL(location, toURL: localPath)
        
        // Update the realm to indicate that the was properly saved
        try! realm.write {
            resource.localPath = localPath.path!
            resource.taskIdentifier = 0
        }
    }
    
    // Callback from current download process with written bytes (Can be used for progress)
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
//        print("session \(session) download task \(downloadTask) wrote an additional \(bytesWritten) bytes (total \(totalBytesWritten) bytes) out of an expected \(totalBytesExpectedToWrite) bytes.")
    }
    
    // Tells the delegate that all messages enqueed for a background session have been delivered
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        print("background session \(session) finished events.")
            
        if !session.configuration.identifier!.isEmpty {
            callCompletionHandlerForSession(session.configuration.identifier)
        }
    }
    
    //MARK: session delegate
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        print("Challenge: \(challenge)")
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))
    }

    
    //MARK: completion handler
    func addCompletionHandler(handler: CompleteHandlerBlock, identifier: String) {
        handlerQueue[identifier] = handler
    }
    
    func callCompletionHandlerForSession(identifier: String!) {
        let handler : CompleteHandlerBlock = handlerQueue[identifier]!
        handlerQueue!.removeValueForKey(identifier)
        handler()
    }
    
    //MARK: activation methods
//    func startBackgroundDownloads(sessionTasks: [NSURLSessionTask]) {
//        downloadTask.resume()
//    }
}