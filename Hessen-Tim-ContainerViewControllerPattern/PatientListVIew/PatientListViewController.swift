//
//  PatientListViewController.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 01.07.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import UIKit
import SMART


struct cellData {
    var opened = Bool()
    var firstName = String()
    var familyName = String()
    var sectionData = [String]();
}

struct Patient {
    var surename : String
    var firstName : String
    var sex : String
    var birthday : Date
    var size : Int
    var weight : Int
    var clinic : String
    var insurance : String
    
}

class PatientTableViewCell: UITableViewCell {

    @IBOutlet weak var nachnameLabel: UILabel!
    @IBOutlet weak var vornameLabel: UILabel!
    @IBOutlet weak var geschlechtLabel: UILabel!
    @IBOutlet weak var geburtsdatumLabel: UILabel!
    @IBOutlet weak var groesseLabel: UILabel!
    @IBOutlet weak var gewichtLabel: UILabel!
    @IBOutlet weak var klinikLabel: UILabel!
    @IBOutlet weak var versicherungLabel: UILabel!
    @IBOutlet weak var comHistory: UIStackView!
    
}

class CommunicationCell: UITableViewCell {
    @IBOutlet weak var testLabel: UILabel!
    
}

fileprivate func parseDate(_ str : String) -> Date {
    let dateFormat = DateFormatter()
    dateFormat.dateFormat = "yyyy-MM-dd"
    return dateFormat.date(from: str)!
}

class PatientListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var list: PatientList?
    
    var selectedCellIndexPath: IndexPath?
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var communicationHistoryStack: UIStackView!
    
    @IBAction func goBackToRootTapped(_ sender: Any) {
        performSegue(withIdentifier: "exitToRoot", sender: self)
    }
    

    var tableViewData = [cellData]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor(red:38.0/255.0, green:46.0/255.0, blue:84.0/255.0, alpha:1.0)
        
        tableView.rowHeight = 70
        tableView.sectionHeaderHeight = 40
        tableView.sectionFooterHeight = 20
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 85
        
        let attributes = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Light", size: 25)!]
        UINavigationBar.appearance().titleTextAttributes = attributes
        
        self.title = "Patientenliste"
        //self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Patientenliste", size: 20)!]
        
        if let client = Institute.shared.client {
            list = PatientListAll()
            list?.onPatientUpdate = {
                self.tableView.reloadData()
            }
            list?.retrieve(fromServer: client.server)
        }
        
        tableViewData = [cellData(opened: false, firstName:"Hans", familyName: "müller", sectionData: ["cell1","cell2","cell3"]),
                         cellData(opened: false, firstName:"Paul", familyName: "panzer", sectionData: ["cell1","cell2","cell3", "cell4"]),
                         cellData(opened: false, firstName:"Heiko", familyName: "blümlein", sectionData: ["cell1","cell2"]),
                         cellData(opened: false, firstName:"Nikolai", familyName: "panke", sectionData: ["cell1","cell2","cell3"])]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //return 1
        print("Number of section:" + String(tableViewData.count))
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       //return patienten.count
        if(tableViewData[section].opened){
            return tableViewData[section].sectionData.count+1
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.row == 0){
            //guard let cell = tableView.dequeueReusableCell(withIdentifier: "PatientCell") as! PatientTableViewCell else{return UITableViewCell()}
            let cell = tableView.dequeueReusableCell(withIdentifier: "PatientCell", for: indexPath) as! PatientTableViewCell
            //cell.textLabel?.text = tableViewData[indexPath.section].title
            cell.nachnameLabel?.text = tableViewData[indexPath.section].familyName
            cell.vornameLabel?.text = tableViewData[indexPath.section].firstName
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommunicationCell", for: indexPath) as! CommunicationCell
            //cell.textLabel?.text = tableViewData[indexPath.section].sectionData[indexPath.row-1]
            cell.testLabel?.text = tableViewData[indexPath.section].sectionData[indexPath.row-1]
            return cell
        }
        /*
        let cell = tableView.dequeueReusableCell(withIdentifier: "PatientCell", for: indexPath) as! PatientTableViewCell
        
        let patient = patienten[indexPath.row]
        let date = patient.birthday
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        cell.backgroundView = UIImageView(image: UIImage(named: "ListElementBackground.png")!)
        cell.surenameLabel?.text = patient.surename
        cell.firstNameLabel?.text = patient.firstName
        cell.sexLabel?.text = patient.sex
        cell.birthdayLabel?.text = dateFormatter.string(from: date)
        cell.sizeLabel?.text = String(patient.size)
        cell.weightLabel?.text = String(patient.weight)
        cell.clinicLabel?.text = patient.clinic
        cell.insuranceLabel?.text = patient.insurance
        print("Name!!!:" + patient.surename)
        return cell
         */
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            //headerView.contentView.backgroundColor = UIColor(red:30.0/255.0, green:37.0/255.0, blue:67.0/255.0, alpha:1.0)
            headerView.contentView.backgroundColor = UIColor(red:38.0/255.0, green:46.0/255.0, blue:84.0/255.0, alpha:1.0)
            headerView.backgroundView?.backgroundColor = .white
            headerView.textLabel?.textColor = .green
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 10))
        returnedView.backgroundColor = UIColor(red:38.0/255.0, green:46.0/255.0, blue:84.0/255.0, alpha:1.0)
        
        return returnedView
    }

    
    //https://www.atomicbird.com/blog/uistackview-table-cells/
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0){
            if(tableViewData[indexPath.section].opened){
                tableViewData[indexPath.section].opened = false
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            }else{
                tableViewData[indexPath.section].opened = true
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            }
        }else{
            //hier passiert was ,wenn man auf die Zellen klickt
        }

    }
    
    @IBAction func click(_ sender: Any) {
        print("I clicktheButton")
    }
    
}
