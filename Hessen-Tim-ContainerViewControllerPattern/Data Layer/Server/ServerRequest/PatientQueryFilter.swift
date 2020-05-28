//
//  PatientQueryFilter.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Marco Festini on 27.05.20.
//  Copyright © 2020 Awesome Technologies Innovationslabor GmbH. All rights reserved.
//

import UIKit
import SMART

class PatientQueryFilter: DomainResourceQueryFilter {
    private var filterDict: [String: Patient.PatientFilter] = [:]
    
    override func constructQuery() -> [String : Any] {
        var query = super.constructQuery()
        
        filterDict.forEach { (key, filter) in
            switch filter {
            case .practitioner(let value):
                query[key] = value
            }
        }
        
        return query
    }
    
    func set(filter: Patient.PatientFilter) {
        filterDict[filter.key()] = filter
    }
    
    func filter(resources: [Patient]) -> [Patient] {
        var result = super.filter(resources: resources)
        
        filterDict.forEach { (key, filter) in
            switch filter {
            case .practitioner(let value):
                result = result.filter({ ($0.generalPractitioner?.contains(where: { ($0.reference?.string.starts(with: value) ?? false) }) ?? false) })
            }
        }
        
        return result
    }
}
