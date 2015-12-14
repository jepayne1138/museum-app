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

    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var playToggleButton: UIButton!
    @IBOutlet weak var audioSlider: UISlider!

    var audio: AVAudioPlayer!
    var autoplay = false

    let playImage = UIImage(named: "play")
    let pauseImage = UIImage(named: "pause")

    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false

        // Do any additional setup after loading the view.
        // Set font size
        self.descriptionTextView.selectable = true
        self.descriptionTextView.font = UIFont(name: "Helvetica Neue", size: 24)
        self.descriptionTextView.selectable = false
        // Set description text
        descriptionTextView.text = exhibit!.text

        // Set default button image
        if (autoplay) {
            playToggleButton.setImage(pauseImage, forState: UIControlState.Normal)
        } else {
            playToggleButton.setImage(playImage, forState: UIControlState.Normal)
        }

        // Set the inital slider position
        audioSlider.value = 0

        if (exhibit!.resource!.localPath != "") {
            let url = NSURL(fileURLWithPath: exhibit!.resource!.localPath)

            do {
                audio = try AVAudioPlayer(contentsOfURL: url)
                if (autoplay) {
                    audio.play()
                }
            } catch {
                print("Unable to load file for audio: \(audio)")
            }
        }
    }

    @IBAction func playToggleButtonTouchUpInside(sender: UIButton) {
        // Handle the actual loggic for toggling play and pause
        if (audio != nil) {
            if (audio.playing) {
                audio.pause()
            } else {
                audio.play()
            }

            // Set the button image to the new image
            if (audio.playing) {
                playToggleButton.setImage(pauseImage, forState: UIControlState.Normal)
            } else {
                playToggleButton.setImage(playImage, forState: UIControlState.Normal)
            }
        } else {
            // Handle situation if audio is not yet loaded
            print("Audio is not yet loaded")
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
