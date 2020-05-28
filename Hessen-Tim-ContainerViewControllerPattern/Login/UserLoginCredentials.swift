//
//  UserLoginCredentials.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 05.05.20.
//  Copyright © 2020 Michael Rojkov. All rights reserved.
//

import Foundation
import SMART

class UserLoginCredentials{
    static let shared = UserLoginCredentials()

    private init(){}
    
    var selectedProfile:ProfileType = .NONE
    var organizationProfile:Organization? = nil
    var performerOrganizationProfile:Organization? = nil
    var endpointProfile:Endpoint? = nil
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
    
    func clinic() -> String {
        return rawValue
    }
    
    func performer() -> String {
        return other().clinic()
    }
}
