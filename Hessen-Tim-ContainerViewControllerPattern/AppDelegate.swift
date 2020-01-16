//
//  AppDelegate.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 13.03.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var splitView = false
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        setupRootViewController(animated: false)
        return true
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
                let splitViewController = window.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "SplitVC") as! UISplitViewController
                let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
                navigationController.topViewController?.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
                //splitViewController.delegate = self as! UISplitViewControllerDelegate
                
                let masterNavigationController = splitViewController.viewControllers[0] as! UINavigationController
                let controller = masterNavigationController.topViewController as! MasterViewController
                
                newRootViewController = splitViewController
                transition = .transitionFlipFromRight
                
                splitView = false
                
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


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
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


}

