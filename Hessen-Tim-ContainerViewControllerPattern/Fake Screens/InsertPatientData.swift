//
//  InsertPatientData.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 14.01.20.
//  Copyright © 2020 Michael Rojkov. All rights reserved.
//

import UIKit
import SMART

class InsertPatientData: UIViewController {
    
    @IBOutlet weak var patientDropdown: DropDown!
    @IBOutlet weak var patientName: UITextField!
    @IBOutlet weak var patientBirthday: UITextField!
    @IBOutlet weak var patientSize: UITextField!
    @IBOutlet weak var patientSex: UITextField!
    @IBOutlet weak var patientWeight: UITextField!
    
    @IBOutlet weak var insurance: UITextField!
    @IBOutlet weak var clinicName: UITextField!
    @IBOutlet weak var contactDoctor: UITextField!
    @IBOutlet weak var contactNumber: UITextField!
    
    @IBOutlet weak var continueButton: UIButton!
    
    let datePicker = UIDatePicker()
    
    var organizationID = ""
    var patientID = ""
    var serviceRequestID = ""
    
    var observation = Observation()
    var serviceRequest = ServiceRequest()
    var list: PatientList?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // The list of array to display. Can be changed dynamically
        patientDropdown.optionArray = []
        //Its Id Values and its optional
        patientDropdown.optionIds = []
        
        if let client = Institute.shared.client {
            list = PatientListAll()
            list?.onPatientUpdate = {
                self.fillPatientList()
                    
            }
            list?.retrieve(fromServer: client.server)
        }
        
            
        

        // The list of array to display. Can be changed dynamically
        //patientDropdown.optionArray = ["Max Müller", "Paul Pantzer", "Betina Bauer"]
        //Its Id Values and its optional
        //patientDropdown.optionIds = [1,23,54,22]

        // Image Array its optional
        //bisherigePatienten.ImageArray = [👩🏻‍🦳,🙊,🥞]
        // The the Closure returns Selected Index and String
        //var id = patientDropdown.optionIds[0]
        patientDropdown.didSelect{(selectedText , index ,id) in
            print("Selected String: \(selectedText) \n index: \(index) \n id: \(id)")
            Institute.shared.getPatientByID(id: String(id), completion: { patient in
                DispatchQueue.main.async {
                    Institute.shared.patientObject = patient
                    self.patientName.text = patient.name?[0].given?[0].string
                    self.patientBirthday.text = patient.birthDate?.description
                    self.patientSex.text = patient.gender?.rawValue
                }
                
            })
        }
        
