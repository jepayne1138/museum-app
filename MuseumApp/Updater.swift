//
//  Updater.swift
//  MuseumApp
//
//  Created by James Payne on 12/12/15.
//  Copyright © 2015 James Payne. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import Alamofire


struct BaseURLs {
    static let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
    static let baseURL = getBaseURL()
}


func getBaseURL() -> String {
    if let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist"), dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
        return dict["com.payne.ios.baseurl"] as! String
    }
    return ""  // Put a better error indicator here? Throw exception.
}


func initUpdateRealm() {
    //* Set up the realm
    // Purge the realm file for testing purposes
    do {
        print(Realm.Configuration.defaultConfiguration.path!)
        try NSFileManager.defaultManager().removeItemAtPath(Realm.Configuration.defaultConfiguration.path!)
    } catch {
        // Pass
    }
    // */
    
    // Get a new Realm instance
    let realm = try! Realm()
    // Create a new metadata instance it none exists
    if (realm.objectForPrimaryKey(Metadata.self, key: 0) == nil) {
        try! realm.write {
            realm.create(Metadata.self, value: ["revision": 0], update: true)
        }
    }
    let metadata = realm.objectForPrimaryKey(Metadata.self, key: 0)
    
    //* Test Alamofire code for updating the app
    let URL = "\(BaseURLs.baseURL)update?revision=\(metadata!.revision)"
    print(URL)
    Alamofire.request(.GET, URL).responseJSON() {
        response in
        switch response.result {
        case .Success(let data):
            let json = data as! NSDictionary
            handleUpdateJSON(json)
        case .Failure(let error):
            print("Request failed with error: \(error)")
        }
    }

}

func handleUpdateJSON(json: NSDictionary) {
    // New realm as this is called asyncronously in an Alamofire response handling closure
    let realm = try! Realm()
    
    // Arrays of new model objects to up added or updated
    var viewControllers = [ViewControllerData]()
    var exhibitSections = [ExhibitSection]()
    var resources = [Resource]()
    var events = [Event]()
    var exhibits = [Exhibit]()
    
    // Array of tasks that control resources that will be downloaded in the background
    var resourceDownloadTasks = [NSURLSessionTask]()
    let networkHandler = DownloadSessionDelegate.sharedInstance
    let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(SessionProperties.identifier)
    let backgroundSession = NSURLSession(configuration: configuration, delegate: networkHandler, delegateQueue: nil)
    
    
    // Create new models for non-dependate objects
    if let jsonViewControllers = json["view_controllers"] as? [NSDictionary] {
        for jsonViewController in jsonViewControllers {
            viewControllers.append(Mapper<ViewControllerData>().map(jsonViewController)!)
        }
    }
    if let jsonExhibitSections = json["exhibit_sections"] as? [NSDictionary] {
        for jsonExhibitSection in jsonExhibitSections {
            exhibitSections.append(Mapper<ExhibitSection>().map(jsonExhibitSection)!)
        }
    }
    if let jsonResources = json["resources"] as? [NSDictionary] {
        for jsonResource in jsonResources {
            let resource = Mapper<Resource>().map(jsonResource)!
            if !resource.url.isEmpty {
                let url = NSMutableURLRequest(URL: NSURL(string: "\(BaseURLs.baseURL)resources/\(resource.url)")!)
                let downloadTask = backgroundSession.downloadTaskWithRequest(url)
                resource.taskIdentifier = downloadTask.taskIdentifier  // Set taskIdentifier in Realm to match task when complete
                resourceDownloadTasks.append(downloadTask)
                resources.append(resource)
            }
        }
    }
    
    // Write non-dependant objects to the realm
    try! realm.write {
        for viewController in viewControllers {
            realm.add(viewController)
        }
        for exhibitSection in exhibitSections {
            realm.add(exhibitSection)
        }
        for resource in resources {
            realm.add(resource)
        }
    }
    
    // Start all resource downloads
    for sessionTask in resourceDownloadTasks {
        sessionTask.resume()
    }
    
    // Create new models for dependant objects
    if let jsonEvents = json["events"] as? [NSDictionary] {
        for jsonEvent in jsonEvents {
            let event = Mapper<Event>().map(jsonEvent)!
            // Add the Resource object
            event.resource = realm.objectForPrimaryKey(Resource.self, key: event.resourceID)
            events.append(event)
        }
    }
    if let jsonExhibits = json["exhibits"] as? [NSDictionary] {
        for jsonExhibit in jsonExhibits {
            let exhibit = Mapper<Exhibit>().map(jsonExhibit)!
            // Add the ExhibitSection object
            exhibit.exhibitSection = realm.objectForPrimaryKey(ExhibitSection.self, key: exhibit.exhibitSectionID)
            // Add the ViewControllerData object
            exhibit.viewController = realm.objectForPrimaryKey(ViewControllerData.self, key: exhibit.viewControllerID)
            // Add the Resource object
            exhibit.resource = realm.objectForPrimaryKey(Resource.self, key: exhibit.resourceID)
            exhibits.append(exhibit)
        }
    }
    
    // Write dependant objects to the realm
    try! realm.write {
        for event in events {
            realm.add(event)
        }
        for exhibit in exhibits {
            realm.add(exhibit)
        }
        // Update revision value after update is complete
        realm.objectForPrimaryKey(Metadata.self, key: 0)?.revision = json["revision"] as! Int
    }
}


func uniqueFilename(custom: String) -> NSURL {
    // Guarentees uniqueness for the filename in the default document directory
    let uuid: CFUUIDRef = CFUUIDCreate(nil)
    let uuidString = CFUUIDCreateString(nil, uuid)
    return BaseURLs.directoryURL.URLByAppendingPathComponent("\(uuidString).\(custom)")
}

// Saves a temporary file that was downloaded in a background session to the local device
func saveDownloadedFile(downloadTask: NSURLSessionDownloadTask, location: NSURL) {
    // New realm as this is called asyncronously in an Alamofire response handling closure
    let realm = try! Realm()
    let resource = realm.objects(Resource).filter("taskIdentifier = %@", downloadTask.taskIdentifier)[0]
    let localPath = uniqueFilename(resource.url)
    
    // Move the temporary file to the permanant location
//    print("Src: \(location.path!)")
//    print("File exists? : \(NSFileManager.defaultManager().fileExistsAtPath(location.path!))")
//    print("Dst: \(localPath)")
    try! NSFileManager.defaultManager().copyItemAtURL(location, toURL: localPath)
    
    // Update the realm to indicate that the was properly saved
    try! realm.write {
        resource.localPath = localPath.path!
        resource.taskIdentifier = 0
    }
}
