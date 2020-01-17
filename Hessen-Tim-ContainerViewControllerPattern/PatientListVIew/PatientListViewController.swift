//
//  PatientListViewController.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 01.07.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import UIKit
import SMART

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

class PatientListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var list: PatientList?
    
    var selectedCellIndexPath: IndexPath?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func goBackToRootTapped(_ sender: Any) {
        performSegue(withIdentifier: "exitToRoot", sender: self)
    }
    
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
        if let count = list?.patients?.count {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PatientCell", for: indexPath) as! PatientTableViewCell
        
        cell.backgroundView = UIImageView(image: UIImage(named: "ListElementBackground.png")!)
        if let patient = list?.patients?[indexPath.row] {
            if let name = patient.name?[0] {
                cell.nachnameLabel?.text = name.family?.string
                cell.vornameLabel?.text = name.given?[0].string
            }
            
        }
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
