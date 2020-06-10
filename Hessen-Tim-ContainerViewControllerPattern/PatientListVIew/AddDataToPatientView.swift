//
//  AddDataToPatientView.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 10.06.20.
//  Copyright © 2020 Michael Rojkov. All rights reserved.
//

import Foundation
import UIKit
import SMART



class AddDataToPatientView: UIView {
    
    var resource: ServiceRequest?
    var patient: Patient?
    weak var delegate: HistoryViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let cellView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red:41.0/255.0, green:45.0/255.0, blue:86.0/255.0, alpha:1.0)
        //view.backgroundColor = UIColor.green
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let addPatientData: UILabel = {
        let label = UILabel()
        label.text = "Fügen Sie dem Patienten Daten hinzu"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    func setupView() {
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
        self.addGestureRecognizer(gesture)
        
        addSubview(cellView)
        cellView.addSubview(addPatientData)
        
        
        NSLayoutConstraint.activate([
            cellView.topAnchor.constraint(equalTo: self.topAnchor),
            cellView.rightAnchor.constraint(equalTo: self.rightAnchor),
            cellView.leftAnchor.constraint(equalTo: self.leftAnchor),
            cellView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        addPatientData.heightAnchor.constraint(equalToConstant: 50).isActive = true
        addPatientData.widthAnchor.constraint(equalToConstant: 400).isActive = true
        addPatientData.centerYAnchor.constraint(equalTo: cellView.centerYAnchor).isActive = true
        addPatientData.centerXAnchor.constraint(equalTo: cellView.centerXAnchor).isActive = true
        
        
    }
    
    @objc func checkAction(sender : UITapGestureRecognizer) {
        print("I TAB IN STACKKK")
        Institute.shared.patientObject = patient
        Institute.shared.createServiceRequest(category: "Intensivmedizin", completion: {
            DispatchQueue.main.async {
                self.delegate?.showMedicalDataView()
            }
        })
        
    }
    
}

