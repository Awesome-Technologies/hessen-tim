//
//  CacheProvider.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Marco Festini on 27.04.20.
//  Copyright © 2020 Awesome Technologies Innovationslabor GmbH. All rights reserved.
//

import UIKit
import SMART

/// The CacheProvider holds a list of all active caches for resource types.
/// If a cache does not exist yet, it will be created.
class CacheProvider {
    private var cacheList = [String: SuperCache]()
    
    /// Whether or not a cache for the given type already exists
    /// - Parameter ofType: The type to check
    /// - Returns: True if a cache exists, false if it doesn't
    func exists<T: DomainResource>(ofType: T.Type) -> Bool {
        return cacheList.contains(where: {$0.key == T.resourceType})
    }
    
    /// Return the cache for the given type. Creates a new cache if one does not exist yet.
    /// - Parameter type: DomainResource type to return a cache for.
    func cache<T: DomainResource>(forType type: T.Type) -> Cache<NSString, T> {
        if let cache = cacheList[T.resourceType] as? Cache<NSString, T> {
            return cache
        }
        let cache = Cache<NSString, T>()
        cacheList[T.resourceType] = cache
        return cache
    }
}
