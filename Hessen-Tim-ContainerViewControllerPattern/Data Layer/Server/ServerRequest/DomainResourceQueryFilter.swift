//
//  ServerRequestQueryFilter.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Marco Festini on 07.05.20.
//  Copyright © 2020 Awesome Technologies Innovationslabor GmbH. All rights reserved.
//

import UIKit
import SMART

class DomainResourceQueryFilter: NSObject {
    private var filterDict: [String: DomainResource.SearchFilter] = [:]
    
    var sortingString: String? {
        guard let filter = filterDict["_sort"] else {
            return nil
        }
        return filter.sortString()
    }
    
    /// Construct query for use with FHIRSearch.
    func constructQuery() -> [String: Any] {
        var query: [String: Any] = [:]
        filterDict.forEach { (key, filter) in
            switch filter {
            case .id(let value), .sort(let value):
                query[key] = value
            case .subject(let type, let id):
                query[key] = ["$type": type.resourceType, "_id": id]
            case .basedOn(let array):
                guard let array = array else {
                    query[key] = ["$type": ServiceRequest.resourceType]
                    return
                }
                array.forEach { (key2, value) in
                    switch key2 {
                    case "status", "_id":
                        query[key] = value
                    case "subject":
                        guard let (type, variable, variableValue) = value as? (DomainResource.Type, String, String) else { return }
                        query[key] = ["$type": type.resourceType , "subject:" + variable: variableValue]
                    default: break
                    }
                }
            case .summary(let summary):
                query[key] = summary.rawValue
            case .has(let chain, let value):
                query[key] = (chain, value)
            }
                
        }
        return query
    }
    
    func set(filter: DomainResource.SearchFilter) {
        filterDict[filter.key()] = filter
    }
    
    /// Apply the added filters to the given resource list.
    /// - Parameter resources: The resource list to alter.
    func filter<T: DomainResource>(resources: [T]) -> [T] {
        var result = resources
        let values = filterDict.values.sorted { (left, right) -> Bool in
            return left.key() != "_sort"
        }
        values.forEach { filter in
            switch filter {
            case .id(let value):
                if let resource = result.first(where: {$0.id?.string == value}) {
                    result = [resource]
                } else {
                    result = [T]()
                }
            case .basedOn(let array):
                result = result.filter { (resource) -> Bool in
                    guard let basedOn = getBasedOnReference(ofResource: resource) else { return false }
                    guard let array = array, !array.isEmpty else { return basedOn.reference?.string.starts(with: ServiceRequest.resourceType) ?? false }
                    
                    if let refId = basedOn.reference?.string.split(separator: "/")[1], let sr = Repository.instance.getCachedResource(withId: String(refId)) as? ServiceRequest {
                        let mirror = Mirror(reflecting: sr)
                        
                        var matched = true
                        array.forEach { (variable) in
                            let (name, value) = variable
                            var compName = name
                            var compValue = ""
                            switch name {
                            case "status":
                                compValue = value as? String ?? compValue
                            case "_id":
                                compName = "id"
                                compValue = value as? String ?? compValue
                            case "subject":
                                guard let subject = value as? [String: Any],
                                    let type = subject["$type"] as? DomainResource.Type,
                                    let id = subject["_id"] as? String else { return }
                                compValue = "\(type.resourceType)/\(id)"
                            default:
                                break
                            }
                            
                            matched = mirror.children.contains(where: {$0.label == compName && $0.value as? String == compValue})
                            if !matched {
                                return
                            }
                        }
                        return matched
                    } else {
                        return false
                    }
                }
            case .sort(let sort):
                let _sort = sort == "authored" ? "authoredOn" : sort
                
                result = result.sorted(by: { (drl, drr) -> Bool in
                    let ml = Mirror(reflecting: drl)
                    let mr = Mirror(reflecting: drr)
                    
                    guard let dateLeft = (ml.children.first(where: { $0.label == _sort })?.value as? DateTime)?.nsDate,
                    let dateright = (mr.children.first(where: { $0.label == _sort })?.value as? DateTime)?.nsDate else {
                        return false
                    }
                    
                    return dateLeft.compare(dateright) == .orderedDescending
                })
            case .subject(let type, let id):
                result = filterForSubject(resources: result, tuple: (type, id))
            default: break
            }
        }
        
        return result
    }
    
    private func filterForSubject<T: DomainResource>(resources: [T], tuple: (type: DomainResource.Type, id: String)) -> [T] {
        return resources.filter { (resource) -> Bool in
            let mirror = Mirror(reflecting: resource)
            
            if let ref = mirror.children.first(where: {$0.label == "subject"})?.value as? Reference {
                return ref.reference?.string == "\(tuple.type.resourceType)/\(tuple.id)"
            }
            
            return false
        }
    }
    
    private func getBasedOnReference(ofResource resource: DomainResource) -> Reference? {
        let mirror = Mirror(reflecting: resource)
        return mirror.children.first(where: {$0.label == "basedOn"})?.value as? Reference
    }
}
