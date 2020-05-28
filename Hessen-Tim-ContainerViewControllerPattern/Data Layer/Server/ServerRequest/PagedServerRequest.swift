//
//  PagedServerRequest.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Marco Festini on 28.04.20.
//  Copyright © 2020 Awesome Technologies Innovationslabor GmbH. All rights reserved.
//

import UIKit
import SMART

class PagedServerRequest<T: DomainResource>: SimpleServerRequest<T> {

    public enum Status: Int {
        case unknown
        case initialized
        case loading
        case ready
    }
    
    open var status: Status = .unknown {
    didSet {
            onStatusUpdate?(lastStatusError)
            lastStatusError = nil
        }
    }
    fileprivate var lastStatusError: FHIRError? = nil
    
    /// A block executed whenever the receiver's status changes.
    open var onStatusUpdate: ((FHIRError?) -> Void)?
    
    public var fetchedList: [T]? {
        didSet {
            expectedNumber = max(expectedNumber, actualNumber)
            onListUpdate?()
        }
    }
    
    /// Expected total number of resources.
    private (set) var expectedNumber: UInt = 0
    open var actualNumber: UInt {
        return UInt(fetchedList?.count ?? 0)
    }
    
    /// A block to be called when the `fetchedList` property changes.
    open var onListUpdate: (() -> Void)?
    
    var isDone = false
    
    /// Indicating whether not all patients have yet been loaded.
    open var hasMore: Bool {
        return search.hasMore
    }
    
    convenience override init(toServer server: Server, withFilter filter: DomainResourceQueryFilter? = nil) {
        self.init(toServer: server, withFilter: filter, pageSize: 50)
    }
    
    init(toServer server: Server, withFilter filter: DomainResourceQueryFilter? = nil, pageSize: Int = 50) {
        super.init(toServer: server, withFilter: filter)
        search.pageCount = pageSize
        status = .initialized
    }
    
    func serverRequestToken() -> ServerRequestToken {
        return ServerRequestToken(hasMore: hasMore, token: token)
    }
    
    /**
    Execute the patient query against the given FHIR server and updates the receiver's `patients` property when done.
    
    - parameter fromServer: A FHIRServer instance to query the patients from
    */
    override func retrieve() {
        fetchedList = nil
        expectedNumber = 0
        retrieveBatch()
    }
    
    /**
    Attempt to retrieve the next batch of patients. You should check `hasMore` before calling this method.
    
    - parameter fromServer: A FHIRServer instance to retrieve the batch from
    */
    open func retrieveMore() {
        retrieveBatch(append: true)
    }
    
    func retrieveBatch(append: Bool = false) {
        status = .loading
        execute { [weak self] bundle, error in
            if let this = self {
                if let error = error {
                    print("ERROR running query: \(error)")
                    this.lastStatusError = error
                    callOnMainThread() {
                        this.status = .ready
                    }
                }
                else {
                    var fetchedList: [T]? = nil
                    var expTotal: Int32? = nil
                    
                    // extract the resources from the search result bundle
                    if let bundle = bundle {
                        if let total = bundle.total?.int32 {
                            expTotal = total
                        }
                        
                        if let entries = bundle.entry {
                            let newElements = entries
                                .filter() { $0.resource is T }
                                .map() { $0.resource as! T }
                            
                            let append = append && nil != this.fetchedList
                            fetchedList = append ? this.fetchedList! + newElements : newElements
                        }
                    }
                    
                    callOnMainThread() {
                        if let total = expTotal {
                            this.expectedNumber = UInt(total)
                        }
                        // when patients is nil, only set this.patients to nil if appendPatients is false
                        // otherwise we might reset the list to no patients when hitting a 404 or a timeout
                        if nil != fetchedList || !append {
                            this.fetchedList = fetchedList
                        }
                        this.status = .ready
                    }
                }
            }
        }
    }
    
    
    // MARK: - Server Interaction
    
    /// Reset the search.
    override func reset() {
        super.reset()
        isDone = false
    }
    
    /// Send the search request to the server.
    /// - Parameter callback: Completion block that gets called once a response has been retrieved.
    private func execute(callback: @escaping (SMART.Bundle?, FHIRError?) -> Void) {
        if isDone {
            callback(nil, nil)
            return
        }
        
        let cb: (SMART.Bundle?, FHIRError?) -> Void = { bundle, error in
            if nil != error || nil == bundle {
                callback(nil, error)
            } else {
                self.isDone = !self.search.hasMore
                callback(bundle, nil)
            }
        }
        
        // starting fresh, add sorting URL parameters
        if !isDone && !search.hasMore {
            search.sort = filter?.sortingString
            search.perform(server, callback: cb)
        }
        
        // get next page of results
        else {
            search.nextPage(server, callback: cb)
        }
    }
}
