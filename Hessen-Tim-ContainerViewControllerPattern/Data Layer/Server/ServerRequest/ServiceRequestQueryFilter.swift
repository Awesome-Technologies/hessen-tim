//
//  ServiceRequestQueryFilter.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Marco Festini on 27.05.20.
//  Copyright © 2020 Awesome Technologies Innovationslabor GmbH. All rights reserved.
//

import UIKit
import SMART

class ServiceRequestQueryFilter: DomainResourceQueryFilter {
    private var filterDict: [String: ServiceRequest.ServiceRequestFilter] = [:]
    
    override func constructQuery() -> [String : Any] {
        var query = super.constructQuery()
        
        filterDict.forEach { (key, filter) in
            switch filter {
            case .requester(let type, let id):
                query[key] = ["$type": type.resourceType, "_id": id]
            case .status(let requestStatus):
                query[key] = requestStatus.rawValue
            }
        }
        
        return query
    }
    
    func set(filter: ServiceRequest.ServiceRequestFilter) {
        filterDict[filter.key()] = filter
    }
    
    func filter(resources: [ServiceRequest]) -> [ServiceRequest] {
        var result = super.filter(resources: resources)
        
        filterDict.forEach { (key, filter) in
            switch filter {
            case .requester(let id):
                result = result.filter({ (serviceRequest) -> Bool in
                    return serviceRequest.requester?.reference?.string == "Organization/\(id)"
                })
            case .status(let requestStatus):
                result = result.filter({ $0.status == requestStatus })
            }
        }
        
        return result
    }
}
