//
//  ServerRequestProvider.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Marco Festini on 27.04.20.
//  Copyright © 2020 Awesome Technologies Innovationslabor GmbH. All rights reserved.
//

import UIKit
import SMART
import RxSwift

class RemoteDataProvider {
    enum ServerError: Error {
        case runtimeError(String)
    }
    enum ConnectionStatus {
        case connecting
        case connected
        case disconnected
    }
    
    private let serverUrl = "https://tim.amp.institute/hapi-fhir-jpaserver/fhir/"
    private var client: Client?
    
    private var activePagedServerRequests = Dictionary<String, AnyObject>()
    private var activeSimpleServerRequests = Dictionary<String, AnyObject>()
    
    /// Observable to stay informed about the connection status to the server
    let connectionStatus = BehaviorSubject<ConnectionStatus>(value: .disconnected)
    
    // MARK: Handling server connection
    
    /// Connect to the server.
    /// - Parameter complete: Completion block that gets called once the server responses.
    func connect(complete: @escaping (ServerError?) -> ()) {
        guard client?.server == nil else {
            complete(nil)
            return
        }
        
        if let url = URL(string: serverUrl) {
            let server = Server(baseURL: url)
            client = Client(server: server)
            connectionStatus.onNext(.connecting)
            client?.ready(callback: { (error) in
                if let error = error as? FHIRError {
                    let institureError = ServerError.runtimeError("Error connecting to server. \(error.description)")
                    complete(institureError)
                    
                    self.connectionStatus.onNext(.disconnected)
                } else {
                    print("[RemoteDataProvider] Successful login!")
                    self.connectionStatus.onNext(.connected)
                    complete(nil)
                }
            })
        } else {
            let institureError = ServerError.runtimeError("Server URL couldn't be parsed")
            complete(institureError)
        }
    }
    
    // MARK: Creating/Discarding Server Requests
    
    /// Helper function to discard a given server request.
    /// - Parameter serverRequest: Server request to be discarded.
    func discardServerRequest<T: DomainResource>(_ serverRequest: ServerRequest<T>) {
        discardServerRequestToken(serverRequest.token)
    }
    
    /// Discard the given server request token.
    /// - Parameter token: Token to be discarded.
    func discardServerRequestToken(_ token: String) {
        if let request = activeSimpleServerRequests[token] as? ServerRequest ?? activePagedServerRequests[token] as? ServerRequest {
            request.reset()
            activeSimpleServerRequests.removeValue(forKey: token)
            activePagedServerRequests.removeValue(forKey: token)
        }
    }
    
    private func createServerRequest<T: DomainResource>(ofType type: T.Type, withFilter filter: DomainResourceQueryFilter? = nil) -> PagedServerRequest<T>? {
        guard let server = client?.server else {
            return nil
        }
        let serverRequest = PagedServerRequest<T>(toServer: server, withFilter: filter)
        activePagedServerRequests[serverRequest.token] = serverRequest
        return serverRequest
    }
    
    private func createSimpleServerRequest<T: DomainResource>(ofType type: T.Type, withFilter filter: DomainResourceQueryFilter?) -> SimpleServerRequest<T>? {
        guard let server = client?.server else {
            return nil
        }
        let serverRequest = SimpleServerRequest<T>(toServer: server, withFilter: filter)
        activeSimpleServerRequests[serverRequest.token] = serverRequest
        return serverRequest
    }
    
    // MARK: Paging
    
    /// Fetch the next page.
    /// - Parameter token: Token of the server request.
    func nextPage(token: String) {
        guard let serverRequest = activePagedServerRequests[token] as? PagedServerRequest else {
            return
        }
        
        serverRequest.retrieveMore()
    }
    
    // MARK: Fetching resources
    
    /// Fetch a resource with a given id.
    /// - Parameters:
    ///   - resourceType: Resource type to request for.
    ///   - id: Id of the resource.
    ///   - complete: Completion block that gets called once the server responses.
    func fetchResource<T: DomainResource>(_ resourceType: T.Type, withId id: String, _ complete: @escaping (Result<RequestResult<T>, Error>) -> Void) {
        guard let server = client?.server else {
            complete(.failure(FHIRError.error("No server connection")))
            return
        }
        T.read(id, server: server) { (resource, error) in
            if let resource = resource as? T {
                complete(.success(RequestResult(resource)))
            } else if let error = error?.asFHIRError {
                complete(.failure(error))
            }
        }
    }
    
