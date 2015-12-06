//
//  ExhibitsTableViewController.swift
//  MuseumApp
//
//  Created by James Payne on 11/6/15.
//  Copyright © 2015 James Payne. All rights reserved.
//

import UIKit
import RealmSwift

struct InvalidViewController: ErrorType {}

class ExhibitsTableViewController: UITableViewController {

    let realm = try! Realm()
    var exhibitSections: Results<ExhibitSection>?
    var exhibits: Results<Exhibit>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        exhibitSections = realm.objects(ExhibitSection)
        exhibits = realm.objects(Exhibit)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return exhibitSections!.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return exhibitSections![section].exhibits.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("exhibitTableCell", forIndexPath: indexPath) as! ExhibitsTableViewCell
        
        let exhibit = exhibitSections![indexPath.section].exhibits[indexPath.row]
        
        // Configure the cell...
        cell.exhibitNameLabel.text = exhibit.name
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let exhibit = exhibitSections![indexPath.section].exhibits[indexPath.row]
        self.performSegueWithIdentifier(exhibit.viewController!.segueID, sender: tableView)
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return exhibitSections![section].name
    }
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let destView = segue.destinationViewController as? ExhibitViewControllerBase

        if let indexPath = self.tableView.indexPathForSelectedRow {
            destView?.exhibit = exhibitSections![indexPath.section].exhibits[indexPath.row]
        }
    }

}
