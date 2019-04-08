//
//  SecondScreenViewController.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Marco Festini on 05.04.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import UIKit

class FirstScreenViewController: UIViewController {
    @IBOutlet weak var screen1ImageView: UIImageView!
    @IBOutlet weak var touchAreaView: UIView!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Place touch area at the appropriate place on the screenshot
        
        let x = screen1ImageView.frame.minX + (screen1ImageView.frame.width * 0.68)
        let y = screen1ImageView.frame.minY + (screen1ImageView.frame.height * 0.355)
        let width = screen1ImageView.frame.width * 0.277
        let height = screen1ImageView.frame.height * 0.0899
        
        touchAreaView.frame = CGRect(x: x, y: y, width: width, height: height)
    }
    
    @IBAction func exitViewToRootView(segue:UIStoryboardSegue) {}
}
