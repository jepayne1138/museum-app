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
import SwiftyJSON

func handleUpdateJSON(json: NSDictionary) {
    // New realm as this is called asyncronously in an Alamofire response handling closure
    let realm = try! Realm()
    let dateFormatter = NSDateFormatter()
    dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
    
//    print(json)
    
    // Create/update non-dependant realm objects, so that dependants will have access to updated data
    try! realm.write {
        // Update ViewControllerDate, ExhibitSection, and Resource as these are non-dependant
        if let values = json["view_controllers"] as? [NSDictionary] {
            for value in values {
                realm.create(ViewControllerData.self, value: value, update: true)
            }
        }
        if let values = json["exhibit_sections"] as? [NSDictionary] {
            for value in values {
                realm.create(ExhibitSection.self, value: value, update: true)
            }
        }
        if let values = json["resources"] as? [NSDictionary] {
            for value in values {
                realm.create(Resource.self, value: value, update: true)
            }
        }
    
    // Create/update dependant realm objects and update any dependancies with our updated non-dependant objects
        if let values = json["exhibits"] as? [NSDictionary] {
            for value in values {
                let object = realm.create(Exhibit.self, value: value, update: true)
                // Get the exhibit section object and add the object to the exhibits list
                realm.objectForPrimaryKey(ExhibitSection.self, key: object.exhibitSectionID)!.exhibits.append(object)
                // Add the ViewControllerData object
                object.viewController = realm.objectForPrimaryKey(ViewControllerData.self, key: object.viewControllerID)
                // Add the Resource object
                object.resource = realm.objectForPrimaryKey(Resource.self, key: object.resourceID)
            }
        }
        if let values = json["events"] as? [NSDictionary] {
            for i in values.indices {
                var value = values[i].copy()
                let object = realm.create(Event.self, value: value, update: true)
                // Add the Resource object
                object.resource = realm.objectForPrimaryKey(Resource.self, key: object.resourceID)
            }
        }
    }
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
        if (realm.objectForPrimaryKey(Metadata.self, key: 0) == nil) {
            // Create a new metadata instance
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
        

        /* Sample Realm Data (add / to begining to use)
        let section1 = ExhibitSection(value: ["exhibitSectionID": 0, "name": "Section 1"])
        let section2 = ExhibitSection(value: ["exhibitSectionID": 1, "name": "Section 2"])
        
        let emptyResource = Resource()
        
        let textViewController = ViewControllerData(value: ["viewControllerID": 1, "name" : "TextViewController", "segueID": "toExhibitTextController"])
        let imageViewController = ViewControllerData(value: ["viewControllerID": 2, "name" : "ImageViewController", "segueID": "toExhibitImageController"])
        
        let testExhibit = Exhibit()
        testExhibit.exhibitID = 2
        testExhibit.name = "Test Exhibit"
        testExhibit.viewController = textViewController
        testExhibit.title = "Exhibit 1"
        testExhibit.text = "Example text goes here"
        testExhibit.resource = emptyResource
        
        let testExhibit2 = Exhibit()
        testExhibit2.exhibitID = 3
        testExhibit2.name = "Test Exhibit 2"
        testExhibit2.viewController = textViewController
        testExhibit2.title = "Exhibit 2"
        testExhibit2.text = "Exhibit 2 text goes here"
        testExhibit2.resource = emptyResource

        
        section1.exhibits.append(testExhibit)
        section2.exhibits.append(testExhibit2)
        
        // Events
        let event1 = Event()
        event1.eventID = 0
        event1.name = "Event 1"
        event1.content = "Description goes here"
        
        // Add to the Realm inside a transaction
        try! realm.write {
            // Add sections
            realm.add(section1)
            realm.add(section2)
            
            // Add resources
            realm.add(emptyResource)
            
            // Add view controllers
            realm.add(textViewController)
            realm.add(imageViewController)
            
            // Add exhibits
            realm.add(testExhibit)
            realm.add(testExhibit2)
            
            // Add events
            realm.add(event1)
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
