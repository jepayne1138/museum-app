//
//  ExhibitWebViewController.swift
//  MuseumApp
//
//  Created by James Payne on 12/5/15.
//  Copyright © 2015 James Payne. All rights reserved.
//

import UIKit

class ExhibitWebViewController: ExhibitViewControllerBase {
    @IBOutlet weak var contentWebView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Need to decide if supporting local files, remote calls, or both
        // Currently loads a remote URL from the text field of the exhibit
        let url = NSURL(string: (exhibit!.text))
        let request = NSURLRequest(URL: url!)
        contentWebView.loadRequest(request)
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
