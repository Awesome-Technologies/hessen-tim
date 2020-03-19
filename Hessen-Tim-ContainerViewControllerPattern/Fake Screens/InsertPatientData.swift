//
//  InsertPatientData.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 14.01.20.
//  Copyright © 2020 Michael Rojkov. All rights reserved.
//

import UIKit
import SMART

class InsertPatientData: UIViewController , UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var patientDropdown: UITextField!
    @IBOutlet weak var patientSurname: UITextField!
    @IBOutlet weak var patientFirstname: UITextField!
    @IBOutlet weak var patientBirthday: UITextField!
    @IBOutlet weak var patientSize: UITextField!
    @IBOutlet weak var patientSex: UITextField!
    @IBOutlet weak var patientWeight: UITextField!
    
    @IBOutlet weak var insurance: UITextField!
    @IBOutlet weak var clinicName: UITextField!
    @IBOutlet weak var contactDoctor: UITextField!
    @IBOutlet weak var contactNumber: UITextField!
    
    @IBOutlet var deleteSelectedPatient: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    
    let datePicker = UIDatePicker()
    weak var pickerView: UIPickerView?
    var sex = ["male", "female", "other", "unknown"]
    var patientNames:[String]? = []
    var patientIDs:[String]? = []
    
    var itemSelected = ""
    
    
    var organizationID = ""
    var patientID = ""
    var serviceRequestID = ""
    
    var list: PatientList?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitle(title: "Bitte geben sie die Patientendaten ein")
        
        
        
        //add round cornes to Textfields and Buttons
        addUIcorners(item: patientDropdown)
        addUIcorners(item: patientSurname)
        addUIcorners(item: patientFirstname)
        addUIcorners(item: patientBirthday)
        addUIcorners(item: patientSize)
        addUIcorners(item: patientSex)
        addUIcorners(item: patientWeight)
        addUIcorners(item: insurance)
        addUIcorners(item: clinicName)
        addUIcorners(item: contactDoctor)
        addUIcorners(item: contactNumber)
        continueButton.clipsToBounds = true
        continueButton.layer.cornerRadius = 10
        
        //Add left side text padding to Textfields
        patientSurname.setLeftPaddingPoints(15)
        patientFirstname.setLeftPaddingPoints(15)
        patientBirthday.setLeftPaddingPoints(15)
        insurance.setLeftPaddingPoints(15)
        clinicName.setLeftPaddingPoints(15)
        contactDoctor.setLeftPaddingPoints(15)
        contactNumber.setLeftPaddingPoints(15)
        
        //Add observer to TextFields to highlight text input
        patientFirstname.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        patientSurname.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        patientFirstname.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        patientBirthday.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        patientSize.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        patientWeight.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        insurance.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        clinicName.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        contactDoctor.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        contactNumber.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        //UIPICKER
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        showDatePicker()
        patientSize.delegate = self
        contactNumber.delegate = self
        
        
        patientSex.delegate = self
        patientSex.inputView = pickerView
        
        patientDropdown.delegate = self
        patientDropdown.inputView = pickerView
        
        
        //It is important that goes after de inputView assignation
        self.pickerView = pickerView
        
        
        //Institute.shared.deleteAllImageMedia()
        //Institute.shared.deleteAllObservations()
        //Institute.shared.deleteAllServiceRequests()
        //Institute.shared.deleteAllPatients()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let client = Institute.shared.client {
            list = PatientListAll()
            list?.onPatientUpdate = {
                self.fillPatientList()
                
            }
            list?.retrieve(fromServer: client.server)
        }
    }
    
    
    /**
     Checks if text was text was inserted into TextField and highlight with green border
     */
    @objc func textFieldDidChange(_ textField: UITextField) {
        if(textField.text != ""){
            textField.layer.borderColor = UIColor.green.cgColor
        }
    }
    
    
    /**
     Sets the String and the style for the Title
     */
    func setTitle(title: String){
        self.title = title
        let attrs = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont(name: "AppleSDGothicNeo-SemiBold", size: 25)!
        ]
        UINavigationBar.appearance().titleTextAttributes = attrs
        
    }
    
    @IBAction func toPrevScreen(_ sender: Any) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.splitView = false
        delegate.setupRootViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    /**
     Adds round corners to Textfields
     */
    func addUIcorners(item: UITextField){
        item.clipsToBounds = true
        item.layer.cornerRadius = 10
        item.layer.borderWidth = 1.0
        item.layer.borderColor = UIColor.black.cgColor
    }
    
    
    /**
     Inserts all registered patients into the UIPicker
     */
    func fillPatientList(){
        if list?.patients?.count != nil {
            for patientNumber in 0...(Int(list!.patients!.count-1)) {
                let patient = list?.patients?[Int(patientNumber)]
                if let name = patient?.name?[0] {
                    let patientString = name.family!.string + " " + (name.given?[0].string)!
                    patientNames?.append(patientString)
                    let id: Int = Int((patient?.id!.description)!)!
                    patientIDs?.append(String(id))
                    
                }
                
            }
        }
    }
    
    
    /**
     Configure the UIPicker for the date
     */
    func showDatePicker(){
        //Formate Date
        datePicker.datePickerMode = .date
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        
        patientBirthday.inputAccessoryView = toolbar
        patientBirthday.inputView = datePicker
        
    }
    
    
    /**
     Format the date output and highlight the selection with a green border
     */
    @objc func donedatePicker(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        patientBirthday.text = formatter.string(from: datePicker.date)
        patientBirthday.layer.borderColor = UIColor.green.cgColor
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    
    /**
     Checks the input on numerical TextFields to accept only numbers and certain characters
     */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //For mobile numer validation
        if (textField == patientSize || textField == contactNumber || textField == patientWeight) {
            let allowedCharacters = CharacterSet(charactersIn:"+0123456789, ")//Here change this characters based on your requirement
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.pickerView?.reloadAllComponents()
    }
    
    
    /**
     Configure the UIPickers
     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if patientSex.isFirstResponder{
            return sex.count
        }
            
        else if patientDropdown.isFirstResponder{
            if(patientNames != nil){
                return patientNames!.count
            }else{
                return 0
            }
            
        }
        return 0
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    /**
     Configure the displayed items in the UIPicker
     */
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if patientSex.isFirstResponder{
            return sex[row]
        }else if patientDropdown.isFirstResponder{
            if(patientNames != nil){
                //fillTextFields(id: patientIDs![row])
                return patientNames![row]
            }else{
                return ""
            }
        }
        return nil
    }
    
    
    /**
     Configure the returned text from the UIPicker and highlight the selection with a green border
     */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if patientSex.isFirstResponder{
            let itemselected = sex[row]
            patientSex.text = itemselected
            patientSex.layer.borderColor = UIColor.green.cgColor
        }else if patientDropdown.isFirstResponder{
            if(patientNames != nil){
                let itemselected = patientNames?[row]
                fillTextFields(id: patientIDs![row])
                patientDropdown.text = itemselected
            }else{
                patientDropdown.text = ""
            }
            
        }
    }
    
    
    /**
     Upon selecting an already registered patient, the patients information are displayed in its respective Textfields
     */
    func fillTextFields(id: String){
        Institute.shared.getPatientByID(id: id, completion: { patient in
            DispatchQueue.main.async {
                Institute.shared.patientObject = patient
                self.patientSurname.text = patient.name?[0].family?.string
                self.patientFirstname.text = patient.name?[0].given?[0].string
                self.patientBirthday.text = patient.birthDate?.description
                self.patientSize.text = Institute.shared.observationHeight?.valueQuantity?.value?.description
                self.patientWeight.text = Institute.shared.observationWeight?.valueQuantity?.value?.description
                self.patientSex.text = patient.gender?.rawValue
                //self.insurance.text = ...
                self.clinicName.text = patient.contact?.first?.address?.text?.string
                self.contactDoctor.text = patient.contact?.first?.name?.family?.string
                self.contactNumber.text = patient.contact?.first?.telecom?.first?.value?.string
            }
            
        })
    }
    
    
    /**
     Deletes all of the selected/typed information on the screen
     */
    @IBAction func deleteSelectedPatientData(_ sender: Any) {
        patientDropdown.text = ""
        patientSurname.text = ""
        patientFirstname.text = ""
        patientBirthday.text = ""
        patientSize.text = ""
        patientSex.text = ""
        patientWeight.text = ""
        insurance.text = ""
        clinicName.text = ""
        contactDoctor.text = ""
        contactNumber.text = ""
        
        patientDropdown.layer.borderColor = UIColor.black.cgColor
        patientSurname.layer.borderColor = UIColor.black.cgColor
        patientFirstname.layer.borderColor = UIColor.black.cgColor
        patientBirthday.layer.borderColor = UIColor.black.cgColor
        patientSize.layer.borderColor = UIColor.black.cgColor
        patientSex.layer.borderColor = UIColor.black.cgColor
        patientWeight.layer.borderColor = UIColor.black.cgColor
        insurance.layer.borderColor = UIColor.black.cgColor
        clinicName.layer.borderColor = UIColor.black.cgColor
        contactDoctor.layer.borderColor = UIColor.black.cgColor
        contactNumber.layer.borderColor = UIColor.black.cgColor
    }
    
    
    /**
     Checks the inputs and triggers the creation of a patient/ServiceRequest - resource and segues to the next screen
     */
    @IBAction func `continue`(_ sender: Any) {
        if(patientDropdown.text != ""){
            //Institute.shared.createPatient(firstName: patientName.text!, familyName: "Neuman", gender: "male", birthday: DateTime.now.description)
            Institute.shared.createServiceRequest(status: "draft", intent: "proposal", category: "Intensivmedizin", priority: "asap", patientID: "7", organizationID: "51")
            performSegue(withIdentifier: "toMedicalData", sender: nil)
        }else if (!textElementsMissing()) {
            Institute.shared.createPatient(firstName: patientSurname.text!, familyName: patientFirstname.text!, gender: patientSex.text!, birthday: patientBirthday.text!, weight: patientWeight.text!, height: patientSize.text!, clinicName: clinicName.text!, doctorName: contactDoctor.text!, contactNumber: contactNumber.text!, completion: {
                Institute.shared.createServiceRequest(status: "draft", intent: "proposal", category: "Weaning", priority: "asap", patientID: "7", organizationID: "51")
            })
            performSegue(withIdentifier: "toMedicalData", sender: nil)
        }
    }
    
    /**
     The inputs are passed over to the next view
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMedicalData" {
            
            let controller = segue.destination as! MedicalDataViewController
            print("name: " +  String(self.patientSurname.text!))
            controller.pName = self.patientSurname.text!
            controller.pBirthday = self.patientBirthday.text!
            controller.pSize = self.patientSize.text!
            controller.pSex = self.patientSex.text!
            controller.pWeight = self.patientWeight.text!
            controller.insuranceName = self.insurance.text!
            controller.clinic = self.clinicName.text!
            controller.doctor = self.contactDoctor.text!
            controller.number = self.contactNumber.text!
            
            controller.serviceRequestID = self.serviceRequestID
            
        }
    }
    
    /**
     Checks if inputs are missing and highlights all the respective Textfields
     */
    func textElementsMissing() -> Bool {
        print("checkTextFields")
        
        highlightAllMissingElements()
        return checkMissingElements()
    }
    
    /**
     highlight all testfields with missing input with a shake animation and a red border
     */
    func highlightAllMissingElements(){
        
        for view in self.view.subviews {
            if (view is UITextField) {
                var textField = view as! UITextField
                if(textField != patientDropdown){
                    //textFields.append(textField)
                    if(textField.text == ""){
                        textField.layer.borderColor = UIColor.red.cgColor
                        textField.shake()
                        
                    }
                }
                
            }
        }
    }
    
    /**
     Checks if inputs are missing
     */
    func checkMissingElements()->Bool{
        
        for view in self.view.subviews {
            if (view is UITextField) {
                var textField = view as! UITextField
                if(textField != patientDropdown){
                    //textFields.append(textField)
                    if(textField.text == ""){
                        print("Missing element in")
                        print(textField.accessibilityLabel)
                        print(textField.restorationIdentifier )
                        return true
                    }
                }
                
            }
        }
        return false
    }
    
}

/**
 Extension for adding text padding to Textfields
 */
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}


/**
 Extension for shake animation for Textfields
 */
extension UIView {
    func shake(){
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))
        self.layer.add(animation, forKey: "position")
    }
}
