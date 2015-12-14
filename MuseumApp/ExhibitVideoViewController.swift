//
//  ExhibitVideoViewController.swift
//  MuseumApp
//
//  Created by James Payne on 12/5/15.
//  Copyright © 2015 James Payne. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ExhibitVideoViewController: ExhibitViewControllerBase {

    @IBOutlet weak var playVideoButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!

    var localPathURL: String?
    var headerText: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        print("ATTEMPTING TO LOAD:  id=\(exhibit!.resource!.resourceID), url=\(exhibit!.resource!.url), localPath=\(exhibit!.resource!.localPath)")

        self.automaticallyAdjustsScrollViewInsets = false
        headerText = ""

        localPathURL = exhibit!.resource!.localPath
        if localPathURL! != "" {
            playVideoButton.enabled = true
            if let snapshotImage = videoSnapshot(localPathURL!) {
                playVideoButton.setImage(snapshotImage, forState: UIControlState.Normal)
            }
        }
        else {
            // Disable the button as the resource is not yet loaded
            playVideoButton.enabled = false
            headerText = "Video assest not yet downloaded:  Please try again later.\n\n"
        }

        // Do any additional setup after loading the view.
        // Set font size
        self.descriptionTextView.selectable = true
        self.descriptionTextView.font = UIFont(name: "Helvetica Neue", size: 24)
        self.descriptionTextView.selectable = false

        descriptionTextView.text = headerText! + exhibit!.text
    }

    @IBAction func playVideoButtonTouchUpInside(sender: UIButton) {
            if (localPathURL! != "") {
                let player = AVPlayer(URL: NSURL(fileURLWithPath: localPathURL!))
                let playerController = AVPlayerViewController()
                playerController.player = player
                self.presentViewController(playerController, animated: true) {
                    player.play()
                }
            }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let destView = segue.destinationViewController as? VideoPlayerViewController

        if let unwrappedPath = localPathURL {
            let url = NSURL(string: unwrappedPath)
            destView!.player = AVPlayer(URL: url!)
        }
    }
}
