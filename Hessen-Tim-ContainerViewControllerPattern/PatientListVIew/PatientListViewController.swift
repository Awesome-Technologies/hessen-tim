//
//  PatientListViewController.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 01.07.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import UIKit

struct PatientSection {
    
    var gruppenname : String
    var patienten : [Patient]
    
}

struct Patient {
    var nachname : String
    var vorname : String
    var geschlecht : String
    var geburtsdatum : Date
    var groeße : Int
    var gewicht : Int
    var klinik : String
    var kostentraeger : String
    
}


class PatientTableViewCell: UITableViewCell {
    @IBOutlet weak var nachnameLabel: UILabel!
    @IBOutlet weak var vornameLabel: UILabel!
    @IBOutlet weak var geschlechtLabel: UILabel!
    @IBOutlet weak var geburtsdatumLabel: UILabel!
    @IBOutlet weak var groeßeLabel: UILabel!
    @IBOutlet weak var gewichtLabel: UILabel!
    @IBOutlet weak var klinikLabel: UILabel!
    @IBOutlet weak var kostentraegerLabel: UILabel!
    
}

fileprivate func parseDate(_ str : String) -> Date {
    let dateFormat = DateFormatter()
    dateFormat.dateFormat = "yyyy-MM-dd"
    return dateFormat.date(from: str)!
}

fileprivate func firstDayOfMonth(date : Date) -> Date {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month], from: date)
    return calendar.date(from: components)!
}



class PatientListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {



    @IBOutlet weak var tableView: UITableView!
    var sections = [PatientSection]()
    
    //variablen zum merken, welche Spalte in welche Richtung sortiert wurde
    var sortNachnameUp = false
    var sortVornameUp = false
    var sortGeschlechtUp = false
    var sortGeburtsdatumUp = false
    var sortGroeßeUp = false
    var sortGewichtUp = false
    var sortKlinikUp = false
    var sortVersicherungUp = false
    
    var patienten = [
        Patient(nachname: "Müller", vorname: "Hans", geschlecht: "M", geburtsdatum: parseDate("1950-02-15"), groeße: 180, gewicht: 71, klinik: "Kassel", kostentraeger: "Allianz"),
        Patient(nachname: "Maier", vorname: "Georg", geschlecht: "M", geburtsdatum: parseDate("1951-06-04"), groeße: 152, gewicht: 69, klinik: "Frankfurt", kostentraeger: "AOK"),
        Patient(nachname: "Kachelman", vorname: "Jörg", geschlecht: "M", geburtsdatum: parseDate("1953-05-01"), groeße: 169, gewicht: 87, klinik: "Frankfurt", kostentraeger: "Allianz"),
        Patient(nachname: "Panzer", vorname: "Paul", geschlecht: "M", geburtsdatum: parseDate("1950-02-18"), groeße: 180, gewicht: 81, klinik: "Frankfurt", kostentraeger: "TK"),
        Patient(nachname: "Geiger", vorname: "Sabine", geschlecht: "W", geburtsdatum: parseDate("1951-06-15"), groeße: 154, gewicht: 53, klinik: "Kassel", kostentraeger: "HUK"),
        Patient(nachname: "Bauer", vorname: "Heiko", geschlecht: "M", geburtsdatum: parseDate("1962-06-28"), groeße: 208, gewicht: 96, klinik: "Kassel", kostentraeger: "AOK"),
    ]
    
    @IBAction func goBackToRootTapped(_ sender: Any) {
        performSegue(withIdentifier: "exitToRoot", sender: self)
    }
    
    @IBAction func sortNachname(_ sender: Any) {
        sortNachname()
        self.tableView.reloadData()
    }
    
    @IBAction func sortVorname(_ sender: Any) {
        sortVornamen()
        self.tableView.reloadData()
    }
    
    @IBAction func sortGeschlecht(_ sender: Any) {
        sortGeschlecht()
        self.tableView.reloadData()
    }
    
    @IBAction func sortGeburtsdatum(_ sender: Any) {
        sortBirthday()
        self.tableView.reloadData()
    }
    
    @IBAction func sortGroeße(_ sender: Any) {
        sortGroeße()
        self.tableView.reloadData()
    }
    
    @IBAction func sortGewicht(_ sender: Any) {
        sortGewicht()
        self.tableView.reloadData()
    }
    
    @IBAction func sortKlinik(_ sender: Any) {
        sortKlinik()
        self.tableView.reloadData()
    }
    
    @IBAction func sortVersicherung(_ sender: Any) {
        sortVersicherung()
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor(red:38.0/255.0, green:46.0/255.0, blue:84.0/255.0, alpha:1.0)
        
        sortNachname()
        
        tableView.rowHeight = 70
        tableView.sectionHeaderHeight = 40
        tableView.sectionFooterHeight = 20
        
        let attributes = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Light", size: 25)!]
        UINavigationBar.appearance().titleTextAttributes = attributes
        
        self.title = "Patientenliste"
        //self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Patientenliste", size: 20)!]
    }
    
