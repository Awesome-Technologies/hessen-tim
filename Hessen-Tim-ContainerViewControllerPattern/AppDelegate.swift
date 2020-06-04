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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var splitView = false
    
    var observID = ObservationType.NONE
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        setupRootViewController(animated: false)
        return true
    }
    
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
    func setupRootViewController(animated: Bool) {
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
                let medicalData = window.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "medicalDataVC") as! UIViewController
                
                //Place the insertPatietData and medicalData vc on the navigation stack of the navigationController, so you will be transitioned back to the medicalDataVC
                loginViewController.pushViewController(insertPatientData, animated: true)
                loginViewController.pushViewController(medicalData, animated: true)
                newRootViewController = loginViewController
                transition = .transitionFlipFromLeft
            
            }else{
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
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        registerForPushNotifications()
        // Check if launched from notification
        let notificationOption = launchOptions?[.remoteNotification]
        
        //If your app wasn’t running and the user launches it by tapping the push notification
        if let notification = notificationOption as? [String: AnyObject],
            let aps = notification["aps"] as? [String: AnyObject] {
            Institute.shared.connect { error in
                if error == nil {
                    Institute.shared.openMedicalDataFromNotification(notification: aps, completion: {
                        DispatchQueue.main.async {
                            self.setupRootViewController(animated: false)
                        }
                    })
                }
            }
            
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
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                [weak self] granted, error in
                
                print("Permission granted: \(granted)")
                guard granted else { return }
                self?.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        print("Notification settings: \(settings)")
        
        guard settings.authorizationStatus == .authorized else { return }
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
        
      }
    }
    
    func application(_ application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //https://forums.developer.apple.com/thread/52224
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        /**
         Checks if a token is still present from the previouse use, and if it is still the same
         */
        if let oldPushDeviceToken = UserDefaults.standard.string(forKey: "current_device_token"){
            if(oldPushDeviceToken != token){
                UserDefaults.standard.set(token, forKey: "current_device_token")
            }
        } else {
            UserDefaults.standard.set(token, forKey: "current_device_token")
        }
        print("User default Token: \(UserDefaults.standard.string(forKey: "current_device_token"))")
    }
    
    func application(_ application: UIApplication,didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
}

//https://www.ably.io/tutorials/ios-push-notifications#step6-register-device-for-push
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    //Handle Push Notifications, when App is in Background or running in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let aps = userInfo["aps"] as? [String: AnyObject]{
            Institute.shared.connect { error in
                if error == nil {
                    Institute.shared.openMedicalDataFromNotification(notification: userInfo, completion: {
                        DispatchQueue.main.async {
                            self.setupRootViewController(animated: false)
                        }
                    })
                }
            }
        }
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("[LOCALLOG] Your device just received a notification!")
        // Show the notification alert in foreground
        completionHandler([.alert, .sound, .badge])
    }
}

