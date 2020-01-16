//
//  SplitViewController.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 12.06.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController , UISplitViewControllerDelegate{
    
    var masterVisible = true
    var oldDisplayMode: UISplitViewController.DisplayMode = UISplitViewController.DisplayMode.allVisible
    
    let window = UIApplication.shared.keyWindow!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Put the Master View on the left side
        self.primaryEdge = .trailing
        self.presentsWithGesture = false
        self.preferredDisplayMode = UISplitViewController.DisplayMode.primaryHidden
        self.delegate = self
        
    }
    
    func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode){
        
        print(self.displayMode.rawValue)
        if(self.displayMode.rawValue == 2){
            masterVisible = true
        }
        
        print("some change in the master")
        if(masterVisible){
            NotificationCenter.default.post(name: Notification.Name(rawValue: "removeGraySubview"), object: nil)
            masterVisible = false
        }else{
            NotificationCenter.default.post(name: Notification.Name(rawValue: "addGraySubview"), object: nil)
            masterVisible = true
        }
        /*
        if(self.displayMode != oldDisplayMode){
            masterVisible = false
            oldDisplayMode = self.displayMode
        }
 */
        
    }
    
}

extension UISplitViewController {
    var primaryViewController: UIViewController? {
        print(self.viewControllers.first?.title)
        return self.viewControllers.first
    }
    
    var secondaryViewController: UIViewController? {
        return self.viewControllers.count > 1 ? self.viewControllers[1] : nil
    }
}

extension UISplitViewController {
    func setMasterVisuble(bool: Bool){
    }
}
