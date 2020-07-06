//
//  UserLoginCredentials.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 05.05.20.
//  Copyright © 2020 Michael Rojkov. All rights reserved.
//

import Foundation
import SMART
import RxSwift
import RxRelay

protocol UserLoginCredentialsDelegate: class {
    func didUpdateCachedOrganizationIds(newIds: [ProfileType: (organization: String, endpoint: String)])
}

class UserLoginCredentials{
    static let shared = UserLoginCredentials()
    
    weak var delegate: UserLoginCredentialsDelegate?
    
    let deviceId: String
    private let DeviceIdKey = "device_id"
    
    let observableProfile = BehaviorRelay<ProfileType>(value: .NONE)
    var selectedProfile: ProfileType {
        get {
            return observableProfile.value
        }
        set {
            observableProfile.accept(newValue)
        }
    }
    
    /// Dictionary of tuples representing the organization/endpoint combinations for a given profile type present on the server
    private(set) var cachedOrganizationIds: [ProfileType: (organization: String, endpoint: String)] = [:] {
        didSet {
            delegate?.didUpdateCachedOrganizationIds(newIds: cachedOrganizationIds)
        }
    }
    
    /// Ids the user is currently logged into
    var loginIds: (organization: String, endpoint: String)? {
        return cachedOrganizationIds[selectedProfile]
    }
    
    private var bag = DisposeBag()
    
    private init() {
        if let id = UserDefaults.standard.string(forKey: DeviceIdKey) {
            deviceId = id
        } else {
            deviceId = UUID().uuidString
            UserDefaults.standard.setValue(deviceId, forKey: DeviceIdKey)
        }
        
        // Setting up tuple array whenever a connection is established to have it cached locally
        let connectionStatus = Repository.instance.connectionStatus
        let loginStatus = observableProfile.asObservable()
        Observable.combineLatest(connectionStatus, loginStatus)
            .map { (connection, login) in
                return connection == .connected && login != .NONE
        }
        .subscribe(onNext: { register in
            guard register else { return }
            Repository.instance.registerDevice()
        })
            .disposed(by: bag)
    }
    
    func updateCachedOrganizationIds(newIds: [ProfileType: (organization: String, endpoint: String)]) {
        cachedOrganizationIds = newIds
    }
    
    func logout(_ complete: @escaping (() -> Void)) {
        print("[UserLoginCredentials] Logout")
        
        guard let endpointId = loginIds?.endpoint, selectedProfile != .NONE else { return }
        Repository.instance.removeDeviceFromEndpoint(endpointId) { success in
            print("[UserLoginCredentials] Logged out")
            self.selectedProfile = .NONE
            complete()
        }
    }
}


enum ProfileType: String {
    case PeripheralClinic = "peripheralClinic"
    case ConsultationClinic = "consultationClinic"
    case NONE
    
    func other() -> ProfileType {
        switch self {
        case .ConsultationClinic:
            return .PeripheralClinic
        case .PeripheralClinic:
            return .ConsultationClinic
        default:
            return .NONE
        }
    }
}