        showDatePicker()
        
        
        //Institute.shared.deleteAllImageMedia()
        //Institute.shared.deleteAllObservations()
        //Institute.shared.deleteAllServiceRequests()
        //Institute.shared.deleteAllPatients()
        //Institute.shared.searchPatientWithID(id: "5")
        //Institute.shared.updateServiceRequest(id: "61", status: "draft", intent: "proposal", category: "Weaning", priority: "asap", authoredOn: "2020-02-23", patientID: "7", organizationID: "51")
        //Institute.shared.createServiceRequest(status: "draft", intent: "proposal", category: "Weaning", priority: "asap", patientID: "7", organizationID: "51")
    }
    
    @IBAction func toPrevScreen(_ sender: Any) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.splitView = false
        delegate.setupRootViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    func fillPatientList(){
          if list?.patients?.count != nil {
            for patientNumber in 0...(Int(list!.patients!.count-1)) {
                  let patient = list?.patients?[Int(patientNumber)]
                  if let name = patient?.name?[0] {
                      //print(name.family?.string)
                      //print(name.given?[0].string)
                      //print("---")
                    print("I fill the List with the patient: \(name.family?.string) \n with the id: \(patient?.id!.description)")
                    let patientString = name.family!.string + (name.given?[0].string)!
                    patientDropdown.optionArray.append(patientString)
                    let id: Int = Int((patient?.id!.description)!)!
                    print("Found the id: \(id)")
                    patientDropdown.optionIds?.append(id)
    
                  }
                  
              }
          }
    }

    func showDatePicker(){
        //Formate Date
        datePicker.datePickerMode = .date

        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));

        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)

        patientBirthday.inputAccessoryView = toolbar
        patientBirthday.inputView = datePicker

    }

    @objc func donedatePicker(){

        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        patientBirthday.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }

    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    @IBAction func `continue`(_ sender: Any) {
        //print("continue to Main View")
        //print("name: " +  String(self.patientName.text!))
        //Institute.shared.deleteAllServiceRequests()
        
        //serviceRequestID =
        
        //serviceRequest = Institute.shared.searchServiceRequestWithID(id: "61")
        //Institute.shared.deleteAllImageMedia()
        //Institute.shared.deleteAllObservations()
        //Institute.shared.deleteAllServiceRequests()
        //Institute.shared.createServiceRequest(status: "draft", intent: "proposal", category: "Weaning", priority: "asap", authoredOn: "2020-02-23", patientID: "7", organizationID: "51")
        Institute.shared.changeAllMediaStatus()
        print("Indexxxxx:")
        print(patientDropdown.selectedIndex)
        
        //Institute.shared.createServiceRequest(status: "draft", intent: "proposal", category: "Weaning", priority: "asap", patientID: "7", organizationID: "51")
        if(patientDropdown.selectedIndex != nil){
            //Institute.shared.createPatient(firstName: patientName.text!, familyName: "Neuman", gender: "male", birthday: DateTime.now.description)
            Institute.shared.createServiceRequest(status: "draft", intent: "proposal", category: "Weaning", priority: "asap", patientID: "7", organizationID: "51")
            performSegue(withIdentifier: "toMedicalData", sender: nil)
        }else if (patientName.text != "") {
            Institute.shared.createPatient(firstName: patientName.text!, familyName: "Neuman", gender: "male", birthday: DateTime.now.description, completion: {
                Institute.shared.createServiceRequest(status: "draft", intent: "proposal", category: "Weaning", priority: "asap", patientID: "7", organizationID: "51")
            })
            performSegue(withIdentifier: "toMedicalData", sender: nil)
        }else{
            print("Nicht alle Felder ausgefüllt")
        }
        
        //Institute.shared.searchAllPatientRequests()
        print("NumberofPatients")
        print(self.list?.actualNumberOfPatients)
        
        //Institute.shared.getAllObservationsForPatient()
        if(true){
            //organizationID = Institute.shared.createOrganization(organizationName: "TestKlinik", contactName: "DR.Sommer", contactNumber: "123456s")
            //serviceRequestID = Institute.shared.createServiceRequest(status: "draft", intent: "proposal", category: "Weaning", priority: "asap", authoredOn: "2020-02-23", patientID: "7", organizationID: "51")
            //Institute.shared.updateServiceRequest(id: "61", status: "draft", intent: "proposal", category: "Weaning", priority: "asap", authoredOn: "2020-02-23", patientID: "7", organizationID: "51")
            
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMedicalData" {
            
            let controller = segue.destination as! MedicalDataViewController
            print("name: " +  String(self.patientName.text!))
            controller.pName = self.patientName.text!
            controller.pBirthday = self.patientBirthday.text!
            controller.pSize = self.patientSize.text!
            controller.pSex = self.patientSex.text!
            controller.pWeight = self.patientWeight.text!
            controller.insuranceName = self.insurance.text!
            controller.clinic = self.clinicName.text!
            controller.doctor = self.contactDoctor.text!
            controller.number = self.contactNumber.text!
            
            controller.serviceRequestID = self.serviceRequestID
            
            //Institute.shared.createServiceRequest(status: "draft", intent: "proposal", priority: "asap", authoredOn: "2020-02-23")
            //Institute.shared.searchAllServiceRequests()
            //Institute.shared.searchAllPatientRequests()
            //Institute.shared.createObservation(category: "Blutgasanalyse")
            /*
            Institute.shared.searchObservationWithID(id: "67", completion: {(value) in
                
                DispatchQueue.main.async {
                    self.observation = value
                    print(self.observation)
                }
                
                print(self.observation.id)
                
            })
            */
            //print("IPrintTheObservation:")
            //print(observation)
            //Institute.shared.searchServiceRequestWithID(id: "61")
            //Institute.shared.searchOnePatient()
            //print("ServiceRequest.ID")
            //print(serviceRequest.id)
            //Institute.shared.addObservationToServiceRequest()
            
            
            
        }
    }

}
