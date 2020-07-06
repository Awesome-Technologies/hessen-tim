//
//  Repository.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Marco Festini on 27.04.20.
//  Copyright © 2020 Awesome Technologies Innovationslabor GmbH. All rights reserved.
//

import UIKit
import FHIR
import RxSwift
import RxRelay

/// This class provides access to cached and remote data.
class Repository {
    /// The local echo store. This is where resources are saved in before the server responded.
    private let localEchoStore = LocalEchoStore()
    /// The local cache.
    private let cacheProvider = CacheProvider()
    /// The remote data provider. This requests resources from the server.
    private let remoteDataProvider = RemoteDataProvider()
    
    /// Passthrough observable of remot data provider connection status
    var connectionStatus: Observable<RemoteDataProvider.ConnectionStatus> {
        return remoteDataProvider.connectionStatus.asObservable()
    }
	
    /// The shared repository instance.
    static let instance = Repository()
    
    let bag = DisposeBag()
	
    /// Setup the connection to the remote server.
    /// - Parameter complete: completion block that gets called if the connection was setup successfully.
    func setup(complete: @escaping () -> Void) {
        remoteDataProvider.connect { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                complete()
            }
        }
    }
    
    /// Get the observable for the given type. Use this to get notified should the cached list of items for this type gets altered.
    /// - Parameter type: The type for which a observable get sreturned.
    func getObservable<T: DomainResource>(forType type: T.Type) -> Observable<[T]> {
        let cacheAlreadyExisted = cacheProvider.exists(ofType: T.self)
        let cache = cacheProvider.cache(forType: T.self)
        let cacheObservable = cache.observable
        
        let observable = Observable.combineLatest(cacheObservable, localEchoStore.observable).map { (_, _) -> [T] in
            var result = [T]()
            
            result.append(contentsOf: cache.getCachedObjects())
            let echoes = self.localEchoStore.allResources(ofType: T.self)
            result.append(contentsOf: echoes)
            
            return result
        }
        
        if !cacheAlreadyExisted {
            // Cache was freshly populated, so we want to
            // fetch a first set of resources from the server
            getAllResources(ofType: T.self, true, pageCount: 50) { result in
                switch result {
                case .success(let requestResult):
                    if let patientList = requestResult.resultValue as? [Patient] {
                        for patient in patientList {
                            self.getAllServiceRequestsForPatient(patient: patient)
                            self.getAllDiagnosticReportsForPatient(patient: patient)
                        }
                    }
                case .failure(_): break
                }
            }
        }
        
        return observable
    }
    
    /// Helper function that replaces the local echo resource with the actual resource (returned by the server).
    /// - Parameter resource: The new resource.
    private func replaceLocalEcho<T: DomainResource>(withResource resource: T) {
        localEchoStore.remove(resource: resource)
        cacheProvider.cache(forType: T.self).insert(resource)
    }
    
    // MARK: Writing
    
    /// Save the resource. This function turns it into a local echo and saves it as such. Then the resource will be saved on the server.
    /// Once the server responses with the actual resource, it will be saved in cache properly.
    /// To get notified when that happens, use the Observable provided by the getObservable function.
    /// - Parameter resource: Resource to save.
    func saveResource<T: DomainResource>(_ resource: T) {
        resource.makeLocalEcho()
        localEchoStore.add(resource: resource)
        
        remoteDataProvider.createResourceAndReturn(resource) { (result) in
            switch result {
            case .success(let newResource):
                self.replaceLocalEcho(withResource: newResource)
                self.update(resource: newResource)
            case .failure(let error):
                print("Error creating resource on server \(error.asFHIRError.humanized)")
            }
        }
    }
    
    /// Helper function to save a list of resources on the server. See saveResources(:)
    /// - Parameter resources: List of resources to save.
    func saveResources<T: DomainResource>(_ resources: [T]) {
        resources.forEach { (resource) in
            saveResource(resource)
        }
    }
    
    // MARK: Retry saving resources
    
    /// Send all unsent resources. Because local echoes are considered not available on the server,
    /// this function goes through them all and tries to resend them.
    func sendUnsentResources() {
        let resources = localEchoStore.allResources()
        saveResources(resources)
    }
    
    // MARK: Updating
    
    /// Update a resource on the server. Since it has changed, the resource will be saved as a local echo again.
    /// One the response from the server comes, the local echo will be removed and saved in cache as before.
    /// - Parameter resource: The updated resource.
    func update<T: DomainResource>(resource: T, _ success: (() -> ())? = nil) {
        if let id = resource.id?.string {
            cacheProvider.cache(forType: T.self).removeValue(forKey: id as NSString)
        }
        localEchoStore.add(resource: resource)
        
        resource.update { (error) in
            guard let error = error else {
                // The resource was successfully update, so we can store it in cache again
                self.replaceLocalEcho(withResource: resource)
                success?()
                return
            }
            print("Error updating resource \(error.asFHIRError.humanized)")
        }
    }
    
    // MARK: Reading
    
    /// Helper function to get a list of media resources for a given observation type.
    /// - Parameters:
    ///   - type: Observation type for which to filter media resources.
    ///   - forceDownload: Whether to skip local cache.
    ///   - complete: Completion block that gets called once the response is ready.
    func getMediaList(ofObservationType type: ObservationType, forceDownload: Bool = false, complete: @escaping (Result<RequestResult<[Media]>, Error>) -> Void) {
        let filter = MediaQueryFilter()
        filter.set(filter: .modality(type.rawValue))
        
        getAllResources(ofType: Media.self, filter: filter, pageCount: 10) { (result) in
            complete(result)
        }
    }
    
    /// Helper function to get a list of media resources for a given observation type and patient.
    /// - Parameters:
    ///   - type: Observation type for which to filter media resources.
    ///   - date: Filter out resources created later than this date.
    ///   - patient: The patient the resource has to refer to (see subject).
    ///   - forceDownload: Whether to skip local cache.
    ///   - complete: Completion block that gets called once the response is ready.
    func getMediaList(ofObservationType type: ObservationType, notNewerThan date: DateTime, forPatient patient: Patient, forceDownload: Bool = false, complete: @escaping (Result<RequestResult<[Media]>, Error>) -> Void) {
        guard let patientId = patient.id?.string else { return }
        let filter = MediaQueryFilter()
        
        let subject: [String: Any] = ["subject": ["$type": Patient.resourceType, "_id": patientId]]
        
        filter.set(filter: .basedOn(subject))
        filter.set(filter: .modality(type.rawValue))
        filter.set(filter: .summary(.true))
        filter.set(filter: .sort("created"))
        filter.set(filter: .created("$le", date))
        
        getAllResources(ofType: Media.self, filter: filter, pageCount: 10) { (result) in
            complete(result)
        }
        
        
    }
    
    // MARK: Number of resources
    
    /// Get the number of resources for a given type.
    /// If there are no resources in local cache, a server request will be sent.
    /// - Parameters:
    ///   - type: Type for which to get the number of available resources.
    ///   - complete: Completion block that gets called once the count is ready.
    func numberOfResources<T: DomainResource>(ofType type: T, complete: @escaping (Result<UInt, Error>) -> Void) {
        var count: UInt = UInt(localEchoStore.allResources().count)
        count += cacheProvider.cache(forType: T.self).numberOfObjects()
        if count == 0 {
            remoteDataProvider.numberOfResources(ofType: type.self, complete: complete)
        } else {
            complete(.success(count))
        }
    }
    
    /// Get the number of images for a given observation type.
    /// - Parameters:
    ///   - observationType: Observation type for which to get the number of available images.
    ///   - complete: Completion block that gets called once the count is ready.
    func numberOfImages(withObservationType obsType: ObservationType, complete: @escaping (Result<UInt, Error>) -> Void) {
        var count = UInt(localEchoStore.allResources().count)
        count += UInt(cacheProvider.cache(forType: Media.self).numberOfObjects())
        if count == 0 {
            remoteDataProvider.numberOfImages(observationType: obsType, complete: complete)
        } else {
            complete(.success(count))
        }
    }
    
    // MARK: Convenience Methods
    
    /// Get the patient for the given id.
    /// - Parameters:
    ///   - id: The id of the patient.
    ///   - forceDownload: Whether to skip local cache.
    ///   - complete: Completion block that gets called once the patient resource is ready.
    func getPatient(withId id: String, forceDownload: Bool = false, complete: @escaping (Result<RequestResult<Patient>, Error>) -> Void) {
        getResource(Patient.self, withId: id, complete: complete)
    }
    
    /// Get all patients.
    /// - Parameters:
    ///   - forceDownload: Whether to skip local cache.
    ///   - complete: Completion block thtat gets called once the patient list is ready.
    func getAllPatients(_ forceDownload: Bool = false, complete: @escaping (Result<RequestResult<[Patient]>, Error>) -> Void) {
        getAllResources(forceDownload, filter: nil, complete: complete)
    }
    
    // MARK: Patient History
    
    /// Update the cached ServiceRequest with the given Id with the Resource saved remotely.
    /// - Parameters:
    ///   - id: Id of the ServiceRequest to update.
    ///   - complete: Completion block thtat gets called once the ServiceRequest has been fetched.
    func updateServiceRequestFromServer(withId id: String, complete: @escaping (Result<ServiceRequest, Error>) -> Void) {
        remoteDataProvider.fetchResource(ServiceRequest.self, withId: id) { [unowned self] (result) in
            switch result {
            case .success(let requestResult):
                self.replaceLocalEcho(withResource: requestResult.resultValue)
                complete(.success(requestResult.resultValue))
            case .failure(let error):
                print("Error getting service request: \(error.humanized)")
                complete(.failure(error))
            }
        }
    }
    
    /// Get all service requests for a given patient.
    /// - Parameters:
    ///   - patient: The patient to get the service requests for.
    ///   - completion: Completion block that gets called once the service requests are ready.
    func getAllServiceRequestsForPatient(patient: Patient, completion: ((Result<[ServiceRequest], Error>) -> Void)? = nil) {
        var serviceRequests = localEchoStore.allResources() as? [ServiceRequest] ?? [ServiceRequest]()
        let cache = cacheProvider.cache(forType: ServiceRequest.self)
        serviceRequests += cache.getCachedObjects()
        serviceRequests = serviceRequests.filter( {$0.subject?.reference?.string.digitString == patient.id?.string && $0.status?.rawValue == "active"} )
        serviceRequests.sort { (srl, srr) -> Bool in
            guard let authoredLeft = srl.authoredOn, let authoredRight = srr.authoredOn else {
                return false
            }
            return authoredLeft.nsDate.compare(authoredRight.nsDate) == .orderedDescending
        }
        if serviceRequests.isEmpty, let patientId = patient.id?.string {
            let filter = ServiceRequestQueryFilter()
            filter.set(filter: .sort("authored"))
            filter.set(filter: .subject(type: Patient.self, id: patientId))
            filter.set(filter: .status(.active))
            remoteDataProvider.fetchResourceList(ServiceRequest.self, filter: filter) { (result) in
                switch result {
                case .success(let requestResult):
                    cache.insertList(requestResult.resultValue)
                    completion?(.success(requestResult.resultValue))
                case .failure(let error):
                    completion?(.failure(error))
                }
            }
        } else {
            completion?(.success(serviceRequests))
        }
    }
    
    /// Get all diagnostic reports for a given patient.
    /// - Parameters:
    ///   - patient: The patient to get the diagnostic reports for.
    ///   - completion: Completion block that gets called once the diagnostic reports are ready.
    func getAllDiagnosticReportsForPatient(patient: Patient, completion: ((Result<[DiagnosticReport], Error>) -> Void)? = nil) {
        var diagnosticReports = localEchoStore.allResources() as? [DiagnosticReport] ?? [DiagnosticReport]()
        let cache = cacheProvider.cache(forType: DiagnosticReport.self)
        
        diagnosticReports += cache.getCachedObjects()
        diagnosticReports = diagnosticReports.filter( {$0.subject?.reference?.string.digitString == patient.id?.string && $0.subject?.reference?.string.starts(with: ServiceRequest.resourceType) ?? false} )
        diagnosticReports.sort { (drl, drr) -> Bool in
            guard let issuedLeft = drl.issued, let issuedRight = drr.issued else {
                return false
            }
            return issuedLeft.nsDate.compare(issuedRight.nsDate) == .orderedDescending
        }
        
        if diagnosticReports.isEmpty, let patientId = patient.id?.string {
            let filter = DomainResourceQueryFilter()
            let subject: [String: Any] = ["subject": (ServiceRequest.self, "\(Patient.resourceType)._id", patientId)]
            filter.set(filter: .basedOn(subject))
            filter.set(filter: .sort("issued"))
            remoteDataProvider.fetchResourceList(DiagnosticReport.self, filter: filter) { (result) in
                switch result {
                case .success(let requestResult):
                    cache.insertList(requestResult.resultValue)
                    completion?(.success(requestResult.resultValue))
                case .failure(let error):
                    completion?(.failure(error))
                }
            }
        } else {
            completion?(.success(diagnosticReports))
        }
    }
    
    /// Get the observable for the history of a given patient.
    /// The history consists of service requests and diagnostic reports.
    /// - Parameter patient: The patient for which to get the observable for.
    /// - Returns: Observable for the history of a patient.
    func getHistoryObservable(forPatient patient: Patient) -> Observable<[DomainResource]> {
        let diagnosticObservable = getObservable(forType: DiagnosticReport.self)
        let serviceObservable = getObservable(forType: ServiceRequest.self)
        return Observable.combineLatest(diagnosticObservable, serviceObservable)
            .map({ (reports, requests) -> [DomainResource] in
                var result = [DomainResource]()
                guard let patientId = patient.id?.string else {
                    return result
                }
                result.append(contentsOf: requests.filter({
                    $0.subject?.reference?.string == "\(Patient.resourceType)/\(patientId)"
                }))
                var srWithDiagnosticReport = [String]()
                result.forEach { (resource) in
                    guard resource is ServiceRequest else {return}
                    result.append(contentsOf: reports.filter({
                        guard let id = resource.id?.string else { return false }
                        if $0.basedOn?.first?.reference?.string == "\(ServiceRequest.resourceType)/\(id)" {
                            srWithDiagnosticReport.append(id)
                            return true
                        }
                        return false

                    }))
                }
                result.removeAll(where:{srWithDiagnosticReport.contains($0.id?.string ?? "")})
                
                return result
            })
            .map({ (resources) -> [DomainResource] in
                return resources.sorted { (drl, drr) -> Bool in
                    guard let dateLeft = (drl as? DiagnosticReport)?.issued?.nsDate ?? (drl as? ServiceRequest)?.authoredOn?.nsDate,
                        let dateRight = (drr as? DiagnosticReport)?.issued?.nsDate ?? (drr as? ServiceRequest)?.authoredOn?.nsDate else {
                            return false
                    }
                    return dateLeft.compare(dateRight) == .orderedDescending
                }
            })
            .asObservable()
    }
    
    // MARK: Generic methods to fetch data
    
    /// Get cached resource for the given id.
    /// - Parameter id: Id of the resource.
    func getCachedResource<T: DomainResource>(withId id: String) -> T? {
        let cache = self.cacheProvider.cache(forType: T.self)
        return cache.value(forKey: id as NSString)
    }
    
    /// Get the cached resources of a given type.
    /// - Parameters:
    ///   - type: Type of the resources.
    ///   - filter: filter to apply.
    func getCachedResourceList<T: DomainResource>(ofType type: T.Type? = nil, filter: DomainResourceQueryFilter? = nil) -> [T] {
        let cache = self.cacheProvider.cache(forType: T.self)
        var result = self.localEchoStore.allResources(ofType: T.self)
        result.append(contentsOf: cache.getCachedObjects())
        if let filter = filter {
            result = filter.filter(resources: result)
        }
        
        return result
    }
    
    /// Get the resource of a given type with the given id.
    /// - Parameters:
    ///   - resourceType: The resource type.
    ///   - id: The id of the requested resource.
    ///   - forceDownload: Whether to skip local cache.
    ///   - complete: The completion block that gets called once the resource is ready.
    func getResource<T: DomainResource>(_ resourceType: T.Type, withId id: String, forceDownload: Bool = false, complete: @escaping (Result<RequestResult<T>, Error>) -> Void) {
        guard !id.isEmpty else {
            complete(.failure(FHIRError.error("Invalid id")))
            return
        }
        let cache = self.cacheProvider.cache(forType: resourceType)
        let idString = id as NSString
        if !forceDownload, let echo = localEchoStore[id] as? T {
            complete(.success(RequestResult(echo)))
        } else if !forceDownload, let resource = cache[idString] {
            print("[Repository] getResource : fetched from cache")
            complete(.success(RequestResult(resource)))
        } else {
            print("[Repository] getResource : fetching from server")
            remoteDataProvider.fetchResource(resourceType, withId: id) { (result) in
                switch result {
                case .success(let requestResult):
                    cache[idString] = requestResult.resultValue
                case .failure(_): break
                }
                complete(result)
            }
        }
    }
    
    /// Get all resources of a given type.
    /// - Parameters:
    ///   - type: The type of the resource.
    ///   - forceDownload: Whether to skip local cache.
    ///   - filter: The filter to be applied.
    ///   - pageCount: How many resources are returned per page. Only applies to server requests.
    ///   - complete: Completion block that gets called once the resources are ready.
    func getAllResources<T: DomainResource>(ofType type: T.Type? = nil, _ forceDownload: Bool = false, filter: DomainResourceQueryFilter? = nil, pageCount: Int? = nil, complete: ((Result<RequestResult<[T]>, Error>) -> Void)? = nil) {
        var array = [T]()
        let cache = cacheProvider.cache(forType: T.self)
        if !forceDownload, let echoes = localEchoStore.allResources() as? [T] {
            array.append(contentsOf: echoes)
        }
        if !forceDownload, cache.hasCachedObjects() {
            array.append(contentsOf: cache.getCachedObjects())
        }
        
        if let newArray = filter?.filter(resources: array) {
            array = newArray
        }
        
        if array.isEmpty {
            remoteDataProvider.fetchResourceList(T.self, filter: filter, pageCount: pageCount, noCache: forceDownload) { result in
                switch result {
                case .success(let requestResult):
                    array.append(contentsOf: requestResult.resultValue)
                    cache.insertList(requestResult.resultValue)
                case .failure(_): break
                }
                complete?(result)
            }
        } else {
            complete?(.success(RequestResult(array)))
        }
    }
    
    // MARK: Device Registration
    
    /// Fetch the given Endpoint from the server to remove all ContactPoint instances for this device
    /// - Parameters:
    ///   - endpointId: Id of the Endpoint to alter
    ///   - completion: Completion block that gets called upon completion. The boolean indicates whether the Endpoint was fetch successfully to check for the device id.
    func removeDeviceFromEndpoint(_ endpointId: String, completion: @escaping ((Bool) -> Void)) {
        let filter = DomainResourceQueryFilter()
        filter.set(filter: .id(endpointId))
        remoteDataProvider.fetchResourceList(Endpoint.self, filter: filter, pageCount: 1, noCache: true) { result in
            switch result {
            case .success(let requestResult):
                guard let endpoint = requestResult.resultValue.first else { return }
                var contacts = endpoint.contact ?? [ContactPoint]()
                let deviceEndpointData = EndpointData.current()
                var didChange = false
                
                contacts.removeAll { contactPoint -> Bool in
                    guard let json = contactPoint.value?.string.data(using: .utf8), let contactEndpointData = EndpointData.from(json: json) else { return false }
                    let remove = deviceEndpointData.deviceId == contactEndpointData.deviceId
                    if remove {
                        didChange = true
                    }
                    return remove
                }
                endpoint.contact = contacts
                if didChange {
                    self.update(resource: endpoint)
                }
                completion(true)
            case .failure(let error):
                print("Error fetching Endpoints from the server: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    /// Register this device on the server given the device is logged in
    func registerDevice() {
        guard let loginEndpoint = UserLoginCredentials.shared.loginIds?.endpoint else {
            return
        }
        let deviceEndpointData = EndpointData.current()
        
        UserLoginCredentials.shared.cachedOrganizationIds.forEach { (key: ProfileType, value: (organization: String, endpoint: String)) in
            
            let filter = DomainResourceQueryFilter()
            filter.set(filter: .id(value.endpoint))
            remoteDataProvider.fetchResourceList(Endpoint.self, filter: filter, pageCount: 1, noCache: true) { result in
                let isLoginEndpoint = value.endpoint == loginEndpoint
                switch result {
                case .success(let requestResult):
                    guard let endpoint = requestResult.resultValue.first else { return }
                    var didChange = false
                    var contacts = endpoint.contact ?? [ContactPoint]()
                    contacts.removeAll { contactPoint -> Bool in
                        guard let json = contactPoint.value?.string.data(using: .utf8), let contactEndpointData = EndpointData.from(json: json) else { return false }
                        let remove = deviceEndpointData.deviceId == contactEndpointData.deviceId
                        if remove {
                            didChange = true
                        }
                        return remove
                    }
                    if isLoginEndpoint, let json = deviceEndpointData.toJson() {
                        let contactPoint = ContactPoint()
                        contactPoint.value = FHIRString(json)
                        contactPoint.use = .work
                        contactPoint.system = .other
                        contacts.append(contactPoint)
                        didChange = true
                    }
                    endpoint.contact = contacts
                    if didChange {
                        self.update(resource: endpoint)
                    }
                case .failure(let error):
                    print("Error fetching Endpoints from the server: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Fetch the organizations from the server and cache them in UserLoginCredetials.cachedOrganizationIds
    func cacheOrganizationIds() {
        remoteDataProvider.fetchResourceList(Organization.self , noCache: true) { result in
            let credentials = UserLoginCredentials.shared
            var cachedIds:  [ProfileType: (organization: String, endpoint: String)] = [:]
            switch result {
            case .success(let requestResult):
                requestResult.resultValue.forEach { org in
                    guard let id = org.id?.string, let endpointId = org.endpoint?.first?.reference?.string.split(separator: "/")[1] else { return }
                    let tuple = (id, String(endpointId))
                    
                    let profileTypeString = org.type?.first?.text?.string
                    if profileTypeString == ProfileType.ConsultationClinic.rawValue {
                        cachedIds[.ConsultationClinic] = tuple
                    } else if profileTypeString == ProfileType.PeripheralClinic.rawValue {
                        cachedIds[.PeripheralClinic] = tuple
                    }
                }
                credentials.updateCachedOrganizationIds(newIds: cachedIds)
            case .failure(let error):
                print("Error fetching Organizations from the server: \(error.localizedDescription)")
            }
        }
    }
    
}
