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
    dynamic var exibitSections: ExhibitSection?
    dynamic var viewController: ViewControllerData?
    dynamic var title = ""
    dynamic var text = ""
    dynamic var resource: Resource?
    dynamic var revision = 0;
    
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