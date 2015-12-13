//
//  DataModels.swift
//  MuseumApp
//
//  Created by James Payne on 12/5/15.
//  Copyright © 2015 James Payne. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class ISO8601Transform: TransformType {
    
    // TODO:  Add formatters to account for optional variations in ISO 8601 encoding
    //        and take the likely just take the first non-nil value
    // For now I belive this format works with the current API as long as no milliseconds
    
    typealias Object = NSDate
    typealias JSON = String
    
    let dateFormatter = NSDateFormatter()

    init() {
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    }
    
    func transformFromJSON(value: AnyObject?) -> Object? {
        return dateFormatter.dateFromString(value as! String)
    }

    func transformToJSON(value: Object?) -> JSON? {
        return dateFormatter.stringFromDate(value!)
    }

}

class Exhibit: Object, Mappable {
    dynamic var exhibitID = 0
    dynamic var name = ""
    dynamic var exhibitSectionID = 0
    dynamic var exhibitSection: ExhibitSection?
    dynamic var viewControllerID = 0
    dynamic var viewController: ViewControllerData?
    dynamic var text = ""
    dynamic var resourceID = 0
    dynamic var resource: Resource?
    dynamic var revision = 0

    required convenience init?(_ map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        exhibitID <- map["exhibitID"]
        name <- map["name"]
        exhibitSectionID <- map["exhibitSectionID"]
        viewControllerID <- map["viewControllerID"]
        text <- map["text"]
        resourceID <- map["resourceID"]
        revision <- map["revision"]
    }

    override static func primaryKey() -> String? {
        return "exhibitID"
    }
}

class ExhibitSection: Object, Mappable {
    dynamic var exhibitSectionID = 0
    dynamic var name = ""
    dynamic var revision = 0

    var exhibits: [Exhibit] {
        return linkingObjects(Exhibit.self, forProperty: "exhibitSection")
    }
    
    required convenience init?(_ map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        exhibitSectionID <- map["exhibitSectionID"]
        name <- map["name"]
        revision <- map["revision"]
    }

    override static func primaryKey() -> String? {
        return "exhibitSectionID"
    }
}

class Resource: Object, Mappable {
    dynamic var resourceID = 0
    dynamic var url = ""
    dynamic var localPath = ""
    dynamic var filename = ""
    dynamic var taskIdentifier = 0
    dynamic var revision = 0

    required convenience init?(_ map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        resourceID <- map["resourceID"]
        url <- map["url"]
        revision <- map["revision"]
    }

    override static func primaryKey() -> String? {
        return "resourceID"
    }
}

class ViewControllerData: Object, Mappable {
    dynamic var viewControllerID = 0
    dynamic var name = ""
    dynamic var segueID = ""
    dynamic var revision = 0

    required convenience init?(_ map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        viewControllerID <- map["viewControllerID"]
        name <- map["name"]
        segueID <- map["segueID"]
        revision <- map["revision"]
    }

    override static func primaryKey() -> String? {
        return "viewControllerID"
    }
}

class Event: Object, Mappable {
    dynamic var eventID = 0
    dynamic var name = ""
    dynamic var content = ""
    dynamic var resourceID = 0
    dynamic var resource: Resource?
    dynamic var startTime = NSDate()
    dynamic var endTime = NSDate()
    dynamic var revision = 0

    required convenience init?(_ map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        eventID <- map["eventID"]
        name <- map["name"]
        content <- map["description"]
        resourceID <- map["resourceID"]
        startTime <- (map["startTime"], ISO8601Transform())
        endTime <- (map["endTime"], ISO8601Transform())
        revision <- map["revision"]
    }

    override static func primaryKey() -> String? {
        return "eventID"
    }
}

class Metadata: Object, Mappable {
    dynamic var metadataID = 0
    dynamic var revision = 0

    required convenience init?(_ map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        metadataID <- map["metadataID"]
        revision <- map["revision"]
    }

    override static func primaryKey() -> String? {
        return "metadataID"
    }
}
