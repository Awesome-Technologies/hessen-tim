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
    @IBOutlet weak var patientList: UIButton!
    @IBOutlet weak var emergencyContact: UIButton!
    @IBOutlet weak var ecls: UIButton!
    @IBOutlet weak var others: UIButton!
    @IBOutlet weak var weaning: UIButton!
    @IBOutlet weak var konsilSubview: UIView!
    
    @IBOutlet weak var infectiousDisease: UIButton!
    @IBOutlet weak var intensiveCare: UIButton!
    @IBOutlet weak var childIntensiveCare: UIButton!
    @IBOutlet weak var pharmaceuticalVisit: UIButton!
    @IBOutlet weak var diagnostic: UIButton!
    @IBOutlet weak var back: UIButton!
    
    var eclsStart:CGPoint!
    var weaningStart:CGPoint!
    var othersStart:CGPoint!
    var consilStart:CGPoint!
    
    var infectiousDiseaseStart:CGPoint!
    var intensiveCareStart:CGPoint!
    var childIntensiveCareStart:CGPoint!
    var pharmaceuticalVisitStart:CGPoint!
    var diagnosticStart:CGPoint!
    
    
    var consilViewSize: CGRect!
    
    var consilOpen: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eclsStart = ecls.frame.origin
        weaningStart = weaning.frame.origin
        othersStart = others.frame.origin
        consilStart = konsilSubview.frame.origin
        consilViewSize = konsilSubview.frame
        
        infectiousDiseaseStart = infectiousDisease.frame.origin
        intensiveCareStart = intensiveCare.frame.origin
        childIntensiveCareStart = childIntensiveCare.frame.origin
        pharmaceuticalVisitStart = pharmaceuticalVisit.frame.origin
        diagnosticStart = diagnostic.frame.origin
        
        
        let gesture = UITapGestureRecognizer(target: self, action: "someAction:")
        konsilSubview.addGestureRecognizer(gesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        patientList.clipsToBounds = true
        patientList.layer.cornerRadius = 10
        patientList.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner] // Top right corner, Top left corner respectively

        
        ecls.alpha = 0.0
        others.alpha = 0.0
        weaning.alpha = 0.0
        konsilSubview.alpha = 0.0
        ecls.isEnabled = true
        others.isEnabled = true
        weaning.isEnabled = true
        back.isHidden = true
        
        ecls.frame.origin = eclsStart
        weaning.frame.origin = weaningStart
        others.frame.origin = othersStart
        konsilSubview.frame = consilViewSize
        konsilSubview.frame.origin = consilStart
        
        
        infectiousDisease.frame.origin = infectiousDiseaseStart
        intensiveCare.frame.origin = intensiveCareStart
        childIntensiveCare.frame.origin = childIntensiveCareStart
        pharmaceuticalVisit.frame.origin = pharmaceuticalVisitStart
        diagnostic.frame.origin = diagnosticStart
        
        consilOpen = false
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        UIView.animate(withDuration: 0.7, animations: {
            self.ecls.alpha = 1.0
            self.ecls.frame.origin = CGPoint(x: self.ecls.frame.origin.x - 100.0, y: self.ecls.frame.origin.y)
            
            self.others.alpha = 1.0
            self.others.frame.origin = CGPoint(x: self.others.frame.origin.x + 100.0, y: self.others.frame.origin.y)
            
            self.weaning.alpha = 1.0
            self.weaning.frame.origin = CGPoint(x: self.weaning.frame.origin.x - 100.0, y: self.weaning.frame.origin.y)
            
            self.konsilSubview.alpha = 1.0
            self.konsilSubview.frame.origin = CGPoint(x: self.konsilSubview.frame.origin.x + 100.0, y: self.konsilSubview.frame.origin.y)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

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
    
    @objc func someAction(_ sender:UITapGestureRecognizer){
        
        if(!consilOpen){
            UIView.animate(withDuration: 0.3, animations: {
                self.konsilSubview.frame.origin = CGPoint(x: self.konsilSubview.frame.origin.x + 150, y: self.konsilSubview.frame.origin.y)
                self.others.alpha = 0.0
                self.weaning.alpha = 0.0
                self.ecls.alpha = 0.0
                
                self.others.isEnabled = false
                self.weaning.isEnabled = false
                self.ecls.isEnabled = false
                
            }, completion: {(value: Bool) in
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.infectiousDisease.frame.origin = CGPoint(x: self.infectiousDisease.frame.origin.x, y: self.infectiousDisease.frame.origin.y + 30)
                    
                    self.intensiveCare.frame.origin = CGPoint(x: self.intensiveCare.frame.origin.x, y: self.intensiveCare.frame.origin.y + 55)
                    
                    self.childIntensiveCare.frame.origin = CGPoint(x: self.childIntensiveCare.frame.origin.x, y: self.childIntensiveCare.frame.origin.y + 80)
                    
                    self.pharmaceuticalVisit.frame.origin = CGPoint(x: self.pharmaceuticalVisit.frame.origin.x, y: self.pharmaceuticalVisit.frame.origin.y + 105)
                    
                    self.diagnostic.frame.origin = CGPoint(x: self.diagnostic.frame.origin.x, y: self.diagnostic.frame.origin.y +  130)
                    
                    
                    self.konsilSubview.frame = CGRect(x: self.konsilSubview.frame.origin.x, y: self.konsilSubview.frame.origin.y, width: self.konsilSubview.frame.width, height: self.konsilSubview.frame.height+200)
                    
                    self.back.isHidden = false
                    
                    self.consilOpen = true
                })
            })
        }else{
            self.closeKonsilView((Any).self)
        }
        
        
    }
    @IBAction func testAction(_ sender: Any) {
        print("TestAction")
    }
    @IBAction func sonstigeAction(_ sender: Any) {
        print("SonstigeAction")
    }
    @IBAction func closeKonsilView(_ sender: Any) {
        
        back.isHidden = true
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.infectiousDisease.frame.origin = CGPoint(x: self.infectiousDisease.frame.origin.x, y: self.infectiousDisease.frame.origin.y - 30)
            
            self.intensiveCare.frame.origin = CGPoint(x: self.intensiveCare.frame.origin.x, y: self.intensiveCare.frame.origin.y - 55)
            
            self.childIntensiveCare.frame.origin = CGPoint(x: self.childIntensiveCare.frame.origin.x, y: self.childIntensiveCare.frame.origin.y - 80)
            
            self.pharmaceuticalVisit.frame.origin = CGPoint(x: self.pharmaceuticalVisit.frame.origin.x, y: self.pharmaceuticalVisit.frame.origin.y - 105)
            
            self.diagnostic.frame.origin = CGPoint(x: self.diagnostic.frame.origin.x, y: self.diagnostic.frame.origin.y - 130)
            
            self.konsilSubview.frame = CGRect(x: self.konsilSubview.frame.origin.x, y: self.konsilSubview.frame.origin.y, width: self.konsilSubview.frame.width, height: self.konsilSubview.frame.height-200)
            
            
            
        }, completion: {(value: Bool) in
            UIView.animate(withDuration: 0.3, animations: {
                
                self.konsilSubview.frame.origin = CGPoint(x: self.konsilSubview.frame.origin.x - 150, y: self.konsilSubview.frame.origin.y)
                self.others.alpha = 1.0
                self.weaning.alpha = 1.0
                self.ecls.alpha = 1.0
                
                self.others.isEnabled = true
                self.weaning.isEnabled = true
                self.ecls.isEnabled = true
                
                self.consilOpen = false
            })
        })
    }
    
    @IBAction func insertPatientData(_ sender: Any) {
        print("InsertPatientData")
        performSegue(withIdentifier: "insertPatientData", sender: nil)
    }
    
    @IBAction func unwindToStart(segue:UIStoryboardSegue) {
        
    }
    
}
