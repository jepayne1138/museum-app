//
//  ExhibitTextViewController.swift
//  MuseumApp
//
//  Created by James Payne on 12/5/15.
//  Copyright © 2015 James Payne. All rights reserved.
//

import UIKit

class ExhibitTextViewController: ExhibitViewControllerBase {

    @IBOutlet weak var contentTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
        
        // Set font size
        self.contentTextView.selectable = true
        self.contentTextView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
//        (name: "Helvetica Neue", size: 24)
        self.contentTextView.selectable = false

        self.contentTextView.text = self.exhibit!.text
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
