//
//  DataModels.swift
//  MuseumApp
//
//  Created by James Payne on 12/5/15.
//  Copyright © 2015 James Payne. All rights reserved.
//

import Foundation
import RealmSwift

class Exhibit: Object {
    dynamic var exhibitID = 0
    dynamic var name = ""
    dynamic var exhibitSectionID = 0
    dynamic var exibitSection: ExhibitSection?
    dynamic var viewControllerID = 0
    dynamic var viewController: ViewControllerData?
    dynamic var title = ""
    dynamic var text = ""
    dynamic var resourceID = 0
    dynamic var resource: Resource?
    dynamic var revision = 0;
    
    var exhibitSections: [ExhibitSection] {
        return linkingObjects(ExhibitSection.self, forProperty: "exhibits")
    }
    
    override static func primaryKey() -> String? {
        return "exhibitID"
    }
}

class ExhibitSection: Object {
    dynamic var exhibitSectionID = 0
    dynamic var name = ""
    let exhibits = List<Exhibit>()
    dynamic var revision = 0;
    
    override static func primaryKey() -> String? {
        return "exhibitSectionID"
    }
}

class Resource: Object {
    dynamic var resourceID = 0
    dynamic var url = ""
    dynamic var revision = 0;
    
    override static func primaryKey() -> String? {
        return "resourceID"
    }
}

class ViewControllerData: Object {
    dynamic var viewControllerID = 0
    dynamic var name = ""
    dynamic var segueID = ""
    dynamic var revision = 0;
    
    override static func primaryKey() -> String? {
        return "viewControllerID"
    }
}

class Event: Object {
    dynamic var eventID = 0
    dynamic var name = ""
    dynamic var content = ""
    dynamic var resourceID = 0
    dynamic var resource: Resource?
    dynamic var startTime = NSDate()
    dynamic var endTime = NSDate()
    dynamic var revision = 0;

    override static func primaryKey() -> String? {
        return "eventID"
    }
}