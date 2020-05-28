//
//  ServiceRequestView.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 25.04.20.
//  Copyright © 2020 Michael Rojkov. All rights reserved.
//

import Foundation
import UIKit
import SMART



class ServiceRequestView: UIView {
    
    var resource: ServiceRequest?
    var patient: Patient?
    var isLatest = false
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
    
    let icon: UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage(named:"consilButton.png")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
        
    }()
    
    let dateIssued: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let preview: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = UIColor.white
        label.textAlignment = .right
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func setupView() {
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
        self.addGestureRecognizer(gesture)
        
        addSubview(cellView)
        cellView.addSubview(icon)
        cellView.addSubview(dateIssued)
        cellView.addSubview(preview)
        
        
        NSLayoutConstraint.activate([
            cellView.topAnchor.constraint(equalTo: self.topAnchor),
            cellView.rightAnchor.constraint(equalTo: self.rightAnchor),
            cellView.leftAnchor.constraint(equalTo: self.leftAnchor),
            cellView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        icon.heightAnchor.constraint(equalToConstant: 40).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 55).isActive = true
        icon.centerYAnchor.constraint(equalTo: cellView.centerYAnchor).isActive = true
        icon.leftAnchor.constraint(equalTo: cellView.leftAnchor, constant: 20).isActive = true
        
        dateIssued.heightAnchor.constraint(equalToConstant: 50).isActive = true
        dateIssued.widthAnchor.constraint(equalToConstant: 200).isActive = true
        dateIssued.centerYAnchor.constraint(equalTo: cellView.centerYAnchor).isActive = true
        dateIssued.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 50).isActive = true
        
        preview.heightAnchor.constraint(equalToConstant: 50).isActive = true
        preview.widthAnchor.constraint(equalToConstant: 300).isActive = true
        preview.centerYAnchor.constraint(equalTo: cellView.centerYAnchor).isActive = true
        preview.rightAnchor.constraint(equalTo: cellView.rightAnchor, constant: -50).isActive = true
        
    }
    
    func ReportDateFormater(item: ServiceRequest)->String{
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSZ"
        
        let clockTime = DateFormatter()
        clockTime.dateFormat = "HH:mm"
        
        let dateTime = DateFormatter()
        dateTime.dateFormat = "dd.MM.yyyy"
        
        var printdate = ""
        if let date = dateFormatterGet.date(from: (item.authoredOn?.description)!) {
            
            var clock = clockTime.string(from: date)
            var date = dateTime.string(from: date)
            printdate = clock + "     " + date
            
        } else {
            print("There was an error decoding the string")
        }
        return printdate
        
    }
    
    @objc func checkAction(sender : UITapGestureRecognizer) {
        print("Selected Service Request \(resource?.id?.string ?? "n/a")")
        Institute.shared.patientObject = patient
        guard let patient = patient, let request = resource else { return }
        self.delegate?.showMedicalDataView(patient: patient, serviceRequest: request, isLatest: isLatest)
    }
}