    func sortNachname(){
        var dict = Dictionary(grouping: self.patienten) { (patient) in
            return getNachname(name: patient.nachname)
        }
        
        for (key, value) in dict
        {
            dict[key] = value.sorted(by: { $0.nachname < $1.nachname })
        }
        
        if(sortNachnameUp) {
            var sortedDic = dict.sorted { (aDic, bDic) -> Bool in
                return aDic.key > bDic.key
            }
            self.sections = sortedDic.map { (arg) -> PatientSection in
                
                let (key, values) = arg
                return PatientSection(gruppenname: key, patienten: values)
            }
            sortNachnameUp = false
            
        } else {
            var sortedDic = dict.sorted { (aDic, bDic) -> Bool in
                return aDic.key < bDic.key
            }
            self.sections = sortedDic.map { (arg) -> PatientSection in
                
                let (key, values) = arg
                return PatientSection(gruppenname: key, patienten: values)
            }
            sortNachnameUp = true
        }
    }
    
    func sortVornamen(){
        var dict = Dictionary(grouping: self.patienten) { (patient) in
            return String(patient.vorname.first!)
        }
        
        for (key, value) in dict
        {
            dict[key] = value.sorted(by: { $0.vorname < $1.vorname })
        }
        
        if(sortVornameUp) {
            var sortedDic = dict.sorted { (aDic, bDic) -> Bool in
                return aDic.key > bDic.key
            }
            self.sections = sortedDic.map { (arg) -> PatientSection in
                
                let (key, values) = arg
                return PatientSection(gruppenname: key, patienten: values)
            }
            sortVornameUp = false
            
        } else {
            var sortedDic = dict.sorted { (aDic, bDic) -> Bool in
                return aDic.key < bDic.key
            }
            self.sections = sortedDic.map { (arg) -> PatientSection in
                
                let (key, values) = arg
                return PatientSection(gruppenname: key, patienten: values)
            }
            sortVornameUp = true
        }
    }
    
    func sortGeschlecht(){
        var dict = Dictionary(grouping: self.patienten) { (patient) in
            return String(patient.geschlecht.first!)
        }
        
        for (key, value) in dict
        {
            dict[key] = value.sorted(by: { $0.nachname < $1.nachname })
        }
        
        if(sortGeschlechtUp) {
            var sortedDic = dict.sorted { (aDic, bDic) -> Bool in
                return aDic.key > bDic.key
            }
            self.sections = sortedDic.map { (arg) -> PatientSection in
                
                let (key, values) = arg
                return PatientSection(gruppenname: key, patienten: values)
            }
            sortGeschlechtUp = false
            
        } else {
            var sortedDic = dict.sorted { (aDic, bDic) -> Bool in
                return aDic.key < bDic.key
            }
            self.sections = sortedDic.map { (arg) -> PatientSection in
                
                let (key, values) = arg
                return PatientSection(gruppenname: key, patienten: values)
            }
            sortGeschlechtUp = true
        }
    }
    
