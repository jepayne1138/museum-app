//
//  MainTableViewController.swift
//  MuseumApp
//
//  Created by James Payne on 11/1/15.
//  Copyright © 2015 James Payne. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import ObjectMapper

func handleUpdateJSON(json: NSDictionary) {
    // New realm as this is called asyncronously in an Alamofire response handling closure
    let realm = try! Realm()
    
//    let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist")
//    let dict = NSDictionary(contentsOfFile: path!) as? [String: AnyObject]
//    let baseURL = dict!["com.payne.ios.baseurl"] as? String
//    
//    let destination: (NSURL, NSHTTPURLResponse) -> (NSURL) = {
//        (_, response) in
//        return uniqueFilename(response.suggestedFilename!)
//    }
    
    // Arrays of new model objects to up added or updated
    var viewControllers = [ViewControllerData]()
    var exhibitSections = [ExhibitSection]()
    var resources = [Resource]()
    var events = [Event]()
    var exhibits = [Exhibit]()

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
            resources.append(resource)
//            Alamofire.download(.GET, "\(baseURL!)\(resource.url)", destination: destination)
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
    let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
    let uuid: CFUUIDRef = CFUUIDCreate(nil)
    let uuidString = CFUUIDCreateString(nil, uuid)
    return directoryURL.URLByAppendingPathComponent("\(uuidString).\(custom)")
}

class MainTableViewController: UITableViewController {

    struct SegueInfo {
        var name: String
        var segueID: String
    }

    var baseURL: String?
    var navigation = [
        SegueInfo(name: "Information", segueID: "toInformationController"),
        SegueInfo(name: "Exhibits", segueID: "toExhibitsController"),
        SegueInfo(name: "Events", segueID: "toEventsController")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist"), dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            baseURL = dict["com.payne.ios.baseurl"] as? String
        }
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
        let URL = "\(baseURL!)update?revision=\(metadata!.revision)"
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
        // */

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return navigation.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("mainTableCell", forIndexPath: indexPath) as! MainTableViewCell

        // Configure the cell...
        cell.navigationLabel.text = navigation[indexPath.row].name


        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier(navigation[indexPath.row].segueID, sender: tableView)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
