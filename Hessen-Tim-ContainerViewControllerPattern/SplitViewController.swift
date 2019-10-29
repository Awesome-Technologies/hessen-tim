//
//  SplitViewController.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 12.06.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController , UISplitViewControllerDelegate{
    
    var customView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    var masterVisible = true
    var oldDisplayMode: UISplitViewController.DisplayMode = UISplitViewController.DisplayMode.allVisible
    
    let window = UIApplication.shared.keyWindow!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Put the Master View on the left side
        self.primaryEdge = .trailing
        self.presentsWithGesture = false
        self.preferredDisplayMode = UISplitViewController.DisplayMode.allVisible
        self.delegate = self
        customView = UIView(frame: window.bounds)
        self.customView.backgroundColor = UIColor.gray.withAlphaComponent(0.0)
        
    }
    
    func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode){
        
        print(self.displayMode.rawValue)
        if(self.displayMode.rawValue == 2){
            masterVisible = true
        }
        
        print("some change in the master")
        if(masterVisible){
            UIView.animate(withDuration: 0.3, animations: {
                self.customView.backgroundColor = UIColor.gray.withAlphaComponent(0.0)
            }, completion: { finished in
                self.customView.removeFromSuperview()
            })
            masterVisible = false
        }else{
            self.view.addSubview(self.customView)
            UIView.animate(withDuration: 0.3, animations: {
                self.customView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
            }, completion: nil)
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
