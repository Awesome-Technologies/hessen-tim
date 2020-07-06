//
//  AppDelegate.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 13.03.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import UserNotifications
import SMART
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var splitView = false
    
    var observID = ObservationType.NONE
    
    private var autoLoginBag = DisposeBag()
    
    func goToLoginScreen(animated: Bool) {
        
        if let window = self.window {
            var newRootViewController: UIViewController? = nil
            var transition: UIView.AnimationOptions
            
            let loginViewController = window.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginScreenViewController
            
            newRootViewController = loginViewController
            transition = .transitionCurlUp
            
            // update app's rootViewController
            if let rootVC = newRootViewController {
                if animated {
                    UIView.transition(with: window, duration: 0.5, options: transition, animations: { () -> Void in
                        window.rootViewController = rootVC
                    }, completion: nil)
                } else {
                    window.rootViewController = rootVC
                }
            }
        }
        
        
    }
    
    //https://stackoverflow.com/questions/4213097/best-way-to-switch-between-uisplitviewcontroller-and-other-view-controllers/25979945#25979945
    func setupRootViewController(animated: Bool, withPatient patient: Patient? = nil, andServiceRequest serviceRequest: ServiceRequest? = nil) {
        if let window = self.window {
            var newRootViewController: UIViewController? = nil
            var transition: UIView.AnimationOptions
            if !splitView {
                /*
                let loginViewController = window.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "SecondScreen") as! SecondScreenViewController
                newRootViewController = loginViewController
                transition = .transitionFlipFromLeft
                */
                let loginViewController = window.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "sceneNavController") as! UINavigationController
                
                //initiate the insertPatietData and medicalData view controllers
                let insertPatientData = window.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "insertPatientDataVC") as! UIViewController
                let medicalData = window.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "medicalDataVC") as! MedicalDataViewController
                
                //Place the insertPatietData and medicalData vc on the navigation stack of the navigationController, so you will be transitioned back to the medicalDataVC
                loginViewController.pushViewController(insertPatientData, animated: true)
                loginViewController.pushViewController(medicalData, animated: true)
                newRootViewController = loginViewController
                transition = .transitionFlipFromLeft
                
                medicalData.patient = patient
                medicalData.serviceRequest = serviceRequest
            } else {
                let medicalData = window.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "medicalDataVC") as! MedicalDataViewController
                //let splitViewController = window.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "SplitVC") as! UISplitViewController
                let splitViewController = window.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "SplitVC") as! SplitViewController
                let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
                navigationController.topViewController?.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
                
                let masterNavigationController = splitViewController.viewControllers[0] as! UINavigationController
                let detailsNavigationController = splitViewController.viewControllers.last as? UINavigationController
                let masterViewCOntroller = masterNavigationController.topViewController as! MasterViewController
                let detailViewController = detailsNavigationController?.topViewController as! BaseViewController
                
                newRootViewController = splitViewController
                transition = .transitionFlipFromRight
                
                splitView = false
                
                detailViewController.observationType = observID
                
                medicalData.patient = patient
                medicalData.serviceRequest = serviceRequest
                //print("In APPdelegate I push the Value:" + String(splitViewController.selectedCategory.description))
                
            }
            // update app's rootViewController
            if let rootVC = newRootViewController {
                if animated {
                    UIView.transition(with: window, duration: 0.5, options: transition, animations: { () -> Void in
                        window.rootViewController = rootVC
                    }, completion: nil)
                } else {
                    window.rootViewController = rootVC
                }
            }
            
        }}

    //Handle Push Notifications, when app is not running
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Repository.instance.setup {
            Repository.instance.cacheOrganizationIds()
        }
        application.registerForRemoteNotifications()
        
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        authorizeNotifications()
        // Check if launched from notification
        let notificationOption = launchOptions?[.remoteNotification]
        
        //If your app wasn’t running and the user launches it by tapping the push notification
        if let userInfo = notificationOption as? [String: AnyObject] {
            UserLoginCredentials.shared.observableProfile
                .timeout(.seconds(3), scheduler: MainScheduler.instance)
                .subscribe(onNext: { profileType in
                    // Only process notification if the user is logged in automatically
                    guard profileType != .NONE else { return }
                    self.processNotification(withUserinfo: userInfo)
                    self.autoLoginBag = DisposeBag()
                }, onError: { error in
                    // We abort the attempt to process the notification
                    print(error.localizedDescription)
                })
                .disposed(by: autoLoginBag)
        }
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //https://www.raywenderlich.com/8164-push-notifications-tutorial-getting-started
    func authorizeNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                granted, error in
                
                print("Permission granted: \(granted)")
                
        }
    }
    
    func application(_ application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PushNotificationService.shared.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication,didFailToRegisterForRemoteNotificationsWithError error: Error) {
        PushNotificationService.shared.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
    
}

//https://www.ably.io/tutorials/ios-push-notifications#step6-register-device-for-push
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    //Handle Push Notifications, when App is in Background or running in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard UserLoginCredentials.shared.selectedProfile != .NONE else {
            completionHandler()
            return
        }
        let userInfo = response.notification.request.content.userInfo
        processNotification(withUserinfo: userInfo)
        completionHandler()
    }
    
    func processNotification(withUserinfo userInfo: [AnyHashable : Any]) {
        guard let aps = userInfo["aps"] as? [String: AnyObject] else { return }

        // Determine what kind of Push Notification was received
        let alert = aps["alert"] as? [AnyHashable: Any]
        guard let type = alert?["loc-key"] as? String else { return }

        if type.starts(with: "CASE_") {
            print("ServiceRequest Push Notification")
            if let sound = aps["sound"] as? String,
                let patientID = aps["patient"] as? String,
                let serviceRequestID = aps["serviceRequest"] as? String {
                print("sound \(sound)")
                print("patient \(patientID)")
                print("serviceRequest \(serviceRequestID)")
                Repository.instance.getResource(ServiceRequest.self, withId: serviceRequestID.digitString) { serviceResult in
                    switch serviceResult {
                    case .success(let requestResult):
                        Repository.instance.getPatient(withId: patientID.digitString) { patientResult in
                            switch patientResult {
                            case .success(let patientRequestResult):
                                let serviceRequest = requestResult.resultValue
                                let patient = patientRequestResult.resultValue
                                DispatchQueue.main.async {
                                    self.setupRootViewController(animated: false, withPatient: patient, andServiceRequest: serviceRequest)
                                }
                            case .failure(_): break
                            }
                        }
                    case .failure(_): break
                    }
                }
            } else {
                print("Invalid Push Notification: \(aps)")
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("[LOCALLOG] Your device just received a notification!")
        // Show the notification alert in foreground
        completionHandler([.alert, .sound, .badge])
    }
}

