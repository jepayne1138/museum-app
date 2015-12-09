//
//  EventsTableViewController.swift
//  MuseumApp
//
//  Created by James Payne on 12/6/15.
//  Copyright © 2015 James Payne. All rights reserved.
//

import UIKit
import RealmSwift

class EventsTableViewController: UITableViewController {
    
    let realm = try! Realm()
    var events: Results<Event>?
    
    let timeFormat = NSDateFormatter()
    let dateFormat = NSDateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()

        let currentTime = NSDate()
        
        events = realm.objects(Event).sorted("startTime").filter("endTime >= %@", currentTime)
        
        // Initialize the date formatters
        timeFormat.timeStyle = NSDateFormatterStyle.ShortStyle
        dateFormat.dateStyle = NSDateFormatterStyle.ShortStyle
        
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
        return events!.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("eventsTableCell", forIndexPath: indexPath) as! EventsTableViewCell
        
        let event = events![indexPath.row]
        
        // Configure the cell...
        cell.eventNameLabel.text = event.name
        cell.contentTextView.text = event.content
        cell.startTimeLabel.text = timeFormat.stringFromDate(event.startTime)
        cell.endTimeLabel.text = timeFormat.stringFromDate(event.endTime)
        cell.dateLabel.text = dateFormat.stringFromDate(event.startTime)

        return cell
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
