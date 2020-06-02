//
//  PatientListViewController.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 01.07.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import UIKit
import SMART
import Foundation

struct CellData {
    var patient = Patient()
}

/**
 This struct is a Data type, that represents one section in the TableView
 Here, I group the section Items by family name (String)
 */
struct PatientSection {
    
    var familyName : String
    var patients : [CellData]
    
    /**
     I create a dictionarry, where all my patient data are grouped together to sections
     So I get: dict<key = First Name of Family/ value = All the patients with key as first letter in family name>
     As a return, I just convert the dict to the PatientSection structure
     */
    static func group(patients : [CellData]) -> [PatientSection] {
        let groups = Dictionary(grouping: patients) { (patient) -> String in
            return (patient.patient.name?[0].family?.description.characters.first!.description)!
        }
        return groups.map(PatientSection.init(familyName:patients:))
    }
    
}



//https://stackoverflow.com/questions/47963568/programmatically-creating-an-expanding-uitableviewcell
//https://www.ralfebert.de/ios-examples/uikit/uitableviewcontroller/grouping-sections/
class PatientListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ExpandableCellDelegate, HistoryViewDelegate {
    
    
    var list: PatientList?
    var newPatient: Patient?
    var data = [CellData]()
    // The var section holds all of my data, that is grouped into different sections
    var sections = [PatientSection]()
    
    let tableView:UITableView = {
        let tb = UITableView()
        tb.translatesAutoresizingMaskIntoConstraints = false
        return tb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 38/255, green: 46/255, blue: 84/255, alpha: 1)
        self.tableView.backgroundColor = UIColor.clear
        
