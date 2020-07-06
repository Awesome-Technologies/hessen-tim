//
//  EndpointData.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Marco Festini on 05.08.20.
//  Copyright © 2020 Michael Rojkov. All rights reserved.
//

import Foundation

struct EndpointData: Codable {
    var deviceId: String
    var pushToken: String
    var voipToken: String
    
    func toJson() -> String? {
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let json = try encoder.encode(self)
            return String(data: json, encoding: .utf8)
        } catch {
            print("[EndpointData] - Error creating json \(self)")
        }
        return nil
    }
    
    static func from(json: Data) -> EndpointData? {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(EndpointData.self, from: json)
        } catch {
            if let string = String(data: json, encoding: .utf8) {
                print("[EndpointData] - Error creating instance from json \(string))")
            } else {
                print("[EndpointData] - Error creating instance from json")
            }
        }
        return nil
    }
    
    /// Create EndpointData instance filled with the device id and the current push and voip tokens set
    /// - Returns: Filled EndpointData instance
    static func current() -> EndpointData {
        let pushService = PushNotificationService.shared
        return EndpointData(deviceId: UserLoginCredentials.shared.deviceId,
                            pushToken: pushService.getCurrentDeviceToken() ?? "",
                            voipToken: pushService.getCurrentVoipToken() ?? "")
    }
}
