//
//  LoginScreenViewController.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 01.07.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import UIKit

class LoginScreenViewController: UIViewController {

    @IBOutlet weak var screen2ImageView: UIImageView!
    @IBOutlet weak var showMainScreen: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        var x = screen2ImageView.frame.minX + (screen2ImageView.frame.width * 0.26)
        var y = screen2ImageView.frame.minY + (screen2ImageView.frame.height * 0.55)
        var width = screen2ImageView.frame.width * 0.50
        var height = screen2ImageView.frame.height * 0.1
        
        showMainScreen.frame = CGRect(x: x, y: y, width: width, height: height)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
