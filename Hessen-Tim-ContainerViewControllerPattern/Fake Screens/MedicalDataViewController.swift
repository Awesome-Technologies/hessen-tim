//
//  MedicalDataViewController.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 16.01.20.
//  Copyright © 2020 Michael Rojkov. All rights reserved.
//

import UIKit
import SMART


class MedicalDataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var pName: String = "Hans Müller"
    var pBirthday: String = "15.02.1956"
    var pSize: String = "180"
    var pSex: String = "M"
    var pWeight: String = "71"
    var insuranceName: String = "Allianz"
    var clinic: String = "Frankfurt"
    var doctor: String = "Dr.Stein"
    var number: String = "017412345"
    
    var serviceRequestID: String = ""

    @IBOutlet weak var patientDataView: UIView!
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var noteView: UIView!
    
    @IBOutlet weak var imageCategoryView: UIView!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var historyView: UIView!
    
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
    @IBOutlet weak var historyButton: UIButton!
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

    
    @IBOutlet weak var historyTableView: UITableView!
    
    var historyData = [DiagnosticReport]()
    
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
        
        if(Institute.shared.sereviceRequestObject == nil || Institute.shared.sereviceRequestObject?.status != RequestStatus(rawValue: "draft")){
            editPatientData.isHidden = true
            send.isHidden = true
        } else if(Institute.shared.sereviceRequestObject?.status == RequestStatus(rawValue: "draft")){
            editPatientData.isHidden = false
            send.isHidden = false
        }
        
        patientDataView.layer.cornerRadius = 10
        patientDataView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        imageCategoryView.layer.cornerRadius = 10
        imageCategoryView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        historyView.layer.cornerRadius = 10
        historyView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        historyTableView.register(DiagnosticReportTableViewCell.self, forCellReuseIdentifier: "cellId")
        
        pictureCategory.layer.cornerRadius = 10
        pictureCategory.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        historyButton.layer.cornerRadius = 10
        historyButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        noteLabel.layer.masksToBounds = true
        noteLabel.layer.cornerRadius = 10
        noteLabel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        noteTextField.layer.cornerRadius = 10
        noteTextField.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        //Institute.shared.deleteAllImageMedia()
        Institute.shared.clearAllFile()
        //Institute.shared.loadAllMediaResource()
        
        Institute.shared.countImages(completion: { observation, count  in
            self.setNumberOfImages(observation: observation, count: count)
        })
        Institute.shared.getAllDiagnosticReportsForPatient(completion: { items in
            self.historyData = items
            DispatchQueue.main.async {
                self.historyTableView.reloadData()
            }
            
            
        })
        
        
        self.historyTableView.delegate = self
        self.historyTableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(toHomeScreen(_:)), name: Notification.Name(rawValue: "toHomeScreen"), object: nil)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func anamnesePictures(_ sender: Any) {
        openPictureView(sender: sender, category: ObservationType.Anamnesis)
    }
    @IBAction func arztbriefePictures(_ sender: Any) {
        openPictureView(sender: sender,category: ObservationType.MedicalLetter)
    }
    @IBAction func haemodynamikPictures(_ sender: Any) {
        openPictureView(sender: sender,category: ObservationType.Haemodynamics)
    }
    @IBAction func beatmungPictures(_ sender: Any) {
        openPictureView(sender: sender,category: ObservationType.Respiration)
    }
    @IBAction func blutgasanalysePictures(_ sender: Any) {
        openPictureView(sender: sender,category:ObservationType.BloodGasAnalysis)
    }
    @IBAction func perfusorenPictures(_ sender: Any) {
        openPictureView(sender: sender,category: ObservationType.Perfusors)
    }
    @IBAction func InfektiologiePictures(_ sender: Any) {
        openPictureView(sender: sender,category: ObservationType.InfectiousDisease)
    }
    @IBAction func radeologiePictures(_ sender: Any) {
        openPictureView(sender: sender,category: ObservationType.Radeology)
    }
    @IBAction func laborPictures(_ sender: Any) {
        openPictureView(sender: sender,category: ObservationType.Lab)
    }
    @IBAction func sonstigePictures(_ sender: Any) {
        openPictureView(sender: sender,category: ObservationType.Others)
    }
    
    
    
    @IBAction func goToPatientListView(_ sender: Any) {
        performSegue(withIdentifier: "toPatientList", sender: sender)
    }
    
    func openPictureView(sender: Any, category: ObservationType){
        print("MedicalViewCon:Call SplitView, from openPictureView" )
        
        var observation = ObservationType.NONE

        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.observID = category
        delegate.splitView = true
        delegate.setupRootViewController(animated: true)
        
        self.performSegue(withIdentifier: "takePicturesForCategory", sender: sender)
    }
    
    func setNumberOfImages(observation: ObservationType, count: Int){
        DispatchQueue.main.async {
            switch observation {
            case .Anamnesis:
                self.anamnesebutton.setTitle(String(count), for: .normal)
            case .MedicalLetter:
                self.medicalLetterButton.setTitle(String(count), for: .normal)
            case .Haemodynamics:
                self.haemodynamics.setTitle(String(count), for: .normal)
            case .Respiration:
                self.ventilationButton.setTitle(String(count), for: .normal)
            case .BloodGasAnalysis:
                self.bloodGasAnalysisButton.setTitle(String(count), for: .normal)
            case .Perfusors:
                self.perfusorsButton.setTitle(String(count), for: .normal)
            case .InfectiousDisease:
                self.infectiousDiseasesButton.setTitle(String(count), for: .normal)
            case .Radeology:
                self.radeologyButton.setTitle(String(count), for: .normal)
            case .Lab:
                self.labButon.setTitle(String(count), for: .normal)
            case .Others:
                self.otherButton.setTitle(String(count), for: .normal)
            case .NONE:
                print("NONE")
            default:
                print("DEFAULT")
            }
        }
    }
    @IBAction func openPictureCategoryView(_ sender: Any) {
        print("openPictureCategoryView")
        dataView.bringSubviewToFront(imageCategoryView)
        dataView.sendSubviewToBack(historyView)
        
    }
    
    @IBAction func openHistoryView(_ sender: Any) {
        print("openHistoryView")
        dataView.bringSubviewToFront(historyView)
        dataView.sendSubviewToBack(imageCategoryView)

    }
    
    @IBAction func cancelInput(_ sender: Any) {
        print("I quit the input")
        if(Institute.shared.sereviceRequestObject == nil || Institute.shared.sereviceRequestObject?.status == RequestStatus(rawValue: "draft")){
            var notificationView = MedicalDataNotificationView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            self.view.addSubview(notificationView)
            notificationView.addGrayBackPanel()
            notificationView.addSendViewLayoutConstraints()
            notificationView.addNotificationLabel(text: "Wollen Sie die Eingabe beenden")
            notificationView.addHomeIcon()
            notificationView.addCloseNotification()
            notificationView.addCancelbutton()
            notificationView.addDeletebutton()
            view.bringSubviewToFront(notificationView)
        }else{
            //self.performSegue(withIdentifier: "unwindToCaseSelection", sender: self)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "toHomeScreen"), object: nil)
        }
        
    }
    
    @IBAction func send(_ sender: Any) {
        Institute.shared.sendServiceRequest()
        var notificationView = MedicalDataNotificationView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.view.addSubview(notificationView)
        notificationView.addGrayBackPanel()
        notificationView.addSendViewLayoutConstraints()
        notificationView.addNotificationLabel(text: "Die Informationen wurden gesendet")
        notificationView.addPatientInforamtion()
        notificationView.addRequestSendInformation()
        notificationView.addCancelbutton()
        notificationView.addOKbutton()
        
        view.bringSubviewToFront(notificationView)
        
    }
    
    @IBAction func createConsultationReport(_ sender: Any) {
        //createConsilView.isHidden = false
        //view.bringSubviewToFront(createConsilView)
        var notificationView = MedicalDataNotificationView(frame: CGRect(x: 0, y: 0, width: 700, height: 500))
        self.view.addSubview(notificationView)
        notificationView.addGrayBackPanel()
        notificationView.addLayoutConstraints()
        notificationView.addConsilLabel(text: "Konsilbericht erstellen:")
        notificationView.addConsilReportTextView(editable: true, consilText: "")
        notificationView.addSendConsilReportButton()
        notificationView.addCancelbutton()
        
        view.bringSubviewToFront(notificationView)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "takePicturesForCategory" {
            
            let destination = segue.destination as! SplitViewController
            //destination.observationID = "TestObservationID"
            //destination.setCategory(category: 3)
            print("From Medical view I five the ID: 3")
            
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //https://blog.usejournal.com/easy-tableview-setup-tutorial-swift-4-ad48ec4cbd45
        let cell = historyTableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! DiagnosticReportTableViewCell
        cell.backgroundColor = UIColor(red:45.0/255.0, green:55.0/255.0, blue:95.0/255.0, alpha:0.0)
        cell.dateIssued.text = DiagnosticReportDateFormater(report: historyData[indexPath.row])
        cell.preview.text = historyData[indexPath.row].conclusion?.description
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showDiagosticReport(report: historyData[indexPath.row])
    }
    
    func DiagnosticReportDateFormater(report: DiagnosticReport)->String{
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSZ"

        let clockTime = DateFormatter()
        clockTime.dateFormat = "HH:mm"
        
        let dateTime = DateFormatter()
        dateTime.dateFormat = "dd.MM.yyyy"
        
        var printdate = ""
        if let date = dateFormatterGet.date(from: (report.issued?.description)!) {
            
            var clock = clockTime.string(from: date)
            var date = dateTime.string(from: date)
            printdate = clock + "     " + date
            
        } else {
           print("There was an error decoding the string")
        }
        return printdate
    }
    
    func showDiagosticReport(report: DiagnosticReport){
        
        var notificationView = MedicalDataNotificationView(frame: CGRect(x: 0, y: 0, width: 700, height: 500))
        self.view.addSubview(notificationView)
        notificationView.addGrayBackPanel()
        notificationView.addLayoutConstraints()
        notificationView.addConsilLabel(text: "Konsilbericht:")
        notificationView.addConsilDateLabel(text: DiagnosticReportDateFormater(report: report))
        notificationView.addConsilReportTextView(editable: false, consilText: report.conclusion!.description)
        notificationView.addCancelbutton()
        
        view.bringSubviewToFront(notificationView)
        
    }

    @IBAction func editPatientData(_ sender: Any) {
        performSegue(withIdentifier: "editPatientData", sender: nil)
    }
    
    
    @objc func toHomeScreen(_ notification: Notification) {
        self.performSegue(withIdentifier: "unwindToCaseSelection", sender: self)
    }
    
}
