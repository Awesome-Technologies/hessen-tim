//
//  LocalEchoStore.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Marco Festini on 08.05.20.
//  Copyright © 2020 Awesome Technologies Innovationslabor GmbH. All rights reserved.
//

import UIKit
import SMART
import RxSwift
import RxRelay

/// The LocalEchoStore holds a list of all resource that have not yet been stored in the server.
/// This is generally the case if the resource has their *id* property be nil.
/// It acts as a _pending_ resource store. The Repository should make sure
/// that no resource are both in the cache and this store at the same time.
class LocalEchoStore: NSObject {
    private var pendingEchoes = BehaviorRelay<[String: DomainResource]>(value: [:])
    var observable: Observable<[String: DomainResource]> {
        return pendingEchoes.asObservable()
    }
    private var echoes: [String: DomainResource] {
        return pendingEchoes.value
    }
    
    /// Add a resource to the store.
    /// - Parameter resource: Resource to add to the store.
    func add(resource: DomainResource) {
        guard let id = resource.localEchoId, !contains(resource: resource) else {
            return
        }
        var echoes = pendingEchoes.value
        echoes[id] = resource
        pendingEchoes.accept(echoes)
    }
    
    /// Remove a resource frmo the store.
    /// - Parameter resource: Resource to remove from the store.
    func remove(resource: DomainResource) {
        guard let id = resource.localEchoId, echoes.contains(where: {$0.key == id}) else {
            return
        }
        var newEchoes = pendingEchoes.value
        newEchoes.removeValue(forKey: id)
        pendingEchoes.accept(newEchoes)
    }
    
    /// Return the resource with the given id.
    /// - Parameter id: Id of the resource. This is the local store id and not the server given id.
    func echo(forId id: String) -> DomainResource? {
        return echoes[id]
    }
    
    /// Whether or not the store contains a given resource.
    /// - Parameter resource: Resource to check against the store.
    func contains(resource: DomainResource) -> Bool {
        guard let id = resource.localEchoId else {
            return false
        }
        return echoes.contains(where: { $0.key == id })
    }
    
    subscript(id: String) -> DomainResource? {
        get {
            return echo(forId: id)
        }
        set(newValue) {
            guard let newResource = newValue else {
                return
            }
            add(resource: newResource)
        }
    }
    
    /// Return all resources in the store.
    func allResources() -> [DomainResource] {
        return Array(echoes.values)
    }
    
    /// Return all resource of a given type.
    /// - Parameter type: The type to filter the list of resources with.
    func allResources<T: DomainResource>(ofType type: T.Type) -> [T] {
        return echoes.values.filter( {$0 is T} ).map( {$0 as! T} ) 
    }
}
