//
//  MediaQueryFilter.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Marco Festini on 27.05.20.
//  Copyright © 2020 Awesome Technologies Innovationslabor GmbH. All rights reserved.
//

import UIKit
import SMART

class MediaQueryFilter: DomainResourceQueryFilter {
    private var filterDict: [String: Media.MediaFilter] = [:]
    
    override func constructQuery() -> [String : Any] {
        var query = super.constructQuery()
        
        filterDict.forEach { (key, filter) in
            switch filter {
            case .modality(let text):
                query[key] = ["$text": text]
            case .created(let mod, let date):
                query[key] = [mod: date]
            case .status(let eventStatus):
                query[key] = eventStatus
            }
        }
        
        return query
    }
    
    func set(filter: Media.MediaFilter) {
        filterDict[filter.key()] = filter
    }
    
    func filter(resources: [Media]) -> [Media] {
        var result = super.filter(resources: resources)
        
        filterDict.forEach { (key, filter) in
            switch filter {
            case .modality(let text):
                result = result.filter( {$0.modality?.text?.string == text} )
            case .created(let mod, let compareDate):
                result = result.filter { (media) -> Bool in
                    guard let date = media.createdDateTime?.nsDate else { return false }
                    switch mod {
                    case "$le":
                        return date < compareDate.nsDate || date == compareDate.nsDate
                    default: return false
                    }
                }
            case .status(let eventStatus):
                result = result.filter({ $0.status == eventStatus })
            }
        }
        
        return result
    }
}
