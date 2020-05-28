//
//  ServerRequest.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Marco Festini on 05.05.20.
//  Copyright © 2020 Awesome Technologies Innovationslabor GmbH. All rights reserved.
//

import UIKit
import SMART

class ServerRequest<T: DomainResource>: NSObject {
    let server: Server
    var search: FHIRSearch
    var filter: DomainResourceQueryFilter? {
        didSet {
            let oldPageCount = search.pageCount
            search = T.search(filter?.constructQuery() ?? "")
            search.pageCount = oldPageCount
            print("Constructed search: \(search.construct())")
        }
    }
    var completeBlock: ((Result<RequestResult<T>, Error>) -> Void)?
    
    let token = "ServerRequest-" + ProcessInfo.processInfo.globallyUniqueString
    
    init(toServer server: Server, withFilter filter: DomainResourceQueryFilter? = nil) {
        self.server = server
        search = T.search(filter?.constructQuery() ?? "")
        self.filter = filter
    }
    
    func reset() {
        completeBlock = nil
    }
    
    open func retrieve() {
        preconditionFailure("This function ought to be overriden")
    }
}
