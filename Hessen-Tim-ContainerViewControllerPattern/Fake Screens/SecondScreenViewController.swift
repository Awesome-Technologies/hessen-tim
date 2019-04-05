//
//  SecondScreenViewController.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Marco Festini on 05.04.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import UIKit

class SecondScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func goBackToRootTapped(_ sender: Any) {
        performSegue(withIdentifier: "exitToRoot", sender: self)
    }
}
