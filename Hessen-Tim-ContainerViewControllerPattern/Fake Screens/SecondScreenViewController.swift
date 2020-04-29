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
    @IBOutlet weak var patientListView: UIView!
    @IBOutlet weak var splitView: UIView!
    @IBOutlet weak var insertPatientData: UIView!
    @IBOutlet weak var patientList: UIButton!
    @IBOutlet weak var emergencyContact: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Place touch area at the appropriate place on the screenshot

        var x = screen2ImageView.frame.minX + (screen2ImageView.frame.width * 0.045)
        var y = screen2ImageView.frame.minY + (screen2ImageView.frame.height * 0.17)
        var width = screen2ImageView.frame.width * 0.14
        var height = screen2ImageView.frame.height * 0.08

        patientListView.frame = CGRect(x: x, y: y, width: width, height: height)

        x = screen2ImageView.frame.minX + (screen2ImageView.frame.width * 0.22)
        y = screen2ImageView.frame.minY + (screen2ImageView.frame.height * 0.28)
        width = screen2ImageView.frame.width * 0.32
        height = screen2ImageView.frame.height * 0.3

        splitView.frame = CGRect(x: x, y: y, width: 0, height: 0)
        
        
        x = screen2ImageView.frame.minX + (screen2ImageView.frame.width * 0.65)
        y = screen2ImageView.frame.minY + (screen2ImageView.frame.height * 0.25)
        width = screen2ImageView.frame.width * 0.32
        height = screen2ImageView.frame.height * 0.3

        insertPatientData.frame = CGRect(x: x, y: y, width: width, height: height)
        
        patientList.clipsToBounds = true
        patientList.layer.cornerRadius = 10
        patientList.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner] // Top right corner, Top left corner respectively


    }

    @IBAction func goBackToRootTapped(_ sender: Any) {
        performSegue(withIdentifier: "exitToRoot", sender: self)
    }

    @IBAction func splitShow(_ sender: Any) {
        print("Call SplitView")
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.splitView = true
        delegate.setupRootViewController(animated: true)

        self.performSegue(withIdentifier: "showSplitScreenVC", sender: sender)
    }

    @IBAction func openPatientList(_ sender: Any) {
        performSegue(withIdentifier: "toPatientListView", sender: nil)
    }
    
    @IBAction func exitViewToRootView(segue:UIStoryboardSegue) {}
}
