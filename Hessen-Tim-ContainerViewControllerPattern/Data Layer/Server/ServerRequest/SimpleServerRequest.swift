//
//  SimpleServerRequest.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Marco Festini on 04.05.20.
//  Copyright © 2020 Awesome Technologies Innovationslabor GmbH. All rights reserved.
//

import UIKit
import SMART

class SimpleServerRequest<T: DomainResource>: ServerRequest<T> {
    
    /// Start the process of sending a request to the server.
    override func retrieve() {
        search.perform(server) { (bundle, error) in
            if let error = error {
                self.completeBlock?(.failure(error.asFHIRError))
                print(error.asFHIRError.localizedDescription)
                return
            }
            guard bundle?.entry?.count != 0 else {
                let error = FHIRError.error("Couldn't find resource for query \(self.search.construct())")
                self.completeBlock?(.failure(error))
                return
            }
            let entries = bundle?.entry?
                .filter() { return $0.resource is T }
                .map() { return $0.resource as! T }
            
            guard let entry = entries?.first else {
                let error = FHIRError.error("Error casting entry after query \(self.search.construct())")
                self.completeBlock?(.failure(error))
                return
            }
            
            self.completeBlock?(.success(RequestResult(entry)))
        }
    }
}
