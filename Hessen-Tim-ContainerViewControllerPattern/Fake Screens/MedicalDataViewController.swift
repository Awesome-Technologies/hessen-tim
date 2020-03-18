//
//  MedicalDataViewController.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 16.01.20.
//  Copyright © 2020 Michael Rojkov. All rights reserved.
//

import UIKit

class MedicalDataViewController: UIViewController {

    @IBOutlet weak var patientName: UILabel!
    @IBOutlet weak var patientBirthday: UILabel!
    @IBOutlet weak var patientSize: UILabel!
    @IBOutlet weak var patientSex: UILabel!
    @IBOutlet weak var patientWeight: UILabel!
    @IBOutlet weak var insurance: UILabel!
    @IBOutlet weak var clinicName: UILabel!
    @IBOutlet weak var contactDoctor: UILabel!
    @IBOutlet weak var contactNumber: UILabel!
    
    @IBOutlet weak var additionalInformation: UITextField!
    
    @IBOutlet weak var editPatientData: UIButton!
    @IBOutlet weak var pictureCategory: UIButton!
    @IBOutlet weak var communicationTimeline: UIButton!
    @IBOutlet weak var anamnesebutton: UIButton!
    @IBOutlet weak var medicalLetterButton: UIButton!
    @IBOutlet weak var haemodynamics: UIButton!
    @IBOutlet weak var ventilationButton: UIButton!
    @IBOutlet weak var bloodGasAnalysisButton: UIButton!
    @IBOutlet weak var perfusorsButton: UIButton!
    @IBOutlet weak var infectiousDiseasesButton: UIButton!
    @IBOutlet weak var radeologyButton: UIButton!
    @IBOutlet weak var labButon: UIButton!
    @IBOutlet weak var otherButton: UIButton!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var send: UIButton!
    @IBOutlet weak var normalCall: UIButton!
    @IBOutlet weak var videoCall: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
