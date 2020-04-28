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


//https://stackoverflow.com/questions/47963568/programmatically-creating-an-expanding-uitableviewcell
class PatientListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ExpandableCellDelegate, HistoryViewDelegate {
    
    
    var list: PatientList?
    var newPatient: Patient?
    var data = [CellData]()
    
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
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "expandableCell", for: indexPath) as! ExpandableHistoryCell
        cell.patient = data[indexPath.row].patient
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
    
    
}



protocol ExpandableCellDelegate: class {
    func expandableCellLayoutChanged(_ expandableCell: ExpandableHistoryCell)
}

protocol HistoryViewDelegate: class {
    func showDiagosticReport(historyView: UIView)
    func showMedicalDataView()
}


