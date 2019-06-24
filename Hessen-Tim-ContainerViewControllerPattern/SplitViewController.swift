//
//  SplitViewController.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 12.06.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Put the Master View on the left side
        self.primaryEdge = .trailing
        self.presentsWithGesture = false
        self.preferredDisplayMode = UISplitViewController.DisplayMode.primaryOverlay
    }
    
}
