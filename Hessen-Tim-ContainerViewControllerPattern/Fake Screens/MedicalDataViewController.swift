//
//  MedicalDataViewController.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 16.01.20.
//  Copyright © 2020 Michael Rojkov. All rights reserved.
//

import UIKit
import SMART
import IQKeyboardManagerSwift


class MedicalDataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    var serviceRequestID: String = ""

    @IBOutlet weak var patientDataView: UIView!
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var noteView: UIView!
    
    @IBOutlet weak var imageCategoryView: UIView!
    @IBOutlet weak var noteLabel: UILabel!
    //@IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var historyView: UIView!
    @IBOutlet weak var noteTextView: UITextView!
    var commentTextView: UITextView!
    var grayPanel: UIView!
    
    @IBOutlet weak var patientName: UILabel!
    @IBOutlet weak var patientBirthday: UILabel!
    @IBOutlet weak var patientSize: UILabel!
    @IBOutlet weak var patientSex: UILabel!
    @IBOutlet weak var patientWeight: UILabel!
    @IBOutlet weak var insurance: UILabel!
    @IBOutlet weak var clinicName: UILabel!
    @IBOutlet weak var contactDoctor: UILabel!
    @IBOutlet weak var contactNumber: UILabel!
    
    @IBOutlet weak var consultationReport: UIButton!
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
    @IBOutlet weak var historyUnwind: UIButton!
    
    
    @IBOutlet weak var historyTableView: UITableView!
    
    var historyData = [DomainResource]()
    
    var historyUnwindStart:CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysHide
        
        toggleEditButtons()
        
        historyUnwindStart = historyUnwind.frame.origin
        
        historyUnwind.layer.cornerRadius = 5
        historyUnwind.alpha = 0.0
        historyUnwind.isEnabled = false
        
        patientDataView.layer.cornerRadius = 10
        patientDataView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        imageCategoryView.layer.cornerRadius = 10
        imageCategoryView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        historyView.layer.cornerRadius = 10
        historyView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        historyTableView.register(DiagnosticReportTableViewCell.self, forCellReuseIdentifier: "cellId")
        historyTableView.register(ServiceRequestTableViewCell.self, forCellReuseIdentifier: "ScellId")
        
        pictureCategory.layer.cornerRadius = 10
        pictureCategory.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        historyButton.layer.cornerRadius = 10
        historyButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        noteLabel.layer.masksToBounds = true
        noteLabel.layer.cornerRadius = 10
        noteLabel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        commentTextView =  UITextView(frame: CGRect(x: 10, y: 220, width: 1060, height: 130))
        view.addSubview(commentTextView)
        commentTextView.delegate = self
        commentTextView.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(doneNoteButton))
        commentTextView.isEditable = false
        commentTextView.isHidden = true
        commentTextView.font = .systemFont(ofSize: 18)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapFromTextView))
        noteTextView.addGestureRecognizer(tapGestureRecognizer)
        noteTextView.layer.cornerRadius = 10
        noteTextView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        noteTextView.font = .systemFont(ofSize: 18)
        
        //Institute.shared.deleteAllImageMedia()
        Institute.shared.clearAllFile()
        //Institute.shared.loadAllMediaResource()
        
        Institute.shared.countImages(completion: { observation, count  in
            self.setNumberOfImages(observation: observation, count: count)
        })
        
        //Display the communicagtion history for the patient
        Institute.shared.getHistoryForPatient(patient:Institute.shared.patientObject!,  completion: { items in
            if (items != nil){
                self.historyData = items!
                DispatchQueue.main.async {
                    self.historyTableView.reloadData()
                    self.showHistoryNotes()
                    //Checks if we should display the unwind button
                    if self.historyunwindButtonVisible(){
                        self.animateHistoryUnwindButton(visible: true)
                    }else{
                        self.animateHistoryUnwindButton(visible: false)
                        
                    }
                }
            }
            
            
            
        })
        
        
        self.historyTableView.delegate = self
        self.historyTableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(toHomeScreen(_:)), name: Notification.Name(rawValue: "toHomeScreen"), object: nil)
    /*
        print("PROFILE!")
    print(UserLoginCredentials.shared.selectedProfile)
    if(UserLoginCredentials.shared.selectedProfile == .PeripheralClinic){
        consultationReport.isHidden = true
    }else if(UserLoginCredentials.shared.selectedProfile == .ConsultationClinic){
        print("send is HIDDEN!!")
        send.isHidden = true
        editPatientData.isHidden = true
    }
        */
    
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        if(UserLoginCredentials.shared.selectedProfile == .PeripheralClinic){
            consultationReport.isHidden = true
        }else if(UserLoginCredentials.shared.selectedProfile == .ConsultationClinic){
            send.isHidden = true
            editPatientData.isHidden = true
        }
        insertPatientData()
        
        print("INDEX")
        print(historyTableView.indexPathForSelectedRow)
        print(historyTableView.indexPathsForSelectedRows?.first?.row)
        print(historyTableView.indexPathsForVisibleRows?.first?.row)

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
            Institute.shared.clearData()
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
        //notificationView.addCancelbutton()
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
            
            
        } else if(segue.identifier == "editPatientData") { 
            let controller = segue.destination as! InsertPatientData
            controller.isEditMode = true
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let report = historyData[indexPath.row] as? DiagnosticReport {
            print("tableView: Diagnostic: " + report.id!.description)
            //https://blog.usejournal.com/easy-tableview-setup-tutorial-swift-4-ad48ec4cbd45
            let cell = historyTableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! DiagnosticReportTableViewCell
            cell.backgroundColor = UIColor(red:45.0/255.0, green:55.0/255.0, blue:95.0/255.0, alpha:0.0)
            cell.dateIssued.text = DiagnosticReportDateFormater(item: report)
            cell.preview.text = report.conclusion?.description
            
            //Get the String of the Service request, that its based on
            var stringReference = report.basedOn![0].reference?.string
            if let range = stringReference!.range(of: "/") {
                //get the ID of the ServiceRequest
                let scID = stringReference![range.upperBound...]
                
                if(String(scID) == Institute.shared.sereviceRequestObject?.id?.description){
                    cell.greenBorder()
                }else{
                    cell.noBorder()
                }
            }
            
            return cell
        }
        else {
            let request = historyData[indexPath.row] as? ServiceRequest
            print("tableView: Service: " + request!.id!.description)
            let cell = historyTableView.dequeueReusableCell(withIdentifier: "ScellId", for: indexPath) as! ServiceRequestTableViewCell
            cell.backgroundColor = UIColor(red:45.0/255.0, green:55.0/255.0, blue:95.0/255.0, alpha:0.0)
            cell.dateIssued.text = DiagnosticReportDateFormater(item: request!)
            
            if(request?.id?.description == Institute.shared.sereviceRequestObject?.id?.description){
                cell.greenBorder()
            }else{
                cell.noBorder()
                if(request?.status == RequestStatus(rawValue: "draft")){
                    cell.orangeBorder()
                }
            }
            
            if(request?.status == RequestStatus(rawValue: "draft")){
                cell.preview.text = (request?.id!.description)! + " Entwurf"
                
            }else{
                cell.preview.text = (request?.id!.description)! + " Neue Informationen"
            }
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
        if let report = historyData[indexPath.row] as? DiagnosticReport {
            showDiagosticReport(report: report)
        }else{
            let request = historyData[indexPath.row] as? ServiceRequest
            print("Date created: " + (request?.authoredOn!.description)!)
            Institute.shared.sereviceRequestObject = request
            Institute.shared.countImages(completion: { observation, count  in
                self.setNumberOfImages(observation: observation, count: count)
                //self.openPictureCategoryView(self)
            })
            toggleEditButtons()
            //self.openPictureCategoryView(self)
            tableView.reloadData()
            showHistoryNotes()
        }
        
        if(historyunwindButtonVisible()){
            animateHistoryUnwindButton(visible: true)
        } else{
            animateHistoryUnwindButton(visible: false)
        }
        
    }
    
    func DiagnosticReportDateFormater(item: DomainResource)->String{
        if let report = item as? DiagnosticReport {
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
                printdate = date + "     " + clock
                
            } else {
               print("There was an error decoding the string")
            }
            return printdate
        
        } else {
            let request = item as? ServiceRequest
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSZ"

            let clockTime = DateFormatter()
            clockTime.dateFormat = "HH:mm"
            
            let dateTime = DateFormatter()
            dateTime.dateFormat = "dd.MM.yyyy"
            
            var printdate = ""
            if let date = dateFormatterGet.date(from: (request?.authoredOn?.description)!) {
                
                var clock = clockTime.string(from: date)
                var date = dateTime.string(from: date)
                printdate = clock + "     " + date
                
            } else {
               print("There was an error decoding the string")
            }
            return printdate
            
        }
        
    }
    
    func showDiagosticReport(report: DiagnosticReport){
        
        var notificationView = MedicalDataNotificationView(frame: CGRect(x: 0, y: 0, width: 700, height: 500))
        self.view.addSubview(notificationView)
        notificationView.addGrayBackPanel()
        notificationView.addLayoutConstraints()
        notificationView.addConsilLabel(text: "Konsilbericht:")
        notificationView.addConsilDateLabel(text: DiagnosticReportDateFormater(item: report))
        notificationView.addConsilReportTextView(editable: false, consilText: report.conclusion!.description)
        notificationView.addCancelbutton()
        
        view.bringSubviewToFront(notificationView)
        
    }
    
    func toggleEditButtons(){
        if(Institute.shared.sereviceRequestObject == nil || Institute.shared.sereviceRequestObject?.status != RequestStatus(rawValue: "draft")){
            print("NO DRAFFT")
            editPatientData.isHidden = true
            send.isHidden = true
            consultationReport.isHidden = true
        } else if(Institute.shared.sereviceRequestObject?.status == RequestStatus(rawValue: "draft")){
            
            print("DRAFFT")
            editPatientData.isHidden = false
            
            if(UserLoginCredentials.shared.selectedProfile == .PeripheralClinic){
                send.isHidden = false
            }else if(UserLoginCredentials.shared.selectedProfile == .ConsultationClinic){
                consultationReport.isHidden = false
            }
            
        }
        
    }
    
    func insertPatientData(){
        self.patientName.text = (Institute.shared.patientObject!.name?[0].given?[0].string)! + " " + (Institute.shared.patientObject!.name?[0].family?.string)!
        self.patientBirthday.text = Institute.shared.patientObject?.birthDate?.description
        self.patientSize.text = Institute.shared.observationHeight?.valueQuantity?.value?.description
        self.patientSex.text = Institute.shared.patientObject?.gender?.rawValue
        self.patientWeight.text = Institute.shared.observationWeight?.valueQuantity?.value?.description
        self.insurance.text = Institute.shared.coverageObject?.class![0].name?.description
        self.clinicName.text = Institute.shared.patientObject!.contact![0].address?.text?.description
        self.contactDoctor.text = Institute.shared.patientObject!.contact![0].name?.family?.description
        self.contactNumber.text = Institute.shared.patientObject!.contact![0].telecom![0].value?.description
    }
    /**
     Checks if the unwind button should be visible
     We get the newest (firstest) Service request in the history Data
     If our currently selected service Request is not the found newest one, it means, that we are not on the newest Element and should display the unwind button
     */
    func historyunwindButtonVisible() -> Bool {
        if(historyData != nil && historyData.count > 0){
            let newestRequest = historyData.first{$0 is ServiceRequest} as! ServiceRequest
            print("Vergleich")
            print(Institute.shared.sereviceRequestObject?.id)
            print(newestRequest.id)
                if(Institute.shared.sereviceRequestObject?.id == newestRequest.id){
                    return false
                }else{
                    return true
                }
        }else{
            return false
        }
        }
        
    
    /**
     Animate the appearence of the unwind button
     */
    func animateHistoryUnwindButton(visible: Bool){
        if (visible){
            //Only animate if the button is NOT already visible
            if(historyUnwind.alpha != 1.0){
                UIView.animate(withDuration: 0.3, animations: {
                    self.historyUnwind.frame.origin = CGPoint(x: self.historyUnwind.frame.origin.x+50, y: self.historyUnwind.frame.origin.y)
                    self.historyUnwind.alpha = 1.0
                    
                }, completion: {(value: Bool) in
                    self.historyUnwind.isEnabled = true
                })
            }
            
        }else{
            historyUnwind.isEnabled = false
            historyUnwind.alpha = 0.0
            historyUnwind.frame.origin = historyUnwindStart
        }
    }
    
    func showCommentTextField(){
        view.bringSubviewToFront(commentTextView)
        commentTextView.isEditable = true
        commentTextView.isHidden = false
        commentTextView.layer.cornerRadius = 10
        commentTextView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        commentTextView.text = Institute.shared.sereviceRequestObject?.note![0].text?.description
        commentTextView.backgroundColor = UIColor.orange
    }
    
    /**
     Adds a comment marker, when enter is pressed on the keyboard
     */
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            var updatedText: String = textView.text! + ("\n\u{2022} ")
            textView.text = updatedText
            return false
            
        }
        return true
        
    }
    
    /**
     Triggers the closing of the comment view, when the keyboard is dismissed.
     */
    func textViewDidEndEditing(_ textView: UITextView) {
        if(textView == commentTextView){
            doneNoteButton()
        }
    }
    /**
     Adds a gray UIView in the background, when showing the comment view
     */
    func addGrayBackPanel(){
        grayPanel = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        //grayPanel.backgroundColor = UIColor.darkGray
        grayPanel.backgroundColor = UIColor.init(red: 49.0/255.0, green: 49.0/255.0, blue: 49.0/255.0, alpha: 0.5)
                
        self.view?.addSubview(grayPanel)
        grayPanel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            grayPanel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0),
            grayPanel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
            grayPanel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            grayPanel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
        ])
    }
    


    @IBAction func editPatientData(_ sender: Any) {
        performSegue(withIdentifier: "editPatientData", sender: nil)
    }
    
    
    @objc func toHomeScreen(_ notification: Notification) {
        self.performSegue(withIdentifier: "unwindToCaseSelection", sender: self)
        Institute.shared.clearData()
    }
    
    @IBAction func unwindHistory(_ sender: Any) {
        print("unwind")
        //gets the newest ServiceRequest
        let newestRequest = historyData.first{$0 is ServiceRequest} as! DomainResource
        print(newestRequest)
        //get index of the ServiceRequest in the Array
        let index = historyData.firstIndex{$0.id?.description == newestRequest.id?.description}
        print(index)
        
        let selectedIndex = IndexPath(row: index!, section: 0)
        print(selectedIndex)
        historyTableView.selectRow(at: selectedIndex, animated: true, scrollPosition: .none)
        historyTableView.delegate?.tableView!(historyTableView, didSelectRowAt: selectedIndex)
    }
    /**
     Function, that gets called to close the details view of the comments and saves the comment text
     */
    @objc func doneNoteButton() {
        print("doneNoteButton")
        print(commentTextView.text)
        print("---")
        
        commentTextView.isEditable = false
        commentTextView.isHidden = true
        formatCommentText()
        
        if let text = commentTextView.text{
            //Check if comment mode was used without adding a note
            if( text == "\u{2022} "){
                commentTextView.text = ""
            }
            Institute.shared.sereviceRequestObject?.note![0].text = FHIRString(text)
            Institute.shared.serviceRequestDraftObject?.note![0].text = FHIRString(text)
            //noteTextView.text = noteTextView.text + text
        }
        
        self.grayPanel.removeFromSuperview()
        UIView.animate(withDuration: 0.3, animations: {
            let rect = CGRect(x: 15, y: 635, width: 519, height: 153)
            //noteTextField.frame.size.height = noteTextField.frame.size.height+300
            self.noteTextView.frame = rect
            
            
        }, completion: {(value: Bool) in
            self.noteTextView.layer.cornerRadius = 10
            self.noteTextView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
            
            self.noteView.addSubview(self.noteTextView)
            let rect = CGRect(x: 5, y: 36, width: 519, height: 153)
            self.noteTextView.frame = rect
            self.commentTextView.resignFirstResponder()
            self.showHistoryNotes()
        })
    }
    
    /**
     Formats the text in the comment textView
     */
    func formatCommentText(){
        // When commentTextView is visible
        if(self.commentTextView.isEditable){
            if(self.commentTextView.text == ""){
                self.commentTextView.text = "\n\u{2022} "
                
            }else{
                if (!self.commentTextView.text.description.hasSuffix("\u{2022} ")) {
                    self.commentTextView.text = self.commentTextView.text! + ("\n\u{2022} ")
                }
            }
        // When commentTextView is not visible
        }else{
            if(self.commentTextView.text != ""){
                if (self.commentTextView.text.description.hasSuffix("\u{2022} ")) {
                    self.commentTextView.text.removeLast(3)
                }
            }
        }
    }
    
    /**
     Shows all the notes, that have been saved up to the selected ServiceRequest
     */
    func showHistoryNotes(){
        noteTextView.text = ""
        
        //Get a List af all ServiceRequests in the order: newest -> oldest
        Institute.shared.getAllServiceRequestsForPatientCustom(patient: Institute.shared.patientObject!, completion: { (requests) in
            if(requests != nil){
                for (idx, element) in requests!.enumerated() {
                    //At the top od the commentView put the comment from the draftService request
                    if idx == requests!.startIndex {
                        if let serviceObj = Institute.shared.sereviceRequestObject{
                            if(Institute.shared.sereviceRequestObject?.id?.description == Institute.shared.serviceRequestDraftObject?.id?.description){
                                DispatchQueue.main.async {
                                    if(self.noteTextView != nil){
                                        self.noteTextView.text = self.noteTextView.text + Institute.shared.serviceRequestDraftObject!.note![0].text!.description
                                    }
                                }
                            }
                        }
                    }
                    //Show all the other comments, if they fit the date sorting
                    if(element.authoredOn!.nsDate <= Institute.shared.sereviceRequestObject!.authoredOn!.nsDate){
                        if(element.note != nil){
                            if(element.note![0].text != nil){
                                DispatchQueue.main.async {
                                    if(self.noteTextView != nil){
                                        self.noteTextView.text = self.noteTextView.text + element.note![0].text!.description
                                    }
                                }
                            }
                        }
                        
                    }
                }
            //If we dont have a history jet, just display the comment from the draft
            }else{
                DispatchQueue.main.async {
                    if let serviceObject = Institute.shared.sereviceRequestObject{
                        self.noteTextView.text = (serviceObject.note![0].text!.description) + self.noteTextView.text
                    }
                }
            }
        })
    }
    
    /**
     Start the animation and display and adding of the notes, when the user is on a draft Servicerequest
     */
    @objc func handleTapFromTextView(recognizer : UITapGestureRecognizer)
    {
        
        if(Institute.shared.sereviceRequestObject?.status == RequestStatus(rawValue: "draft")){
            if(noteTextView.superview == noteView){
                self.view.addSubview(noteTextView)
                let rect = CGRect(x: 15, y: 635, width: 519, height: 153)
                noteTextView.frame = rect
                
                addGrayBackPanel()
                view.addSubview(noteTextView)
                view.bringSubviewToFront(noteTextView)
                UIView.animate(withDuration: 0.3, animations: {
                    let rect = CGRect(x: 10, y: 20, width: 1060, height: 200)
                    self.noteTextView.frame = rect
                    
                }, completion: {(value: Bool) in
                    self.noteTextView.layer.cornerRadius = 10
                    self.noteTextView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                    
                    self.showHistoryNotes()
                    self.showCommentTextField()
                    self.commentTextView.becomeFirstResponder()
                    self.formatCommentText()
                })
            }else{
               doneNoteButton()
            }
            
        }
    }
}
