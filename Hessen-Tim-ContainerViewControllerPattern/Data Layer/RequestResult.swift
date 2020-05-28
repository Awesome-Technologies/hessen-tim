//
//  RequestResult<T>.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Marco Festini on 27.04.20.
//  Copyright © 2020 Awesome Technologies Innovationslabor GmbH. All rights reserved.
//

import UIKit

struct ServerRequestToken {
    /// Indicating if the server has more resources/pages.
    let hasMore: Bool
    /// The token used as a reference for this request.
    let token: String
}

struct RequestResult<T> {
    /// The result of the request.
    let resultValue: T
    /// Use this token to request the next page from the server.
    let requestToken: ServerRequestToken?
    
    init(_ result: T, token: ServerRequestToken? = nil) {
        resultValue = result
        requestToken = token
    }
}
