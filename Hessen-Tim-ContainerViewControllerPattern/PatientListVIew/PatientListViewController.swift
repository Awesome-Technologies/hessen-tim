//
//  PatientListViewController.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 01.07.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import UIKit
import SMART

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
    @IBOutlet weak var subview1: UIView!{
    didSet {
        subview1.isHidden = true
        }
    }
    @IBOutlet weak var subview2: UIView!{
    didSet {
        subview2.isHidden = true
        }
    }
    @IBOutlet weak var subview3: UIView!{
    didSet {
        subview3.isHidden = true
        }
    }
    @IBOutlet weak var subview4: UIView!{
    didSet {
        subview4.isHidden = true
        }
    }
    
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
    
    @IBAction func goBackToRootTapped(_ sender: Any) {
        performSegue(withIdentifier: "exitToRoot", sender: self)
    }
    
    var patienten: Array<Patient> = [
        Patient(surename: "Müller", firstName: "Hans", sex: "M", birthday: parseDate("1950-02-15"), size: 180, weight: 71, clinic: "Kassel", insurance: "Allianz"),
        Patient(surename: "Maier", firstName: "Georg", sex: "M", birthday: parseDate("1951-06-04"), size: 152, weight: 69, clinic: "Frankfurt", insurance: "AOK"),
        Patient(surename: "Kachelman", firstName: "Jörg", sex: "M", birthday: parseDate("1953-05-01"), size: 169, weight: 87, clinic: "Frankfurt", insurance: "Allianz"),
        Patient(surename: "Panzer", firstName: "Paul", sex: "M", birthday: parseDate("1950-02-18"), size: 180, weight: 81, clinic: "Frankfurt", insurance: "TK"),
        Patient(surename: "Geiger", firstName: "Sabine", sex: "W", birthday: parseDate("1951-06-15"), size: 154, weight: 53, clinic: "Kassel", insurance: "HUK"),
        Patient(surename: "Bauer", firstName: "Heiko", sex: "M", birthday: parseDate("1962-06-28"), size: 208, weight: 96, clinic: "Kassel", insurance: "AOK"),
    ]
    
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
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return patienten.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PatientCell", for: indexPath) as! PatientTableViewCell
        
        let patient = patienten[indexPath.row]
        let date = patient.birthday
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        cell.backgroundView = UIImageView(image: UIImage(named: "ListElementBackground.png")!)
        cell.nachnameLabel?.text = patient.surename
        cell.vornameLabel?.text = patient.firstName
        return cell
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
    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      selectedCellIndexPath = selectedCellIndexPath == indexPath ? nil : indexPath
      tableView.beginUpdates()
      tableView.endUpdates()
    }
    */
    //https://www.atomicbird.com/blog/uistackview-table-cells/
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? PatientTableViewCell {
            tableView.beginUpdates()
            cell.subview1.isHidden = !cell.subview1.isHidden
            cell.subview2.isHidden = !cell.subview2.isHidden
            cell.subview3.isHidden = !cell.subview3.isHidden
            cell.subview4.isHidden = !cell.subview4.isHidden
            tableView.deselectRow(at: indexPath, animated: true)
            tableView.endUpdates()
        }
    }

    /*
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      if selectedCellIndexPath == indexPath {
        return 250
      }
      return 65
    }
     */
    
    @IBAction func click(_ sender: Any) {
        print("I clicktheButton")
    }
    
}
