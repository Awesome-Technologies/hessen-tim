//
//  ExpandableHistoryCell.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 28.04.20.
//  Copyright © 2020 Michael Rojkov. All rights reserved.
//

import UIKit
import SMART
import RxSwift

class ExpandableHistoryCell: UITableViewCell {
    weak var delegate: ExpandableCellDelegate?
    weak var historyDelegate: HistoryViewDelegate?
    
    private var bag = DisposeBag()
    
    var weight: Observation?
    var height: Observation?
    var coverage: Coverage?
    var patient : Patient? {
        didSet {
            guard let patient = patient else { return }
            
            self.patientName.text = (patient.name?[0].family!.string)! + " " + (patient.name?[0].given?[0].string)!
            if(patient.gender == AdministrativeGender(rawValue: "male")){
                self.patientSex.text = "M"
            }else{
                self.patientSex.text = "W"
            }
            self.patientBirthday.text = patient.birthDate?.description
            setupHistoryObservable()
        }
    }
    
    fileprivate let stack = UIStackView()
    
    var isExpanded: Bool = false {
        didSet {
            
            for subview in stack.arrangedSubviews {
                subview.isHidden = !isExpanded
            }
            if(isExpanded){
                self.greenBorder()
                self.setPatientData()
            } else{
                self.whiteBorder()
            }
            delegate?.expandableCellLayoutChanged(self)
        }
    }
    
    var patientView: UIView = {
        var imview = UIView()
        imview.translatesAutoresizingMaskIntoConstraints = false
        return imview
    }()
    
