//
//  InsertPatientData.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 14.01.20.
//  Copyright © 2020 Michael Rojkov. All rights reserved.
//

import UIKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // The list of array to display. Can be changed dynamically
        patientDropdown.optionArray = ["Max Müller", "Paul Pantzer", "Betina Bauer"]
        //Its Id Values and its optional
        patientDropdown.optionIds = [1,23,54,22]

        // Image Array its optional
        //bisherigePatienten.ImageArray = [👩🏻‍🦳,🙊,🥞]
        // The the Closure returns Selected Index and String
        patientDropdown.didSelect{(selectedText , index ,id) in
            print("Selected String: \(selectedText) \n index: \(index)")
        }
    }
    
    @IBAction func toPrevScreen(_ sender: Any) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.splitView = false
        delegate.setupRootViewController(animated: true)
        dismiss(animated: true, completion: nil)
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
        print("continue to Main View")
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
