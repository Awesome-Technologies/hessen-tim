//
//  PatientendatenViewController.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 27.06.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import UIKit

class PatientendatenViewController: UIViewController {


    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var verlegendeKlinik: UITextField!
    @IBOutlet weak var groesse: UITextField!
    @IBOutlet weak var ansprechpartner: UITextField!
    @IBOutlet weak var geschlaecht: UITextField!
    @IBOutlet weak var gewicht: UITextField!
    @IBOutlet weak var rueckrufnummer: UITextField!


    var collapseMaster:UIBarButtonItem!


    //https://github.com/jriosdev/iOSDropDown
    @IBOutlet weak var patientDataDropdown: DropDown!
    @IBOutlet weak var insuranceDropdown: DropDown!
    @IBOutlet weak var patientBirthday: UITextField!
    let datePicker = UIDatePicker()

    //--TableView
    //https://stackoverflow.com/questions/24170922/creating-custom-tableview-cells-in-swift
    let information: [String] = ["Patientendaten", "Anamnese", "Arztbrief", "Monitoring", "Beatmung", "Blutgasanalyse", "Perfusoren", "Mibi", "Radiologie", "Labor", "Sonstige"]
    let cellReuseIdentifier = "infoCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        view.backgroundColor = UIColor.init(red: 38/255, green: 47/255, blue: 83/255, alpha: 1)

        collapseMaster = UIBarButtonItem(title: "Information >", style: .done, target: self, action: #selector(collapse))
        self.navigationItem.rightBarButtonItem = nil

        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(toPrevScreen))


        // The list of array to display. Can be changed dynamically
        patientDataDropdown.optionArray = ["Max Müller", "Paul Pantzer", "Betina Bauer"]
        //Its Id Values and its optional
        patientDataDropdown.optionIds = [1,23,54,22]

        // Image Array its optional
        //bisherigePatienten.ImageArray = [👩🏻‍🦳,🙊,🥞]
        // The the Closure returns Selected Index and String
        patientDataDropdown.didSelect{(selectedText , index ,id) in
            print("Selected String: \(selectedText) \n index: \(index)")
        }

        patientDataDropdown.rowHeight = 40
        patientDataDropdown.borderWidth = 2
        patientDataDropdown.borderStyle = UITextField.BorderStyle.roundedRect
        patientDataDropdown.arrowSize = 30
        patientDataDropdown.layer.cornerRadius = 15.0
        patientDataDropdown.layer.borderWidth = 1.0


        // The list of array to display. Can be changed dynamically
        insuranceDropdown.optionArray = ["BARMER DAK Gesundheit","HEK - Hanseatische Krankenkasse","hkk Krankenkasse","KKH Kaufmännische Krankenkasse","KNAPPSCHAFT","Techniker Krankenkasse (TK)","BIG direkt gesund","IKK Brandenburg und Berlin","IKK classic","IKK gesund plus","IKK Nord","IKK Südwest","AOK Baden-Württemberg","AOK Bayern","AOK Bremen/Bremerhaven","AOK Hessen","AOK Niedersachsen","AOK Nordost","AOK Nordwest","AOK PLUS","AOK Rheinland-Pfalz/Saarland","AOK Rheinland/Hamburg","AOK Sachsen-Anhalt","actimonda krankenkasse","atlas BKK ahlmann","Audi BKK","BAHN-BKK","BERGISCHE Krankenkasse","Bertelsmann BKK","BKK Achenbach Buschhütten","BKK Akzo Nobel Bayern","BKK Diakonie","BKK DürkoppAdler","BKK EUREGIO","BKK exklusiv","BKK Faber-Castell & Partner","BKK firmus","BKK Freudenberg","BKK GILDEMEISTER SEIDENSTICKER","BKK HENSCHEL plus","BKK HERKULES","BKK HMR","BKK Linde","BKK Melitta Plus","BKK Mobil Oil","BKK PFAFF","BKK ProVita","BKK Public","BKK SBH","BKK Scheufelez","BKK Technoform","BKK Textilgruppe Hof","BKK VBU","BKK VDN","BKK VerbundPlus","BKK Werra-Meissner"]
        //Its Id Values and its optional

        var i = 1
        for vers in insuranceDropdown.optionArray{
            insuranceDropdown.optionIds?.append(i)
            i+=1
        }

        // Image Array its optional
        //bisherigePatienten.ImageArray = [👩🏻‍🦳,🙊,🥞]
        // The the Closure returns Selected Index and String
        insuranceDropdown.didSelect{(selectedText , index ,id) in
            print("Selected String: \(selectedText) \n index: \(index)")
        }

        insuranceDropdown.rowHeight = 40
        insuranceDropdown.borderWidth = 2
        insuranceDropdown.borderStyle = UITextField.BorderStyle.roundedRect
        insuranceDropdown.arrowSize = 30
        insuranceDropdown.layer.cornerRadius = 15.0
        insuranceDropdown.layer.borderWidth = 1.0

        showDatePicker()


        //---BorderStyle for Buttons
        name.layer.cornerRadius = 15.0
        name.layer.borderWidth = 1.0
        //name.layer.borderColor = UIColor.red.cgColo
        verlegendeKlinik.layer.cornerRadius = 15.0
        verlegendeKlinik.layer.borderWidth = 1.0
        groesse.layer.cornerRadius = 15.0
        groesse.layer.borderWidth = 1.0
        ansprechpartner.layer.cornerRadius = 15.0
        ansprechpartner.layer.borderWidth = 1.0
        geschlaecht.layer.cornerRadius = 15.0
        geschlaecht.layer.borderWidth = 1.0
        gewicht.layer.cornerRadius = 15.0
        gewicht.layer.borderWidth = 1.0
        rueckrufnummer.layer.cornerRadius = 15.0
        rueckrufnummer.layer.borderWidth = 1.0
        patientBirthday.layer.cornerRadius = 15.0
        patientBirthday.layer.borderWidth = 1.0

    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @objc func collapse(){
        //https://stackoverflow.com/questions/35005887/trouble-using-a-custom-image-for-splitviewcontroller-displaymodebuttonitem-uiba
        UIApplication.shared.sendAction(splitViewController!.displayModeButtonItem.action!, to: splitViewController!.displayModeButtonItem.target, from: nil, for: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
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

}