    /// Fetch a list of resource of the given type.
    /// - Parameters:
    ///   - resourceType: Resource type to request for.
    ///   - filter: Filter to apply to the request.
    ///   - pageCount: Size of each page.
    ///   - complete: Completion block that gets called when the server responses.
    func fetchResourceList<T: DomainResource>(_ resourceType: T.Type, filter: DomainResourceQueryFilter? = nil, pageCount: Int? = nil, noCache: Bool = false, _ complete: ((Result<RequestResult<[T]>, Error>) -> Void)? = nil) {
        print("[RemoteDataProvider] Fetching resource list from server")
        
        guard let serverRequest = createServerRequest(ofType: T.self, withFilter: filter) else {
            return
        }
        serverRequest.search.noCache = noCache
        serverRequest.search.pageCount = pageCount
        print("Search query: \(serverRequest.search.construct())")
        
        serverRequest.onStatusUpdate = { error in
            guard serverRequest.status == .ready else {
                return
            }
            if let error = error?.asFHIRError {
                print("[RemoteDataProvider] Error fetching resource list: \(error.localizedDescription)")
                return
            }
            let resources = serverRequest.fetchedList ?? []
            let serverRequestToken = serverRequest.serverRequestToken()
            let result = RequestResult(resources, token: serverRequestToken)
            
            complete?(.success(result))
        }
        serverRequest.retrieve()
    }
    
    /// Fetch the number of resources of a given type.
    /// - Parameters:
    ///   - ofType: Type to filter for.
    ///   - complete: Completion block that gets called once the server has responded.
    func numberOfResources<T: DomainResource>(ofType: T, complete: @escaping (Result<UInt, Error>) -> Void) {
        guard (client?.server) != nil else { return }
        
        let filter = DomainResourceQueryFilter()
        filter.set(filter: .summary(.count))
        
        guard let serverRequest = createServerRequest(ofType: T.self, withFilter: filter) else { return }
        
        serverRequest.onStatusUpdate = { error in
            guard serverRequest.status == .ready else {
                return
            }
            if let error = error?.asFHIRError {
                print("[RemoteDataProvider] Error fetching resource list: \(error.localizedDescription)")
                complete(.failure(error))
                return
            }
            complete(.success(serverRequest.actualNumber))
        }
    }
    
    /// Fetch the number of images for a given observation type.
    /// - Parameters:
    ///   - observationType: Observation type to filter for.
    ///   - complete: Completion block that gets called once the server has responded.
    func numberOfImages(observationType: ObservationType, complete: @escaping (Result<UInt, Error>) -> Void) {
        guard (client?.server) != nil else { return }
        
        let filter = MediaQueryFilter()
        filter.set(filter: .summary(.count))
        filter.set(filter: .modality(observationType.rawValue))
        filter.set(filter: .basedOn())
        
        guard let serverRequest = createServerRequest(ofType: Media.self, withFilter: filter) else { return }
        serverRequest.search.requestOptions = .lenient
        
        serverRequest.onStatusUpdate = { error in
            guard serverRequest.status == .ready else {
                return
            }
            if let error = error?.asFHIRError {
                print("[RemoteDataProvider] Error fetching resource list: \(error.asFHIRError.humanized)")
                complete(.failure(error))
                return
            }
            complete(.success(serverRequest.expectedNumber))
        }
        serverRequest.retrieve()
    }
    
    // MARK: Fetching patient data
    
    /// Fetch a patient with a given id from the server.
    /// - Parameters:
    ///   - id: Id of the patient.
    ///   - complete: Completion block that gets called when the patient resource is ready.
    func fetchPatient(withId id: String, _ complete: @escaping (Result<RequestResult<Patient>, Error>) -> Void) {
        fetchResource(Patient.self, withId: id, complete)
    }
    
    /// Fetch the patient list from the server. Page size is set to 50.
    ///   - complete: Completion block that gets called when the patient list is ready.
    func fetchPatientList(_ complete: @escaping (Result<RequestResult<[Patient]>, Error>) -> Void) {
        fetchResourceList(Patient.self, pageCount: 50, complete)
    }
    
    // MARK: Creating resource on the server
    
    /// Save a resource on the server.
    /// - Parameters:
    ///   - resource: Resource to save on the server.
    ///   - complete: Completion block that gets called once the server has responded.
    func createResourceAndReturn<T: DomainResource>(_ resource: T, _ complete: @escaping (Result<T, Error>) -> Void) {
        guard let server = client?.server else {
            complete(.failure(FHIRError.error("No server connection")))
            return
        }
        
        resource._server = server
        resource.createAndReturn(server) { (error) in
            if let error = error {
                print("Error creating resource on the server: \(error.localizedDescription)")
                complete(.failure(error))
            } else {
                print("Resource was successfully created on the server")
                complete(.success(resource))
            }
        }
    }
}
