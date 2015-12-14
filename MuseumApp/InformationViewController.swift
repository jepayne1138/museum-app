//
//  InformationViewController.swift
//  
//
//  Created by Alan J Sayler on 12/14/15.
//
//

import UIKit
import RealmSwift
import Alamofire
import ObjectMapper

class InformationViewController: UIViewController {
  
    @IBOutlet weak var informationTextView: UITextView!
    @IBOutlet weak var hoursTextView: UITextView!

    @IBOutlet weak var locationTextView: UITextView!

    @IBOutlet weak var parkingTextView: UITextView!
    
    let realm = try! Realm()
    var information: GeneralInformation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        information = realm.objects(GeneralInformation).first
        informationTextView.text = information?.information
        hoursTextView.text = information?.hours
        locationTextView.text = information?.location
        parkingTextView.text = information?.parking


        // Do any additional setup after loading the view.
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
