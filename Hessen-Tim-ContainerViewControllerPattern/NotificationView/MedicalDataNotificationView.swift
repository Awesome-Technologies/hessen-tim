//
//  MedicalDataNotificationView.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 22.01.20.
//  Copyright © 2020 Michael Rojkov. All rights reserved.
//

import UIKit

class MedicalDataNotificationView: UIView {
    
    var buttonWidth:CGFloat = 200.0
    var buttonHeight:CGFloat = 60.0
    var consilReportTextView: UITextView!
    var grayPanel: UIView!
    
    
    //initWithFrame to init view from code
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    //initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    //common func to init our view
    private func setupView() {
        //backgroundColor = UIColor(red: 33/255, green: 40/255, blue: 75/255, alpha: 1)
        self.layer.cornerRadius = 10
    }
    
    func addLayoutConstraints(){
        backgroundColor = UIColor.white
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            //notificationView.widthAnchor.constraint(equalToConstant: 64),
            //notificationView.widthAnchor.constraint(equalTo: testView.heightAnchor),
            self.heightAnchor.constraint(equalToConstant: 500),
            self.widthAnchor.constraint(equalToConstant: 700),
            self.centerXAnchor.constraint(equalTo: self.superview!.centerXAnchor),
            self.centerYAnchor.constraint(equalTo: self.superview!.centerYAnchor),
        ])
    }
    
    
    func addSendViewLayoutConstraints(){
        backgroundColor = UIColor(red: 41/255, green: 45/255, blue: 86/255, alpha: 1)
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            //notificationView.widthAnchor.constraint(equalToConstant: 64),
            //notificationView.widthAnchor.constraint(equalTo: testView.heightAnchor),
            self.heightAnchor.constraint(equalToConstant: 350),
            self.widthAnchor.constraint(equalToConstant: 600),
            self.centerXAnchor.constraint(equalTo: self.superview!.centerXAnchor),
            self.centerYAnchor.constraint(equalTo: self.superview!.centerYAnchor),
        ])
    }
    
    func addNotificationLabel(text: String){
        var label: UILabel = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        label.font = label.font.withSize(22)
        label.textColor = UIColor.white
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 10
        label.layer.borderWidth = 0
        label.layer.borderColor = UIColor.blue.cgColor
        label.backgroundColor = UIColor(red: 75/255, green: 99/255, blue: 139/255, alpha: 1)
        label.textAlignment = NSTextAlignment.center
        label.text = text
        self.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            //notificationView.widthAnchor.constraint(equalToConstant: 64),
            //notificationView.widthAnchor.constraint(equalTo: testView.heightAnchor),
            //label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 140),
            label.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20),
            label.heightAnchor.constraint(equalToConstant: buttonHeight),
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: 30),
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
        ])
        
    }
    
    func addConsilLabel(text: String){
        var label: UILabel = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        label.textColor = UIColor.black
        label.font = label.font.withSize(25)
        label.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0)
        label.textAlignment = NSTextAlignment.left
        label.text = text
        self.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            //notificationView.widthAnchor.constraint(equalToConstant: 64),
            //notificationView.widthAnchor.constraint(equalTo: testView.heightAnchor),
            //label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            label.heightAnchor.constraint(equalToConstant: 40),
            label.widthAnchor.constraint(equalToConstant: 250),
            label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20),
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
        ])
    }
    
    func addConsilDateLabel(text: String){
        var label: UILabel = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        label.textColor = UIColor.black
        label.font = label.font.withSize(25)
        label.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0)
        label.textAlignment = NSTextAlignment.right
        label.text = text
        self.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            //notificationView.widthAnchor.constraint(equalToConstant: 64),
            //notificationView.widthAnchor.constraint(equalTo: testView.heightAnchor),
            //label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            label.heightAnchor.constraint(equalToConstant: 40),
            label.widthAnchor.constraint(equalToConstant: 250),
            label.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20),
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
        ])
    }
    
    func addConsilReportTextView(editable: Bool, consilText: String){
        consilReportTextView = UITextView()
        consilReportTextView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        consilReportTextView.textColor = UIColor.black
        consilReportTextView.font = .systemFont(ofSize: 23)
        consilReportTextView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0)
        consilReportTextView.textAlignment = NSTextAlignment.left
        consilReportTextView.text = consilText
        consilReportTextView.placeholder = "Klicken Sie hier um Text für den Konsilbericht einzutippen"
        consilReportTextView.isEditable = editable
        self.addSubview(consilReportTextView)
        
        consilReportTextView.layer.cornerRadius = 10
        consilReportTextView.layer.borderWidth = 1
        consilReportTextView.layer.borderColor = UIColor(red: 0/255, green: 96/255, blue: 167/255, alpha: 1).cgColor
        
        consilReportTextView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            //notificationView.widthAnchor.constraint(equalToConstant: 64),
            //notificationView.widthAnchor.constraint(equalTo: testView.heightAnchor),
            //label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            consilReportTextView.heightAnchor.constraint(equalToConstant: 300),
            //label.widthAnchor.constraint(equalToConstant: 250),
            consilReportTextView.topAnchor.constraint(equalTo: self.topAnchor, constant: 80),
            consilReportTextView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20),
            consilReportTextView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20),
            
        ])
    }
    
    func addSendConsilReportButton(){
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        button.setTitle("Bericht absenden ", for: .normal)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 0
        button.layer.borderColor = UIColor.blue.cgColor
        button.backgroundColor = UIColor(red: 0/255, green: 96/255, blue: 167/255, alpha: 1)
        button.addTarget(self, action: #selector(saveDiagnosticReport), for: .touchUpInside)
        
        self.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: buttonWidth),
            button.heightAnchor.constraint(equalToConstant: buttonHeight),
            button.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
        ])
        
    }
    
    func addCancelbutton(){
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        button.setTitle("Abbrechen", for: .normal)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 0
        button.layer.borderColor = UIColor.blue.cgColor
        button.backgroundColor = UIColor(red: 0/255, green: 96/255, blue: 167/255, alpha: 1)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        self.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: buttonWidth),
            button.heightAnchor.constraint(equalToConstant: buttonHeight),
            button.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20),
            button.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
        ])
        
    }
    
    func addButtonToPatientenListe(){
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        button.setTitle("Patientenliste", for: .normal)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 0
        button.layer.borderColor = UIColor.blue.cgColor
        button.backgroundColor = UIColor(red: 0/255, green: 96/255, blue: 167/255, alpha: 1)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        self.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: buttonWidth),
            button.heightAnchor.constraint(equalToConstant: buttonHeight),
            button.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 40),
            button.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -40),
        ])
        
    }
    
    
    func addOKbutton(){
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        button.setTitle("Ok", for: .normal)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 0
        button.layer.borderColor = UIColor.blue.cgColor
        button.backgroundColor = UIColor(red: 0/255, green: 96/255, blue: 167/255, alpha: 1)
        button.addTarget(self, action: #selector(confirmSendServiceRequesrt), for: .touchUpInside)
        
        self.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            //button.widthAnchor.constraint(equalToConstant: buttonWidth),
            button.heightAnchor.constraint(equalToConstant: buttonHeight),
            button.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20),
            button.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20),
            button.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
        ])
        
    }
    
    func addGrayBackPanel(){
        grayPanel = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        //grayPanel.backgroundColor = UIColor.darkGray
        grayPanel.backgroundColor = UIColor.init(red: 49.0/255.0, green: 49.0/255.0, blue: 49.0/255.0, alpha: 0.5)
                
        self.superview?.addSubview(grayPanel)
        
        grayPanel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            grayPanel.rightAnchor.constraint(equalTo: self.superview!.rightAnchor, constant: 0),
            grayPanel.bottomAnchor.constraint(equalTo: self.superview!.bottomAnchor, constant: 0),
            grayPanel.topAnchor.constraint(equalTo: self.superview!.topAnchor, constant: 0),
            grayPanel.leftAnchor.constraint(equalTo: self.superview!.leftAnchor, constant: 0),
        ])
    }
    
    
    func addPatientInforamtion(){
        var patientInformation = UIView()
        
        //Create labels and Icons for the information
        var patientName: UILabel = UILabel()
        var patientSex: UILabel = UILabel()
        var patientBirthday: UILabel = UILabel()
        var patientSize: UILabel = UILabel()
        var patientWeight: UILabel = UILabel()
        
        //put the respective labels in their container views
        patientInformation.addSubview(patientName)
        patientInformation.addSubview(patientSex)
        patientInformation.addSubview(patientBirthday)
        patientInformation.addSubview(patientSize)
        patientInformation.addSubview(patientWeight)
        
        self.addSubview(patientInformation)
        
        patientInformation.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            patientInformation.heightAnchor.constraint(equalToConstant: 60),
            //patientInformation.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            patientInformation.topAnchor.constraint(equalTo: self.topAnchor, constant: 110),
            patientInformation.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20),
            patientInformation.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20),
        ])
        
        patientInformation.backgroundColor = UIColor(red: 38/255, green: 46/255, blue: 84/255, alpha: 1)
        patientInformation.layer.cornerRadius = 10
        patientInformation.layer.borderWidth = 2
        patientInformation.layer.borderColor = UIColor.green.cgColor
        
        if(Institute.shared.patientObject != nil){
            patientName.text = (Institute.shared.patientObject!.name?[0].given?[0].string)! + " " + (Institute.shared.patientObject!.name?[0].family?.string)!
            patientSex.text = Institute.shared.patientObject?.gender?.rawValue
            patientBirthday.text = Institute.shared.patientObject?.birthDate?.description
            patientSize.text = Institute.shared.observationHeight?.valueQuantity?.value?.description
            patientWeight.text = Institute.shared.observationWeight?.valueQuantity?.value?.description
        }else{
            patientName.text = "MaxMüller"
            patientSex.text = "M"
            patientBirthday.text = "25.03.1948 (70)"
            patientSize.text = "169cm"
            patientWeight.text = "71kg"
        }
        
        patientName.textColor = UIColor.white
        patientName.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            patientName.leftAnchor.constraint(equalTo: patientInformation.leftAnchor, constant: 30),
            patientName.centerYAnchor.constraint(equalTo: patientInformation.centerYAnchor),
        ])
        
        patientSex.textColor = UIColor.white
        patientSex.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            patientSex.leftAnchor.constraint(equalTo: patientName.rightAnchor, constant: 30),
            patientSex.centerYAnchor.constraint(equalTo: patientInformation.centerYAnchor),
        ])
        
        patientBirthday.textColor = UIColor.white
        patientBirthday.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            patientBirthday.leftAnchor.constraint(equalTo: patientSex.rightAnchor, constant: 30),
            patientBirthday.centerYAnchor.constraint(equalTo: patientInformation.centerYAnchor),
        ])
        
        patientSize.textColor = UIColor.white
        patientSize.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            patientSize.rightAnchor.constraint(equalTo: patientWeight.leftAnchor, constant: -30),
            patientSize.centerYAnchor.constraint(equalTo: patientInformation.centerYAnchor),
        ])
        
        patientWeight.textColor = UIColor.white
        patientWeight.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            patientWeight.rightAnchor.constraint(equalTo: patientInformation.rightAnchor, constant: -30),
            patientWeight.centerYAnchor.constraint(equalTo: patientInformation.centerYAnchor),
        ])
        
        
    }
    
    func addRequestSendInformation(){
        
        //Create container UIViews for the Information
        var timelineInformation = UIView()
        
        //Create labels and Icons for the information
        var iconTimeline = UIImageView()
        var dateText = UILabel()
        var mainTextInfo = UILabel()
        var sideTextInfo = UILabel()
        
        //put the respective labels in their container views
        timelineInformation.addSubview(iconTimeline)
        timelineInformation.addSubview(dateText)
        timelineInformation.addSubview(mainTextInfo)
        timelineInformation.addSubview(sideTextInfo)
        
        //Define the Layout constrains for the inner timelineInformation container view
        self.addSubview(timelineInformation)
        timelineInformation.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timelineInformation.heightAnchor.constraint(equalToConstant: 60),
            //patientInformation.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            timelineInformation.topAnchor.constraint(equalTo: self.topAnchor, constant: 170),
            timelineInformation.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20),
            timelineInformation.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20),
        ])
        
        timelineInformation.backgroundColor = UIColor(red: 41/255, green: 45/255, blue: 86/255, alpha: 1)
        
        timelineInformation.layer.cornerRadius = 10
        timelineInformation.layer.borderWidth = 2
        timelineInformation.layer.borderColor = UIColor.darkGray.cgColor
        
        // get the current date and time
        let currentDateTime = Date()

        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .long

        // get the date time String from the date object
        dateText.text = formatter.string(from: currentDateTime) // October 8, 2016 at 10:48:53 PM
        
        iconTimeline.image = UIImage(named:"sendButton")
        iconTimeline.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconTimeline.widthAnchor.constraint(equalToConstant: 60),
            iconTimeline.topAnchor.constraint(equalTo: timelineInformation.topAnchor, constant: 5),
            iconTimeline.bottomAnchor.constraint(equalTo: timelineInformation.bottomAnchor, constant: -5),
            iconTimeline.leftAnchor.constraint(equalTo: timelineInformation.leftAnchor, constant: 30),
            iconTimeline.centerYAnchor.constraint(equalTo: timelineInformation.centerYAnchor),
        ])
        
        dateText.textColor = UIColor.white
        dateText.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateText.leftAnchor.constraint(equalTo: iconTimeline.rightAnchor, constant: 30),
            dateText.centerYAnchor.constraint(equalTo: timelineInformation.centerYAnchor),
        ])
        
    }
    
    
    func addHomeIcon(){
        var homeButton = UIImageView()
        self.addSubview(homeButton)
        homeButton.image = UIImage(named:"homeButton")
        homeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            homeButton.widthAnchor.constraint(equalToConstant: 61),
            homeButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            homeButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 30),
            homeButton.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 30),
        ])
    }
    
    func addCloseNotification(){
        consilReportTextView = UITextView()
        consilReportTextView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        consilReportTextView.textColor = UIColor.white
        consilReportTextView.font = .systemFont(ofSize: 23)
        consilReportTextView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0)
        consilReportTextView.textAlignment = NSTextAlignment.left
        consilReportTextView.text = "Wenn Sie die Eingabe beenden, werden alle bisher eingegebenen Daten gelöscht werden"
        consilReportTextView.isEditable = false
        self.addSubview(consilReportTextView)
        
        consilReportTextView.layer.cornerRadius = 10
        consilReportTextView.layer.borderWidth = 1
        consilReportTextView.layer.borderColor = UIColor.darkGray.cgColor
        
        consilReportTextView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            //notificationView.widthAnchor.constraint(equalToConstant: 64),
            //notificationView.widthAnchor.constraint(equalTo: testView.heightAnchor),
            consilReportTextView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            consilReportTextView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            consilReportTextView.topAnchor.constraint(equalTo: self.topAnchor, constant: 120),
            consilReportTextView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -100),
            consilReportTextView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20),
            consilReportTextView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20),
            
        ])
    }
    
    func addDeletebutton(){
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        button.setTitle("Löschen", for: .normal)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 0
        button.layer.borderColor = UIColor.blue.cgColor
        button.backgroundColor = UIColor(red: 0/255, green: 96/255, blue: 167/255, alpha: 1)
        button.addTarget(self, action: #selector(cancelRequestCreation), for: .touchUpInside)
        
        self.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: buttonWidth),
            button.heightAnchor.constraint(equalToConstant: buttonHeight),
            button.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
        ])
        
    }
    

    @objc func buttonAction(sender: UIButton!) {
      print("Button tapped")
        grayPanel.removeFromSuperview()
        self.removeFromSuperview()
        
    }
    @objc func confirmSendServiceRequesrt(sender: UIButton!) {
        print(confirmSendServiceRequesrt)
        grayPanel.removeFromSuperview()
        self.removeFromSuperview()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "toHomeScreen"), object: nil)
        
    }
    
    @objc func saveDiagnosticReport(sender: UIButton!) {
      print("Button tapped")
        Institute.shared.saveDiagnosticReport(text: consilReportTextView.text)
        grayPanel.removeFromSuperview()
        self.removeFromSuperview()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "toHomeScreen"), object: nil)
    }
    
    @objc func cancelRequestCreation(sender: UIButton!) {
      print("Button tapped")
        Institute.shared.deleteAllDataForServiceRequest()
        grayPanel.removeFromSuperview()
        self.removeFromSuperview()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "toHomeScreen"), object: nil)
    }
    
}
