//
//  PushNotificationService.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Marco Festini on 26.06.20.
//  Copyright © 2020 Michael Rojkov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PushKit

class PushNotificationService: NSObject, PKPushRegistryDelegate {
    private let CurrentDeviceTokenKey = "current_device_token"
    private let CurrentVoipTokenKey = "current_voip_token"
    
    static let shared = PushNotificationService()
    
    private var bag = DisposeBag()
    
    var observablePushToken: Observable<String?> {
        get {
            return UserDefaults.standard.rx.observe(String.self, CurrentDeviceTokenKey)
        }
    }
    
    var observableVoipToken: Observable<String?> {
        get {
            return UserDefaults.standard.rx.observe(String.self, CurrentVoipTokenKey)
        }
    }
    
    var combinedObservable: Observable<(String?, String?)> {
        get {
            return Observable.combineLatest(observablePushToken, observableVoipToken).asObservable()
        }
    }
    
    private override init() {
        super.init()
    }
    
    /// Setup the observable monitoring changes in either push or voip tokens to update the devices registration on the server.
    func setup() {
        bag = DisposeBag()
        Observable.combineLatest(observablePushToken, observableVoipToken)
            .debounce(.seconds(5), scheduler: MainScheduler.instance)
            .subscribe(onNext: { _ in
                Repository.instance.registerDevice()
            })
            .disposed(by: bag)
    }
    
    func getCurrentDeviceToken() -> String? {
        return UserDefaults.standard.string(forKey: CurrentDeviceTokenKey)
    }
    
    func getCurrentVoipToken() -> String? {
        return UserDefaults.standard.string(forKey: CurrentVoipTokenKey)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //https://forums.developer.apple.com/thread/52224
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        // Checks if a token is still present from the previouse use, and if it is still the same
        if getCurrentDeviceToken() != token {
            UserDefaults.standard.set(token, forKey: CurrentDeviceTokenKey)
        }
        
        print("New Push token: \(token.prefix(8))")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error.localizedDescription)")
    }
    
    // MARK: VoiP Token
    
    // Register for VoIP notifications
    func voipRegistration() {
        let mainQueue = DispatchQueue.main
        // Create a push registry object
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
        // Set the registry's delegate to self
        voipRegistry.delegate = self
        // Set the push type to VoIP
        // This triggers the registration process and should always come last
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        
        let tokenParts = pushCredentials.token.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        
        if getCurrentVoipToken() != token {
            UserDefaults.standard.set(token, forKey: CurrentVoipTokenKey)
        }
        
        print("New Voip Token: \(token.prefix(8))")
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        switch type {
        case .voIP:
            print("[PushNotificationService] Invalidated voip token")
            UserDefaults.standard.set(nil, forKey: CurrentVoipTokenKey)
        default:
            break
        }
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        switch type {
        case .voIP:
            let dict = payload.dictionaryPayload
            print("[PushNotificationService] Received new voip push: \(dict)")
        default:
            break
        }
    }
}