    let patientName: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.textAlignment = .left
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let patientSex: UILabel = {
        let label = UILabel()
        label.text = "Sex"
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let patientBirthday: UILabel = {
        let label = UILabel()
        label.text = "Birthday"
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let patientSize: UILabel = {
        let label = UILabel()
        label.text = "Height"
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let patientWeight: UILabel = {
        let label = UILabel()
        label.text = "Weight"
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let patientClinic: UILabel = {
        let label = UILabel()
        label.text = "Clinic"
        label.textAlignment = .right
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = 10
        self.selectionStyle = .none
        self.addSubview(patientView)
        self.addSubview(stack)
        
        createPatientView()
        createStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func createPatientView(){
        
        patientView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        patientView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        patientView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        patientView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        patientView.bottomAnchor.constraint(equalTo: stack.topAnchor, constant: 0).isActive = true
        
        patientView.layer.cornerRadius = 10
        patientView.layer.borderWidth = 1
        patientView.layer.borderColor = UIColor.white.cgColor
        patientView.self.backgroundColor = UIColor(red: 45/255, green: 55/255, blue: 95/255, alpha: 1)
        
        patientView.addSubview(patientName)
        
        patientName.heightAnchor.constraint(equalToConstant: 50).isActive = true
        patientName.widthAnchor.constraint(equalToConstant: 150).isActive = true
        patientName.centerYAnchor.constraint(equalTo: patientView.centerYAnchor).isActive = true
        patientName.leftAnchor.constraint(equalTo: patientView.leftAnchor, constant: 50).isActive = true
        
        patientView.addSubview(patientSex)
        
        patientSex.heightAnchor.constraint(equalToConstant: 50).isActive = true
        patientSex.widthAnchor.constraint(equalToConstant: 30).isActive = true
        patientSex.centerYAnchor.constraint(equalTo: patientView.centerYAnchor).isActive = true
        patientSex.leftAnchor.constraint(equalTo: patientName.rightAnchor, constant: 50).isActive = true
        
        patientView.addSubview(patientBirthday)
        
        patientBirthday.heightAnchor.constraint(equalToConstant: 50).isActive = true
        patientBirthday.widthAnchor.constraint(equalToConstant: 150).isActive = true
        patientBirthday.centerYAnchor.constraint(equalTo: patientView.centerYAnchor).isActive = true
        patientBirthday.leftAnchor.constraint(equalTo: patientSex.rightAnchor, constant: 50).isActive = true
        
        patientView.addSubview(patientSize)
        
        patientSize.heightAnchor.constraint(equalToConstant: 50).isActive = true
        patientSize.widthAnchor.constraint(equalToConstant: 100).isActive = true
        patientSize.centerYAnchor.constraint(equalTo: patientView.centerYAnchor).isActive = true
        patientSize.leftAnchor.constraint(equalTo: patientBirthday.rightAnchor, constant: 50).isActive = true
        
        patientView.addSubview(patientWeight)
        
        patientWeight.heightAnchor.constraint(equalToConstant: 50).isActive = true
        patientWeight.widthAnchor.constraint(equalToConstant: 100).isActive = true
        patientWeight.centerYAnchor.constraint(equalTo: patientView.centerYAnchor).isActive = true
        patientWeight.leftAnchor.constraint(equalTo: patientSize.rightAnchor, constant: 50).isActive = true
        
        patientView.addSubview(patientClinic)
        
        patientClinic.heightAnchor.constraint(equalToConstant: 50).isActive = true
        patientClinic.widthAnchor.constraint(equalToConstant: 100).isActive = true
        patientClinic.centerYAnchor.constraint(equalTo: patientView.centerYAnchor).isActive = true
        patientClinic.leftAnchor.constraint(equalTo: patientWeight.rightAnchor, constant: 50).isActive = true
        
        
        
    }
    
    func createStackView(){
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: patientView.bottomAnchor, constant: 0),
            stack.leftAnchor.constraint(equalTo: self.leftAnchor),
            stack.rightAnchor.constraint(equalTo: self.rightAnchor),
            stack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -40),
        ])
        
        stack.addBackground(color: UIColor(red: 45/255, green: 55/255, blue: 95/255, alpha: 1))
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 0
    }
    
    func setupHistoryObservable() {
        guard let patient = patient else { return }
        bag = DisposeBag()
        
        let repo = Repository.instance
        repo.getHistoryObservable(forPatient: patient)
            .subscribe(onNext: { (history) in
                self.rebuildHistoryStackView(history)
            })
            .disposed(by: bag)
    }
    
    func rebuildHistoryStackView(_ history: [DomainResource]) {
        let views = stack.arrangedSubviews
        views.forEach { (view) in
            stack.removeArrangedSubview(view)
        }
        
        var firstServiceRequest = true
        for item in history {
            let containerView = UIView()
            stack.addArrangedSubview(containerView)
            containerView.backgroundColor = UIColor.clear
            containerView.layer.cornerRadius = 10
            containerView.leftAnchor.constraint(equalTo: stack.leftAnchor, constant: 0).isActive = true
            containerView.rightAnchor.constraint(equalTo: stack.rightAnchor, constant: 0).isActive = true
            containerView.isHidden = true
            containerView.translatesAutoresizingMaskIntoConstraints = false
            
            if let report = item as? DiagnosticReport {
                containerView.heightAnchor.constraint(equalToConstant: 80).isActive = true
                let historyView = DiagnosticReportView()
                containerView.addSubview(historyView)
                historyView.resource = report
                historyView.delegate = self.historyDelegate
                historyView.translatesAutoresizingMaskIntoConstraints = false
                historyView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive = true
                historyView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10).isActive = true
                historyView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
                historyView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
                historyView.layer.cornerRadius = 10
                historyView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 200).isActive = true
                historyView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -50).isActive = true
                historyView.dateIssued.text = historyView.ReportDateFormater(item: report)
                historyView.preview.text = report.conclusion?.description
                historyView.translatesAutoresizingMaskIntoConstraints = false
                historyView.layer.borderWidth = 1
                historyView.layer.borderColor = UIColor.white.cgColor
                
            } else if let request = item as? ServiceRequest {
                containerView.heightAnchor.constraint(equalToConstant: 60).isActive = true
                let historyView = ServiceRequestView()
                containerView.addSubview(historyView)
                historyView.delegate = self.historyDelegate
                historyView.resource = request
                historyView.patient = self.patient
                historyView.isLatest = firstServiceRequest
                firstServiceRequest = false
                historyView.translatesAutoresizingMaskIntoConstraints = false
                historyView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
                historyView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 1).isActive = true
                historyView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
                historyView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
                historyView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 50).isActive = true
                historyView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -200).isActive = true
                historyView.layer.cornerRadius = 10
                historyView.dateIssued.text = historyView.ReportDateFormater(item: request)
                historyView.preview.text = (request.id!.description) + " Neue Informationen"
                historyView.translatesAutoresizingMaskIntoConstraints = false
                historyView.layer.borderWidth = 1
                historyView.layer.borderColor = UIColor.white.cgColor
            }else{
                //Create a custom cell, when no communication history is present for the patient
                let containerView = UIView()
                stack.addArrangedSubview(containerView)
                containerView.backgroundColor = UIColor.clear
                containerView.layer.cornerRadius = 10
                containerView.leftAnchor.constraint(equalTo: stack.leftAnchor, constant: 0).isActive = true
                containerView.rightAnchor.constraint(equalTo: stack.rightAnchor, constant: 0).isActive = true
                containerView.isHidden = true
                containerView.translatesAutoresizingMaskIntoConstraints = false
                
                containerView.heightAnchor.constraint(equalToConstant: 60).isActive = true
                let historyView = AddDataToPatientView()
                containerView.addSubview(historyView)
                historyView.delegate = self.historyDelegate
                historyView.patient = self.patient
                historyView.translatesAutoresizingMaskIntoConstraints = false
                historyView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5).isActive = true
                historyView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 5).isActive = true
                historyView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
                historyView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
                historyView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 150).isActive = true
                historyView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -150).isActive = true
                historyView.layer.cornerRadius = 10
                historyView.translatesAutoresizingMaskIntoConstraints = false
                historyView.layer.borderWidth = 1
                historyView.layer.borderColor = UIColor.white.cgColor
            }
        }
    }
    
    func greenBorder(){
        //cellView.layer.cornerRadius = 15
        patientView.layer.borderWidth = 1
        patientView.layer.borderColor = UIColor.green.cgColor
    }
    
    func whiteBorder(){
        //cellView.layer.cornerRadius = 15
        patientView.layer.borderWidth = 1
        patientView.layer.borderColor = UIColor.white.cgColor
    }
    
    func setPatientData(){
        Institute.shared.observationHeight = height
        Institute.shared.observationWeight = weight
        Institute.shared.coverageObject = coverage
    }
    
    override func prepareForReuse() {
        bag = DisposeBag()
    }
    
}

extension UIStackView {
    func addBackground(color: UIColor) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        subView.layer.cornerRadius = 10
        insertSubview(subView, at: 0)
    }
}
