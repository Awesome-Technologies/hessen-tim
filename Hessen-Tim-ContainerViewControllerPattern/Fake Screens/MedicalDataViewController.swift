//
//  MedicalDataViewController.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 16.01.20.
//  Copyright © 2020 Michael Rojkov. All rights reserved.
//

import UIKit

class MedicalDataViewController: UIViewController {
    
    var pName: String = "Hans Müller"
    var pBirthday: String = "15.02.1956"
    var pSize: String = "180"
    var pSex: String = "M"
    var pWeight: String = "71"
    var insuranceName: String = "Allianz"
    var clinic: String = "Frankfurt"
    var doctor: String = "Dr.Stein"
    var number: String = "017412345"
    

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
    @IBOutlet weak var hangUp: UIButton!
    @IBOutlet weak var createCaseReport: UIButton!
    @IBOutlet weak var grayOverlay: UIView!
    @IBOutlet weak var dataSendView: UIView!
    @IBOutlet weak var normalCallView: UIView!
    @IBOutlet weak var hangUpView: UIView!
    @IBOutlet weak var caseReportView: UIView!
    @IBOutlet weak var caseReportSendView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        patientName.text = pName
        patientBirthday.text = pBirthday
        patientSize.text = pSize
        patientSex.text = pSex
        patientWeight.text = pWeight
        insurance.text = insuranceName
        clinicName.text = clinic
        contactDoctor.text = doctor
        contactNumber.text = number
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func anamnesePictures(_ sender: Any) {
        openPictureView(sender: sender, category: "Anamnese")
    }
    @IBAction func arztbriefePictures(_ sender: Any) {
        openPictureView(sender: sender,category: "Arztbrief")
    }
    @IBAction func haemodynamikPictures(_ sender: Any) {
        openPictureView(sender: sender,category: "Haemodynamik")
    }
    @IBAction func beatmungPictures(_ sender: Any) {
        openPictureView(sender: sender,category: "Beatmung")
    }
    @IBAction func blutgasanalysePictures(_ sender: Any) {
        openPictureView(sender: sender,category: "Blutgasanalyse")
    }
    @IBAction func perfusorenPictures(_ sender: Any) {
        openPictureView(sender: sender,category: "Perfusoren")
    }
    @IBAction func InfektiologiePictures(_ sender: Any) {
        openPictureView(sender: sender,category: "Infektiologie")
    }
    @IBAction func radeologiePictures(_ sender: Any) {
        openPictureView(sender: sender,category: "Radeologie")
    }
    @IBAction func laborPictures(_ sender: Any) {
        openPictureView(sender: sender,category: "Labor")
    }
    @IBAction func sonstigePictures(_ sender: Any) {
        openPictureView(sender: sender,category: "Sonstige")
    }
    
    @IBAction func send(_ sender: Any) {
        view.bringSubviewToFront(grayOverlay)
        grayOverlay.isHidden = false
        view.bringSubviewToFront(dataSendView)
        
    }
    
    @IBAction func normalCall(_ sender: Any) {
        view.bringSubviewToFront(grayOverlay)
        grayOverlay.isHidden = false
        view.bringSubviewToFront(normalCallView)
    }
    @IBAction func continueNormalCall(_ sender: Any) {
        view.sendSubviewToBack(grayOverlay)
        grayOverlay.isHidden = true
        view.sendSubviewToBack(normalCallView)
        view.sendSubviewToBack(save)
        view.sendSubviewToBack(send)
        view.sendSubviewToBack(normalCall)
        view.sendSubviewToBack(videoCall)
        view.sendSubviewToBack(createCaseReport)
        view.bringSubviewToFront(hangUp)
    }
    
    @IBAction func hangUp(_ sender: Any) {
        
        view.bringSubviewToFront(normalCall)
        view.bringSubviewToFront(videoCall)
        view.bringSubviewToFront(createCaseReport)
        view.bringSubviewToFront(grayOverlay)
        grayOverlay.isHidden = false
        view.sendSubviewToBack(hangUp)
        view.bringSubviewToFront(hangUpView)
        
    }
    
    @IBAction func createCaseReport(_ sender: Any) {
        view.sendSubviewToBack(hangUpView)
        view.bringSubviewToFront(grayOverlay)
        grayOverlay.isHidden = false
        view.bringSubviewToFront(caseReportView)
    }
    
    @IBAction func sendCaseReport(_ sender: Any) {
        view.bringSubviewToFront(grayOverlay)
        grayOverlay.isHidden = false
        view.sendSubviewToBack(caseReportView)
        view.bringSubviewToFront(caseReportSendView)
    }
    
    @IBAction func closeNotificationWIndow(_ sender: Any) {
        view.sendSubviewToBack(grayOverlay)
        grayOverlay.isHidden = true
        view.sendSubviewToBack(caseReportView)
        view.sendSubviewToBack(dataSendView)
        view.sendSubviewToBack(normalCallView)
        view.sendSubviewToBack(hangUpView)
        view.sendSubviewToBack(caseReportSendView)
    }
    
    @IBAction func goToPatientListView(_ sender: Any) {
        performSegue(withIdentifier: "toPatientList", sender: sender)
    }
    
    func openPictureView(sender: Any, category: String){
        print("Call SplitView, from: " + category)
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.splitView = true
        delegate.setupRootViewController(animated: true)

        self.performSegue(withIdentifier: "takePicturesForCategory", sender: sender)
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