    func sortBirthday(){
        
        //Erstelle ein Dict indem alle Patienten anhand des Geburtsmonats sortiert werden
        var dict = Dictionary(grouping: self.patienten) { (patient) in
            return firstDayOfMonth(date: patient.geburtsdatum)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        
        if sortGeburtsdatumUp {
            
            //Sortiere das Dict, damit die einzelnen Einträge in den keys absteigen angezeigt werden
            for (key, value) in dict
            {
                dict[key] = value.sorted(by: { $0.geburtsdatum > $1.geburtsdatum })
            }
            
            //Sortiere das Dict, damit die Reihenfolfe der keys absteigend angezeigt wird
            var sortedDic = dict.sorted { (aDic, bDic) -> Bool in
                return aDic.key > bDic.key
            }
            
            //Mappe das Dict auf die Struct, um später die Daten einfacher abzugreifen
            self.sections = sortedDic.map { (arg) -> PatientSection in
                
                let (key, values) = arg
                return PatientSection(gruppenname: dateFormatter.string(from: key), patienten: values)
            }
            
            //Aktualisiere die Variable für die Sortierung
            sortGeburtsdatumUp = false
            
        } else {
            
            for (key, value) in dict
            {
                dict[key] = value.sorted(by: { $0.geburtsdatum < $1.geburtsdatum })
            }
            
            var sortedDic = dict.sorted { (aDic, bDic) -> Bool in
                return aDic.key < bDic.key
            }
            
            self.sections = sortedDic.map { (arg) -> PatientSection in
                
                let (key, values) = arg
                return PatientSection(gruppenname: dateFormatter.string(from: key), patienten: values)
            }
            
            sortGeburtsdatumUp = true
            
        }
    }

    func sortGroeße(){
        var dict = Dictionary(grouping: self.patienten) { (patient) in
            return patient.groeße
        }
        
        if(sortGroeßeUp) {
            for (key, value) in dict
            {
                dict[key] = value.sorted(by: { $0.nachname < $1.nachname })
            }
            
            var sortedDic = dict.sorted { (aDic, bDic) -> Bool in
                return aDic.key < bDic.key
            }
            self.sections = sortedDic.map { (arg) -> PatientSection in
                
                let (key, values) = arg
                return PatientSection(gruppenname: String(key), patienten: values)
            }
            sortGroeßeUp = false
            
        } else {
            for (key, value) in dict
            {
                dict[key] = value.sorted(by: { $0.nachname < $1.nachname })
            }
            
            var sortedDic = dict.sorted { (aDic, bDic) -> Bool in
                return aDic.key > bDic.key
            }
            self.sections = sortedDic.map { (arg) -> PatientSection in
                
                let (key, values) = arg
                return PatientSection(gruppenname: String(key), patienten: values)
            }
            sortGroeßeUp = true
        }
    }
    
    func sortGewicht(){
        var dict = Dictionary(grouping: self.patienten) { (patient) in
            return patient.gewicht
        }
        
        if(sortGewichtUp) {
            for (key, value) in dict
            {
                dict[key] = value.sorted(by: { $0.nachname < $1.nachname })
            }
            
            var sortedDic = dict.sorted { (aDic, bDic) -> Bool in
                return aDic.key < bDic.key
            }
            self.sections = sortedDic.map { (arg) -> PatientSection in
                
                let (key, values) = arg
                return PatientSection(gruppenname: String(key), patienten: values)
            }
            sortGewichtUp = false
            
        } else {
            for (key, value) in dict
            {
                dict[key] = value.sorted(by: { $0.nachname < $1.nachname })
            }
            
            var sortedDic = dict.sorted { (aDic, bDic) -> Bool in
                return aDic.key > bDic.key
            }
            self.sections = sortedDic.map { (arg) -> PatientSection in
                
                let (key, values) = arg
                return PatientSection(gruppenname: String(key), patienten: values)
            }
            sortGewichtUp = true
        }
    }
    
    func sortKlinik(){
        var dict = Dictionary(grouping: self.patienten) { (patient) in
            return patient.klinik
        }
        
        for (key, value) in dict
        {
            dict[key] = value.sorted(by: { $0.nachname < $1.nachname })
        }
        
        if(sortKlinikUp) {
            var sortedDic = dict.sorted { (aDic, bDic) -> Bool in
                return aDic.key > bDic.key
            }
            self.sections = sortedDic.map { (arg) -> PatientSection in
                
                let (key, values) = arg
                return PatientSection(gruppenname: key, patienten: values)
            }
            sortKlinikUp = false
            
        } else {
            var sortedDic = dict.sorted { (aDic, bDic) -> Bool in
                return aDic.key < bDic.key
            }
            self.sections = sortedDic.map { (arg) -> PatientSection in
                
                let (key, values) = arg
                return PatientSection(gruppenname: key, patienten: values)
            }
            sortKlinikUp = true
        }
    }
    
    func sortVersicherung(){
        var dict = Dictionary(grouping: self.patienten) { (patient) in
            return patient.kostentraeger
        }
        
        for (key, value) in dict
        {
            dict[key] = value.sorted(by: { $0.nachname < $1.nachname })
        }
        
        if(sortVersicherungUp) {
            var sortedDic = dict.sorted { (aDic, bDic) -> Bool in
                return aDic.key > bDic.key
            }
            self.sections = sortedDic.map { (arg) -> PatientSection in
                
                let (key, values) = arg
                return PatientSection(gruppenname: key, patienten: values)
            }
            sortVersicherungUp = false
            
        } else {
            var sortedDic = dict.sorted { (aDic, bDic) -> Bool in
                return aDic.key < bDic.key
            }
            self.sections = sortedDic.map { (arg) -> PatientSection in
                
                let (key, values) = arg
                return PatientSection(gruppenname: key, patienten: values)
            }
            sortVersicherungUp = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Do any additional setup after loading the view.
        
        var x = UIScreen.main.bounds.minX + (UIScreen.main.bounds.width * 0.02)
        var y = UIScreen.main.bounds.minY + (UIScreen.main.bounds.height * 0.035)
        var width = UIScreen.main.bounds.width * 0.055
        
        var height = width

        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func getNachname(name : String) -> String {
        return String(name.first!)
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
        return section.patienten.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PatientCell", for: indexPath) as! PatientTableViewCell
        
        let section = self.sections[indexPath.section]
        let patient = section.patienten[indexPath.row]
        let date = patient.geburtsdatum
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        cell.backgroundView = UIImageView(image: UIImage(named: "ListElementBackground.png")!)
        cell.nachnameLabel?.text = patient.nachname
        cell.vornameLabel?.text = patient.vorname
        cell.geschlechtLabel?.text = patient.geschlecht
        cell.geburtsdatumLabel?.text = dateFormatter.string(from: date)
        cell.groeßeLabel?.text = String(patient.groeße)
        cell.gewichtLabel?.text = String(patient.gewicht)
        cell.klinikLabel?.text = patient.klinik
        cell.kostentraegerLabel?.text = patient.kostentraeger
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
            //headerView.contentView.backgroundColor = UIColor(red:30.0/255.0, green:37.0/255.0, blue:67.0/255.0, alpha:1.0)
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
