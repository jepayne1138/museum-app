//
//  ExhibitViewControllerBase.swift
//  MuseumApp
//
//  Created by James Payne on 12/5/15.
//  Copyright © 2015 James Payne. All rights reserved.
//

import UIKit

class ExhibitViewControllerBase: UIViewController {

    // All ViewControllers inheriting from ExhibitViewControllerBase need this exhibit instance
    var exhibit: Exhibit?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = exhibit!.name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
