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
import RxSwift
import RxCocoa

//https://stackoverflow.com/questions/47963568/programmatically-creating-an-expanding-uitableviewcell
//https://www.ralfebert.de/ios-examples/uikit/uitableviewcontroller/grouping-sections/
class PatientListViewController: UIViewController, ExpandableCellDelegate, HistoryViewDelegate {
    let bag = DisposeBag()
    var selectedPatient: Patient?
    var selectedServiceRequest: ServiceRequest?
    var selectedLatestServiceRequest = false
    
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
        
        Repository.instance.getObservable(forType: Patient.self)
            .bind(to: tableView.rx.items(cellIdentifier: "expandableCell", cellType: ExpandableHistoryCell.self)) { row, model, cell in
                cell.delegate = self
                cell.historyDelegate = self
                cell.patient = model
        }
        .disposed(by: bag)
        
        tableView.rx.itemSelected.subscribe(onNext: { [unowned self] indexPath in
            if let selectedCell = self.tableView.cellForRow(at: indexPath) as? ExpandableHistoryCell {
                selectedCell.isExpanded = !selectedCell.isExpanded
            }
        }).disposed(by: bag)
        
        tableView.rx.itemDeselected.subscribe(onNext: { [unowned self] indexPath in
            if let selectedCell = self.tableView.cellForRow(at: indexPath) as? ExpandableHistoryCell {
                selectedCell.isExpanded = false
            }
        }).disposed(by: bag)
    }
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 150).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 500
        tableView.register(ExpandableHistoryCell.self, forCellReuseIdentifier: "expandableCell")
        
        createPatientListTitles()
    }
        
    func expandableCellLayoutChanged(_ expandableCell: ExpandableHistoryCell) {
        refreshTableAfterCellExpansion()
    }
    
    func refreshTableAfterCellExpansion() {
        self.tableView.beginUpdates()
        self.tableView.setNeedsDisplay()
        self.tableView.endUpdates()
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
    
    func showMedicalDataView(patient: Patient, serviceRequest: ServiceRequest, isLatest: Bool) {
        selectedPatient = patient
        selectedServiceRequest = serviceRequest
        selectedLatestServiceRequest = isLatest
        self.performSegue(withIdentifier: "showMedicalDataView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedPatient = selectedPatient, let selectedServiceRequest = selectedServiceRequest else {
            return
        }
        if let medicalDataView = segue.destination as? MedicalDataViewController {
            medicalDataView.patient = selectedPatient
            medicalDataView.serviceRequest = selectedServiceRequest
            medicalDataView.isLatestServiceRequest = selectedLatestServiceRequest
        }
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
}

protocol ExpandableCellDelegate: class {
    func expandableCellLayoutChanged(_ expandableCell: ExpandableHistoryCell)
}

protocol HistoryViewDelegate: class {
    func showDiagosticReport(historyView: UIView)
    func showMedicalDataView(patient: Patient, serviceRequest: ServiceRequest, isLatest: Bool)
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
