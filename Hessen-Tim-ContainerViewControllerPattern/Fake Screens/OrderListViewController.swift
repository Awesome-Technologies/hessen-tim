//
//  OrderListViewController.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 01.07.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import UIKit

class OrderListViewController: UIViewController {
    @IBOutlet weak var backButton: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var patient1: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        var x = backgroundImage.frame.minX + (backgroundImage.frame.width * 0.02)
        var y = backgroundImage.frame.minY + (backgroundImage.frame.height * 0.035)
        var width = backgroundImage.frame.width * 0.055
        var height = width
        
        backButton.frame = CGRect(x: x, y: y, width: width, height: height)
        
        x = backgroundImage.frame.minX + (backgroundImage.frame.width * 0.07)
        y = backgroundImage.frame.minY + (backgroundImage.frame.height * 0.22)
        width = backgroundImage.frame.width * 0.85
        height = backgroundImage.frame.height * 0.1
        
        patient1.frame = CGRect(x: x, y: y, width: width, height: height)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func goBackToRootTapped(_ sender: Any) {
        performSegue(withIdentifier: "exitToRoot", sender: self)
    }
}
