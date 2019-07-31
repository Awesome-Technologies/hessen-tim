//
//  OrderListViewController.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 01.07.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import UIKit

struct OrderSection {
    
    var gruppenname : String
    var order : [Order]
    
}

struct Order {
    var datum : Date
    var nr : Int
    var patient : String
    var klinik : String
    var abteilung : String
    var status : String
    
}

class FallTableViewCell: UITableViewCell {
    @IBOutlet weak var datumLabel: UILabel!
    @IBOutlet weak var nummerLabel: UILabel!
    @IBOutlet weak var patientLabel: UILabel!
    @IBOutlet weak var klinikLabel: UILabel!
    @IBOutlet weak var abteilungLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    var tapAction: ((UITableViewCell) -> Void)?
    
    //https://web.archive.org/web/20160730215620/http://candycode.io/how-to-properly-do-buttons-in-table-view-cells-using-swift-closures/
    @IBAction func deleteElement(_ sender: Any) {
        tapAction?(self)
    }
    
}

fileprivate func parseDate(_ str : String) -> Date {
    let dateFormat = DateFormatter()
    dateFormat.dateFormat = "yyyy-MM-dd"
    return dateFormat.date(from: str)!
}



class OrderListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var sections = [OrderSection]()
    
    //variablen zum merken, welche Spalte in welche Richtung sortiert wurde
    var sortDatumUp = false
    var sortNrUp = false
    var sortPatientUp = false
    var sortKlinikUp = false
    var sortAbteilungUp = false
    var sortStatusp = false
    
    @IBAction func sortDatum(_ sender: Any) {
        sortDatum()
        self.tableView.reloadData()
    }
    @IBAction func sortNummer(_ sender: Any) {
        sortNummer()
        self.tableView.reloadData()
    }
    @IBAction func sortPatient(_ sender: Any) {
        sortPatient()
        self.tableView.reloadData()
    }
    @IBAction func sortKlinik(_ sender: Any) {
        sortKlinik()
        self.tableView.reloadData()
    }
    @IBAction func sortAbteilung(_ sender: Any) {
        sortAbteilung()
        self.tableView.reloadData()
    }
    
    
    //Beispieldaten
    var orders = [
        Order(datum: parseDate("2019-02-16"),nr: 3, patient: "Müller Hans", klinik: "Kassel", abteilung: "Infektiologie", status: "nicht bearbeitet"),
        Order(datum: parseDate("2019-04-03"),nr: 4, patient: "Meister Max", klinik: "Kassel", abteilung: "Neurologie", status: "nicht bearbeitet"),
        Order(datum: parseDate("2019-06-25"),nr: 7, patient: "Seifert Frank", klinik: "Göttingen", abteilung: "Infektiologie", status: "nicht bearbeitet"),
        Order(datum: parseDate("2019-01-03"),nr: 1, patient: "Krause Thomas", klinik: "Kassel", abteilung: "Infektiologie", status: "bearbeitet"),
        Order(datum: parseDate("2019-06-03"),nr: 6, patient: "Bauer Michaela", klinik: "Göttingen", abteilung: "Neurologie", status: "nicht bearbeitet"),
        Order(datum: parseDate("2018-05-04"),nr: 5, patient: "Schmied Sabine", klinik: "Kassel", abteilung: "Infektiologie", status: "bearbeitet"),
        Order(datum: parseDate("2019-01-24"),nr: 2, patient: "Kachel Hans", klinik: "Münden", abteilung: "Infektiologie", status: "nicht bearbeitet"),
        Order(datum: parseDate("2018-11-24"),nr: 8, patient: "Stolz Sebastian", klinik: "Kassel", abteilung: "Infektiologie", status: "bearbeitet"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor(red:38.0/255.0, green:46.0/255.0, blue:84.0/255.0, alpha:1.0)
        
        sortDatum()
        
        tableView.rowHeight = 70
        tableView.sectionHeaderHeight = 55
        tableView.sectionFooterHeight = 10
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @IBAction func goBackToRootTapped(_ sender: Any) {
        performSegue(withIdentifier: "exitToRoot", sender: self)
    }
    
    
    func sortDatum(){
        
        //Erstelle ein Dict indem alle Patienten anhand des Geburtsmonats sortiert werden
        var dict = Dictionary(grouping: self.orders) { (order) in
            return order.status
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        
        if sortDatumUp {
            
            //Sortiere das Dict, damit die einzelnen Einträge in den keys absteigen angezeigt werden
            for (key, value) in dict
            {
                dict[key] = value.sorted(by: { $0.datum > $1.datum })
            }
            
            //Aktualisiere die Variable für die Sortierung
            sortDatumUp = false
            
        } else {
            
            for (key, value) in dict
            {
                dict[key] = value.sorted(by: { $0.datum < $1.datum })
            }
            
            sortDatumUp = true
            
        }
        
        //Sortiere das Dict, damit die Reihenfolfe der keys absteigend angezeigt wird
        var sortedDic = dict.sorted { (aDic, bDic) -> Bool in
            return aDic.key > bDic.key
        }
        
        //Mappe das Dict auf die Struct, um später die Daten einfacher abzugreifen
        self.sections = sortedDic.map { (arg) -> OrderSection in
            
            let (key, values) = arg
            return OrderSection(gruppenname: key, order: values)
        }
    }
    
    func sortNummer(){
        //Erstelle ein Dict indem alle Patienten anhand des Geburtsmonats sortiert werden
        var dict = Dictionary(grouping: self.orders) { (order) in
            return order.status
        }
        
        if(sortNrUp) {
            for (key, value) in dict
            {
                dict[key] = value.sorted(by: { $0.nr < $1.nr })
            }
            
            sortNrUp = false
            
        } else {
            for (key, value) in dict
            {
                dict[key] = value.sorted(by: { $0.nr > $1.nr })
            }
            
            sortNrUp = true
        }
        
        var sortedDic = dict.sorted { (aDic, bDic) -> Bool in
            return aDic.key > bDic.key
        }
        
        //Mappe das Dict auf die Struct, um später die Daten einfacher abzugreifen
        self.sections = sortedDic.map { (arg) -> OrderSection in
            
            let (key, values) = arg
            return OrderSection(gruppenname: key, order: values)
        }
    }
    
    func sortPatient(){
        //Erstelle ein Dict indem alle Patienten anhand des Geburtsmonats sortiert werden
        var dict = Dictionary(grouping: self.orders) { (order) in
            return order.status
        }
        
        if(sortPatientUp) {
            for (key, value) in dict
            {
                dict[key] = value.sorted(by: { $0.patient < $1.patient })
            }
            
            sortPatientUp = false
            
        } else {
            for (key, value) in dict
            {
                dict[key] = value.sorted(by: { $0.patient > $1.patient })
            }
            
            sortPatientUp = true
        }
        
        var sortedDic = dict.sorted { (aDic, bDic) -> Bool in
            return aDic.key > bDic.key
        }
        
        //Mappe das Dict auf die Struct, um später die Daten einfacher abzugreifen
        self.sections = sortedDic.map { (arg) -> OrderSection in
            
            let (key, values) = arg
            return OrderSection(gruppenname: key, order: values)
        }
    }
    
    func sortKlinik(){
        //Erstelle ein Dict indem alle Patienten anhand des Geburtsmonats sortiert werden
        var dict = Dictionary(grouping: self.orders) { (order) in
            return order.status
        }
        
        if(sortKlinikUp) {
            for (key, value) in dict
            {
                dict[key] = value.sorted(by: { $0.klinik < $1.klinik })
            }
            
            sortKlinikUp = false
            
        } else {
            for (key, value) in dict
            {
                dict[key] = value.sorted(by: { $0.klinik > $1.klinik })
            }
            
            sortKlinikUp = true
        }
        
        var sortedDic = dict.sorted { (aDic, bDic) -> Bool in
            return aDic.key > bDic.key
        }
        
        //Mappe das Dict auf die Struct, um später die Daten einfacher abzugreifen
        self.sections = sortedDic.map { (arg) -> OrderSection in
            
            let (key, values) = arg
            return OrderSection(gruppenname: key, order: values)
        }
    }
    
    func sortAbteilung(){
        //Erstelle ein Dict indem alle Patienten anhand des Geburtsmonats sortiert werden
        var dict = Dictionary(grouping: self.orders) { (order) in
            return order.status
        }
        
        if(sortAbteilungUp) {
            for (key, value) in dict
            {
                dict[key] = value.sorted(by: { $0.abteilung < $1.abteilung })
            }
            
            sortAbteilungUp = false
            
        } else {
            for (key, value) in dict
            {
                dict[key] = value.sorted(by: { $0.abteilung > $1.abteilung })
            }
            
            sortAbteilungUp = true
        }
        
        var sortedDic = dict.sorted { (aDic, bDic) -> Bool in
            return aDic.key > bDic.key
        }
        
        //Mappe das Dict auf die Struct, um später die Daten einfacher abzugreifen
        self.sections = sortedDic.map { (arg) -> OrderSection in
            
            let (key, values) = arg
            return OrderSection(gruppenname: key, order: values)
        }
    }
    
    func deleteElement(item : Int){
        print("lösche ", item)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
    return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = self.sections[section]
        return section.gruppenname
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = self.sections[section]
        return section.order.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath) as! FallTableViewCell
        
        let section = self.sections[indexPath.section]
        let fall = section.order[indexPath.row]
        let date = fall.datum
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        
        cell.backgroundView = UIImageView(image: UIImage(named: "ListElementBackground.png")!)
        cell.datumLabel?.text = dateFormatter.string(from: date)
        cell.nummerLabel?.text = String(fall.nr)
        cell.patientLabel?.text = fall.patient
        cell.klinikLabel?.text = fall.klinik
        cell.abteilungLabel?.text = fall.abteilung
        cell.statusLabel?.text = fall.status
        
        //Assign the tap action which will be executed when the user taps the UIButton
        cell.tapAction = { (cell) in
            //self.showAlertForRow(tableView.indexPathForCell(cell)!.row)
            //print(tableView.indexPath(for: cell)!)
            //print(tableView.cellForRow(at: tableView.indexPath(for: cell)!)?.textLabel )
            let newCell = cell as! FallTableViewCell
            let deleteNr = Int(newCell.nummerLabel!.text!)
            self.deleteElement(item: deleteNr!)
        }
        
        return cell
    }
    /*
     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
     let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
     returnedView.backgroundColor = .lightGray
     
     let label = UILabel(frame: CGRect(x: 10, y: 7, width: view.frame.size.width, height: 25))
     label.text = self.sections[section].gruppenname
     label.textColor = .black
     returnedView.addSubview(label)
     
     return returnedView
     }
     */
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.contentView.backgroundColor = UIColor(red:38.0/255.0, green:46.0/255.0, blue:84.0/255.0, alpha:1.0)
            headerView.backgroundView?.backgroundColor = .white
            headerView.textLabel?.textColor = .green
        }
    }
    /*
     func tableView(_ tableView: UITableView, titleForFooterInSection
     section: Int) -> String? {
     if (section == self.sections.count-1) {
     return ""
     } else {
     //tableView.backgroundColor = .green
     //tableView.backgroundColor = UIColor(red:38.0/255.0, green:46.0/255.0, blue:84.0/255.0, alpha:1.0)
     return " "
     }
     }
     */
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 10))
        returnedView.backgroundColor = UIColor(red:38.0/255.0, green:46.0/255.0, blue:84.0/255.0, alpha:1.0)
        
        return returnedView
    }
    
}
