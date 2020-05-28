//
//  Cache.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Marco Festini on 27.04.20.
//  Copyright © 2020 Awesome Technologies Innovationslabor GmbH. All rights reserved.
//

import UIKit
import FHIR
import RxSwift
import RxRelay

class SuperCache: NSObject {}

class Cache<Key: NSString, Value: DomainResource>: SuperCache, NSCacheDelegate {
    private let wrapped = NSCache<WrappedKey, Entry>()
    
    // NSCache doesn't expose API to retrieve all objects
    // This list acts as a workaround
    // Since the keys are always synced to the cache itself we can use it for observation
    private let observableKeys = BehaviorRelay(value: Set<WrappedKey>())
    
    /// Observable for the keys that are in this cache.
    /// This can be used to keep track of changes of this cache.
    var observable: Observable<Set<WrappedKey>> {
        return observableKeys.asObservable()
    }
    private var keys: Set<WrappedKey> {
        return observableKeys.value
    }
    
    override init() {
        super.init()
        
        wrapped.delegate = self
    }
    
    private func _insert(_ entry: Entry, forKey key: WrappedKey) {
        
        guard let object = self[key.key],
            let objectUpdated = object.meta?.lastUpdated?.date.nsDate,
            let entryUpdated = entry.value.meta?.lastUpdated?.date.nsDate else {
                wrapped.setObject(entry, forKey: key)
                return
        }
        if (objectUpdated <= entryUpdated) {
            guard let mediaFile = object as? Media else {
                wrapped.setObject(entry, forKey: key)
                return
            }
            if (mediaFile.content?.data == nil) {
                wrapped.setObject(entry, forKey: key)
            }
        }
    }
    
    
    /// Insert a resource into this cache. The id of the resource will be used as the key.
    /// - Parameter value: Resource to be inserted.
    func insert(_ value: Value) {
        guard let id = value.id?.string as? Key else { return }
        insert(value, forKey:id)
    }
    
    /// Insert a resource into this cache.
    /// - Parameters:
    ///   - value: Resource to be inserted.
    ///   - key: Key of the value.
    internal func insert(_ value: Value, forKey key: Key) {
        let entry = Entry(value: value)
        let wrappedKey = WrappedKey(key)
        _insert(entry, forKey: wrappedKey)
        
        var temp = keys
        temp.insert(wrappedKey)
        observableKeys.accept(temp)
    }
    
    /// Insert a list into this cache.
    /// - Parameter newList: The list of resources to put into the cache.
    internal func insertList(_ newList: [Value]) {
        guard newList.count > 0 else {
            return
        }
        
        var temp = keys
        newList.forEach { value in
            if let key = value.id?.string as? Key {
                let entry = Entry(value: value)
                let wrappedKey = WrappedKey(key)
                temp.insert(wrappedKey)
                _insert(entry, forKey: wrappedKey)
            }
        }
        observableKeys.accept(temp)
    }
    
    /// Get the value for a given key.
    /// - Parameter key: Key of the value to return.
    /// - Returns: Returns the Value if it exists. Nil if it doesn't.
    internal func value(forKey key: Key) -> Value? {
        let entry = wrapped.object(forKey: WrappedKey(key))
        return entry?.value
    }
    
    /// Remove a value.
    /// - Parameter key: Key of the value to be removed.
    internal func removeValue(forKey key: Key) {
        let wrappedKey = WrappedKey(key)
        wrapped.removeObject(forKey: wrappedKey)
        
        var temp = keys
        temp.remove(wrappedKey)
        observableKeys.accept(temp)
    }
    
    /// Clear the cache.
    internal func clear() {
        wrapped.removeAllObjects()
        observableKeys.accept([])
    }
    
    /// Whether or not this cache holds any objects.
    func hasCachedObjects() -> Bool {
        return !keys.isEmpty
    }
    
    /// Return the number of objects in this cache.
    func numberOfObjects() -> UInt {
        return UInt(keys.count)
    }
    
    internal func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
        guard let resource = obj as? DomainResource, let id = resource.id?.string as? Key else {
            return
        }
        let wrappedKey = WrappedKey(id)
        
        var temp = keys
        temp.remove(wrappedKey)
        observableKeys.accept(temp)
    }
    
    /// Return all cached objects.
    func getCachedObjects() -> [Value] {
        var result = [Value]()
        for key in keys {
            if let resource = wrapped.object(forKey: key) {
                result.append(resource.value)
            }
        }
        return result
    }
}

extension Cache {
    subscript(key: Key) -> Value? {
        get { return value(forKey: key) }
        set {
            guard let value = newValue else {
                // If nil was assigned using our subscript,
                // then we remove any value for that key:
                removeValue(forKey: key)
                return
            }

            insert(value, forKey: key)
        }
    }
}

extension Cache {
    final class WrappedKey: NSObject {
        let key: Key

        init(_ key: Key) { self.key = key }

        override var hash: Int { return key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }

            return value.key == key
        }
    }
}

extension Cache {
    final class Entry {
        let value: Value

        init(value: Value) {
            self.value = value
        }
    }
}
