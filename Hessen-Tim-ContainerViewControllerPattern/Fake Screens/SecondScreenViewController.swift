//
//  SecondScreenViewController.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Marco Festini on 05.04.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import UIKit

class SecondScreenViewController: UIViewController {
    @IBOutlet weak var screen2ImageView: UIImageView!
    @IBOutlet weak var showCameraTouchAreaView: UIView!
    @IBOutlet weak var patientListView: UIView!
    @IBOutlet weak var orderListView: UIView!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Place touch area at the appropriate place on the screenshot
        
        var x = screen2ImageView.frame.minX + (screen2ImageView.frame.width * 0.78)
        var y = screen2ImageView.frame.minY + (screen2ImageView.frame.height * 0.749)
        var width = screen2ImageView.frame.width * 0.182
        var height = screen2ImageView.frame.height * 0.189
        
        showCameraTouchAreaView.frame = CGRect(x: x, y: y, width: width, height: height)
        
        
        x = screen2ImageView.frame.minX + (screen2ImageView.frame.width * 0.037)
        y = screen2ImageView.frame.minY + (screen2ImageView.frame.height * 0.095)
        width = screen2ImageView.frame.width * 0.14
        height = screen2ImageView.frame.height * 0.08
        
        patientListView.frame = CGRect(x: x, y: y, width: width, height: height)
        
        x = screen2ImageView.frame.minX + (screen2ImageView.frame.width * 0.037)
        y = screen2ImageView.frame.minY + (screen2ImageView.frame.height * 0.2)
        width = screen2ImageView.frame.width * 0.14
        height = screen2ImageView.frame.height * 0.09
        
        orderListView.frame = CGRect(x: x, y: y, width: width, height: height)
    }
    
    @IBAction func goBackToRootTapped(_ sender: Any) {
        performSegue(withIdentifier: "exitToRoot", sender: self)
    }
    
    
    @IBAction func exitViewToRootView(segue:UIStoryboardSegue) {}
}