        let attributes = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Light", size: 25)!]
        UINavigationBar.appearance().titleTextAttributes = attributes
        self.title = "Patientenliste"
        
        
        if let client = Institute.shared.client {
            list = PatientListAll()
            list?.onPatientUpdate = {
                self.loadPatientData()
                self.tableView.reloadData()
            }
            list?.retrieve(fromServer: client.server)
        }
        
    }
    override func loadView() {
        super.loadView()
        
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 150).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 500
        tableView.register(ExpandableHistoryCell.self, forCellReuseIdentifier: "expandableCell")
        
        createPatientListTitles()
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = self.sections[indexPath.section]
        let patient = section.patients[indexPath.row]

        
        let cell = tableView.dequeueReusableCell(withIdentifier: "expandableCell", for: indexPath) as! ExpandableHistoryCell
        //cell.patient = data[indexPath.row].patient
        cell.patient = patient.patient
        cell.getPatientData()
        cell.delegate = self
        cell.historyDelegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ExpandableHistoryCell {
            cell.isExpanded = !cell.isExpanded
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ExpandableHistoryCell {
            cell.isExpanded = false
        }
    }
    
    
    func expandableCellLayoutChanged(_ expandableCell: ExpandableHistoryCell) {
        refreshTableAfterCellExpansion()
    }
    
    func refreshTableAfterCellExpansion() {
        self.tableView.beginUpdates()
        self.tableView.setNeedsDisplay()
        self.tableView.endUpdates()
    }
    
    func loadPatientData(){
        if list?.patients?.count != nil {
            for patient in list!.patients!{
                if let name = patient.name?[0] {
                    self.data.append(CellData(patient: patient))
                }
            }
        }
        //Once all the available patient data is loaded, I group it to different sections
        self.sections = PatientSection.group(patients: self.data)
        self.sections.sort { (lhs, rhs) in lhs.familyName < rhs.familyName }
        
        print (self.sections)
    }
    
    func showDiagosticReport(historyView: UIView){
        
        if let report = historyView as? DiagnosticReportView {
            var notificationView = MedicalDataNotificationView(frame: CGRect(x: 0, y: 0, width: 700, height: 500))
            self.view.addSubview(notificationView)
            notificationView.addGrayBackPanel()
            notificationView.addLayoutConstraints()
            notificationView.addConsilLabel(text: "Konsilbericht:")
            notificationView.addConsilDateLabel(text: report.dateIssued.text!)
            notificationView.addConsilReportTextView(editable: false, consilText: report.preview.text!)
            notificationView.addCancelbutton()
            
            view.bringSubviewToFront(notificationView)
        }
    }
    
    func showMedicalDataView() {
        self.performSegue(withIdentifier: "showMedicalDataView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showMedicalDataView") {
            /**
             Clear all the images in the cache
             This is a quick workaround for the problem, that right now, images in cache are displayed regardless of the patient
             We will fix this in the upcoming DataLayer update
             */
            print("clear cache")
            Institute.shared.images.removeAll()
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = self.sections[section]
        return section.familyName
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = self.sections[section]
        return section.patients.count
    }
    
    /*
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        header.contentView.backgroundColor = UIColor(red:38.0/255.0, green:46.0/255.0, blue:84.0/255.0, alpha:0.0)
    }
    */
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
            let header = view as! UITableViewHeaderFooterView
            header.backgroundView?.backgroundColor = UIColor(red:38.0/255.0, green:46.0/255.0, blue:84.0/255.0, alpha:1.0)
            header.contentView.backgroundColor = UIColor(red:38.0/255.0, green:46.0/255.0, blue:84.0/255.0, alpha:1.0)

            header.textLabel?.textColor = .white
            header.textLabel?.font = UIFont(name: "Helvetica-Bold", size: 14)
    }
    
    func createPatientListTitles(){
    
        let patientNameButton = UIButton()
        patientNameButton.setTitle("Name", for: .normal)
        patientNameButton.layer.cornerRadius = 5
        patientNameButton.layer.borderWidth = 0
        patientNameButton.layer.borderColor = UIColor.blue.cgColor
        patientNameButton.backgroundColor = UIColor(red: 0/255, green: 96/255, blue: 167/255, alpha: 1)
        patientNameButton.addTarget(self, action: #selector(sortFamilyName), for: .touchUpInside)
        
        self.view.addSubview(patientNameButton)
        
        patientNameButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            patientNameButton.widthAnchor.constraint(equalToConstant: 150),
            patientNameButton.heightAnchor.constraint(equalToConstant: 30),
            patientNameButton.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -10),
            patientNameButton.leftAnchor.constraint(equalTo: tableView.leftAnchor, constant: 50),
        ])
        
        
        let patientSexButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        patientSexButton.setTitle("Sex", for: .normal)
        patientSexButton.layer.cornerRadius = 5
        patientSexButton.layer.borderWidth = 0
        patientSexButton.layer.borderColor = UIColor.blue.cgColor
        patientSexButton.backgroundColor = UIColor(red: 0/255, green: 96/255, blue: 167/255, alpha: 1)
        //button.addTarget(self, action: #selector(saveDiagnosticReport), for: .touchUpInside)
        
        self.view.addSubview(patientSexButton)
        
        patientSexButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            patientSexButton.widthAnchor.constraint(equalToConstant: 50),
            patientSexButton.heightAnchor.constraint(equalToConstant: 30),
            patientSexButton.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -10),
            patientSexButton.leftAnchor.constraint(equalTo: patientNameButton.rightAnchor, constant: 40),
        ])
        
        let patientBirthdayButton = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        patientBirthdayButton.setTitle("Birthday", for: .normal)
        patientBirthdayButton.layer.cornerRadius = 5
        patientBirthdayButton.layer.borderWidth = 0
        patientBirthdayButton.layer.borderColor = UIColor.blue.cgColor
        patientBirthdayButton.backgroundColor = UIColor(red: 0/255, green: 96/255, blue: 167/255, alpha: 1)
        //button.addTarget(self, action: #selector(saveDiagnosticReport), for: .touchUpInside)
        
        self.view.addSubview(patientBirthdayButton)
        
        patientBirthdayButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            patientBirthdayButton.widthAnchor.constraint(equalToConstant: 150),
            patientBirthdayButton.heightAnchor.constraint(equalToConstant: 30),
            patientBirthdayButton.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -10),
            patientBirthdayButton.leftAnchor.constraint(equalTo: patientSexButton.rightAnchor, constant: 40),
        ])
        
        let patientSizeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        patientSizeButton.setTitle("Height", for: .normal)
        patientSizeButton.layer.cornerRadius = 5
        patientSizeButton.layer.borderWidth = 0
        patientSizeButton.layer.borderColor = UIColor.blue.cgColor
        patientSizeButton.backgroundColor = UIColor(red: 0/255, green: 96/255, blue: 167/255, alpha: 1)
        //button.addTarget(self, action: #selector(saveDiagnosticReport), for: .touchUpInside)
        
        self.view.addSubview(patientSizeButton)
        
        patientSizeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            patientSizeButton.widthAnchor.constraint(equalToConstant: 100),
            patientSizeButton.heightAnchor.constraint(equalToConstant: 30),
            patientSizeButton.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -10),
            patientSizeButton.leftAnchor.constraint(equalTo: patientBirthdayButton.rightAnchor, constant: 50),
        ])
        
        let patientWeightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        patientWeightButton.setTitle("Weight", for: .normal)
        patientWeightButton.layer.cornerRadius = 5
        patientWeightButton.layer.borderWidth = 0
        patientWeightButton.layer.borderColor = UIColor.blue.cgColor
        patientWeightButton.backgroundColor = UIColor(red: 0/255, green: 96/255, blue: 167/255, alpha: 1)
        //button.addTarget(self, action: #selector(saveDiagnosticReport), for: .touchUpInside)
        
        self.view.addSubview(patientWeightButton)
        
        patientWeightButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            patientWeightButton.widthAnchor.constraint(equalToConstant: 100),
            patientWeightButton.heightAnchor.constraint(equalToConstant: 30),
            patientWeightButton.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -10),
            patientWeightButton.leftAnchor.constraint(equalTo: patientSizeButton.rightAnchor, constant: 50),
        ])

        let patientClinicButton = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        patientClinicButton.setTitle("Clinic", for: .normal)
        patientClinicButton.layer.cornerRadius = 5
        patientClinicButton.layer.borderWidth = 0
        patientClinicButton.layer.borderColor = UIColor.blue.cgColor
        patientClinicButton.backgroundColor = UIColor(red: 0/255, green: 96/255, blue: 167/255, alpha: 1)
        //button.addTarget(self, action: #selector(saveDiagnosticReport), for: .touchUpInside)
        
        self.view.addSubview(patientClinicButton)
        
        patientClinicButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            patientClinicButton.widthAnchor.constraint(equalToConstant: 100),
            patientClinicButton.heightAnchor.constraint(equalToConstant: 30),
            patientClinicButton.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -10),
            patientClinicButton.leftAnchor.constraint(equalTo: patientWeightButton.rightAnchor, constant: 50),
        ])
        
    }
    
    @objc func sortFamilyName(sender: UIButton!) {
        print("SortName")
        if(sections.count > 1){
            if(sections.first!.familyName < sections.last!.familyName){
                self.sections.sort { (lhs, rhs) in lhs.familyName > rhs.familyName }
                tableView.reloadData()
            }else{
                self.sections.sort { (lhs, rhs) in lhs.familyName < rhs.familyName }
                tableView.reloadData()
            }
        }else{
            print("Only one section, nothing to sort")
        }
    }

    
    
}



protocol ExpandableCellDelegate: class {
    func expandableCellLayoutChanged(_ expandableCell: ExpandableHistoryCell)
}

protocol HistoryViewDelegate: class {
    func showDiagosticReport(historyView: UIView)
    func showMedicalDataView()
}


extension Patient: Hashable {

    public func hash(into hasher: inout Hasher) {
         hasher.combine(ObjectIdentifier(self).hashValue)
    }

    // `hashValue` is deprecated starting Swift 4.2, but if you use
    // earlier versions, then just override `hashValue`.
    //
    // public var hashValue: Int {
    //    return ObjectIdentifier(self).hashValue
    // }
}

extension Patient: Equatable {

    public static func ==(lhs: Patient, rhs: Patient) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}
