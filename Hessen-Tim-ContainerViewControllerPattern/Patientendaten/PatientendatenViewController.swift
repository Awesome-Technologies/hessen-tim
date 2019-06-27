//
//  PatientendatenViewController.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 27.06.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import UIKit

class PatientendatenViewController: UIViewController {
    
    var collapseMaster:UIBarButtonItem!
    
    //https://github.com/jriosdev/iOSDropDown
    @IBOutlet weak var patientDataDropdown: DropDown!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collapseMaster = UIBarButtonItem(title: "Information", style: .done, target: self, action: #selector(collapse))
        self.navigationItem.rightBarButtonItem = collapseMaster
        
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
        dismiss(animated: true, completion: nil)
    }

}
