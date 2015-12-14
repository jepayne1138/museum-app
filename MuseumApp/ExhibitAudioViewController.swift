//
//  ExhibitAudioViewController.swift
//  MuseumApp
//
//  Created by James Payne on 12/5/15.
//  Copyright © 2015 James Payne. All rights reserved.
//

import UIKit
import AVFoundation


class ExhibitAudioViewController: ExhibitViewControllerBase {

    var audio: AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let playImage = UIImage(named: "play")
        let pauseImage = UIImage(named: "pause")

        if (exhibit!.resource!.localPath != "") {
            let url = NSURL(fileURLWithPath: exhibit!.resource!.localPath)

            do {
                let audio = try AVAudioPlayer(contentsOfURL: url)
                audio.play()
            } catch {
                print("Unable to load file for audio: \(audio)")
            }
        }
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
