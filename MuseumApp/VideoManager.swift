//
//  VideoManager.swift
//  MuseumApp
//
//  Created by James Payne on 12/13/15.
//  Copyright © 2015 James Payne. All rights reserved.
//
//  Credit to user Nishant on StackOverflow
//  http://stackoverflow.com/a/32683290
//

import Foundation
import AVFoundation
import UIKit


func videoSnapshot(filePathLocal: NSString) -> UIImage? {
    
    let vidURL = NSURL(fileURLWithPath:filePathLocal as String)
    let asset = AVURLAsset(URL: vidURL)
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
    
    let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
    
    do {
        let imageRef = try generator.copyCGImageAtTime(timestamp, actualTime: nil)
        return UIImage(CGImage: imageRef)
    }
    catch let error as NSError
    {
        print("Image generation failed with error \(error)")
        return nil
    }
}