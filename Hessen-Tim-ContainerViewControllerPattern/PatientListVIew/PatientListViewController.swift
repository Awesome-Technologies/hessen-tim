//
//  PatientListViewController.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 01.07.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import UIKit

struct Patient {
    var nachname : String
    var vorname : String
    var geschlecht : String
    var geburtsdatum : String
    var groeße : String
    var gewicht : String
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



class PatientListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {



    @IBOutlet weak var backButton: UIView!
    @IBOutlet weak var patient1: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var patienten = [
        Patient(nachname: "Müller", vorname: "Hans", geschlecht: "M", geburtsdatum: "25.03.1948 (70)", groeße: "169cm", gewicht: "71kg", klinik: "Kassel", kostentraeger: "Allianz"),
        Patient(nachname: "Kachelman", vorname: "Jörg", geschlecht: "M", geburtsdatum: "25.03.1948 (70)", groeße: "169cm", gewicht: "71kg", klinik: "Kassel", kostentraeger: "Allianz"),
        Patient(nachname: "Panzer", vorname: "Paul", geschlecht: "M", geburtsdatum: "25.03.1948 (70)", groeße: "169cm", gewicht: "71kg", klinik: "Kassel", kostentraeger: "Allianz"),
        Patient(nachname: "Geiger", vorname: "Sabine", geschlecht: "W", geburtsdatum: "25.03.1948 (70)", groeße: "169cm", gewicht: "48kg", klinik: "Kassel", kostentraeger: "Allianz"),
        Patient(nachname: "Bauer", vorname: "Heiko", geschlecht: "M", geburtsdatum: "25.03.1948 (70)", groeße: "169cm", gewicht: "71kg", klinik: "Kassel", kostentraeger: "Allianz"),
    ]
    
    @IBAction func goBackToRootTapped(_ sender: Any) {
        performSegue(withIdentifier: "exitToRoot", sender: self)
    }
    
    @IBAction func sortNachname(_ sender: Any) {
        patienten.sort { $0.nachname < $1.nachname }
        self.tableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Do any additional setup after loading the view.
        
        var x = UIScreen.main.bounds.minX + (UIScreen.main.bounds.width * 0.02)
        var y = UIScreen.main.bounds.minY + (UIScreen.main.bounds.height * 0.035)
        var width = UIScreen.main.bounds.width * 0.055

        var height = width
        
        backButton.frame = CGRect(x: x, y: y, width: width, height: height)
        
        x = UIScreen.main.bounds.minX + (UIScreen.main.bounds.width * 0.07)
        y = UIScreen.main.bounds.minY + (UIScreen.main.bounds.height * 0.22)
        width = UIScreen.main.bounds.width * 0.85
        height = UIScreen.main.bounds.height * 0.1

        
        patient1.frame = CGRect(x: x, y: y, width: width, height: height)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print(patienten.count)
        return patienten.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PatientCell", for: indexPath) as! PatientTableViewCell
        
        let patient = patienten[indexPath.row]
        cell.nachnameLabel?.text = patient.nachname
        cell.vornameLabel?.text = patient.vorname
        cell.geschlechtLabel?.text = patient.geschlecht
        cell.geburtsdatumLabel?.text = patient.geburtsdatum
        cell.groeßeLabel?.text = patient.groeße
        cell.gewichtLabel?.text = patient.gewicht
        cell.klinikLabel?.text = patient.klinik
        cell.kostentraegerLabel?.text = patient.kostentraeger
        
        print(indexPath.row)
        print(cell.nachnameLabel?.text)
        
        return cell
    }


    
}
