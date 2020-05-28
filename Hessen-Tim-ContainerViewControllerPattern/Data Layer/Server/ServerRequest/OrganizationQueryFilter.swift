//
//  OrganizationQueryFilter.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Marco Festini on 27.05.20.
//  Copyright © 2020 Awesome Technologies Innovationslabor GmbH. All rights reserved.
//

import UIKit
import SMART

class OrganizationQueryFilter: DomainResourceQueryFilter {
    private var filterDict: [String: Organization.OrganizationFilter] = [:]
    
    override func constructQuery() -> [String : Any] {
        var query = super.constructQuery()
        
        filterDict.forEach { (key, filter) in
            switch filter {
            case .type(let type):
                query[key] = ["$text": type]
            }
        }
        
        return query
    }
    
    func set(filter: Organization.OrganizationFilter) {
        filterDict[filter.key()] = filter
    }
    
    func filter(resources: [Organization]) -> [Organization] {
        var result = super.filter(resources: resources)
        
        filterDict.forEach { (key, filter) in
            switch filter {
            case .type(let type):
                result = result.filter( { ($0.type?.contains(where: { $0.text?.string == type }) ?? false) } )
            }
        }
        
        return result
    }
}
