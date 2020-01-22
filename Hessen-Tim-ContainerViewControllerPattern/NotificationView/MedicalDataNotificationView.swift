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
        backgroundColor = UIColor(red: 33/255, green: 40/255, blue: 75/255, alpha: 1)
        
        
    }
    
    func addLabel(){
        var label: UILabel = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        label.textColor = UIColor.white
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 10
        label.layer.borderWidth = 0
        label.layer.borderColor = UIColor.blue.cgColor
        label.backgroundColor = UIColor(red: 75/255, green: 99/255, blue: 139/255, alpha: 1)
        label.textAlignment = NSTextAlignment.center
        label.text = "test label"
        self.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            //notificationView.widthAnchor.constraint(equalToConstant: 64),
            //notificationView.widthAnchor.constraint(equalTo: testView.heightAnchor),
            //label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 80),
            label.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -80),
            label.heightAnchor.constraint(equalToConstant: buttonHeight),
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: 50),
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
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
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        self.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: buttonWidth),
            button.heightAnchor.constraint(equalToConstant: buttonHeight),
            button.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -40),
            button.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -40),
        ])
        
    }
    
    func addTimelineInformation(){
        
        //Create container UIViews for the Information
        var containerView = UIView()
        var patientInformation = UIView()
        var timelineInformation = UIView()
        
        //Create labels and Icons for the information
        var patientName: UILabel = UILabel()
        var patientSex: UILabel = UILabel()
        var patientBirthday: UILabel = UILabel()
        var patientSize: UILabel = UILabel()
        var patientWeight: UILabel = UILabel()
        
        //Create labels and Icons for the information
        var iconTimeline = UIImageView()
        var iconStatus = UILabel()
        var date = UILabel()
        var mainTextInfo = UILabel()
        var sideTextInfo = UILabel()
        
        containerView.addSubview(patientInformation)
        containerView.addSubview(timelineInformation)
        
        //put the respective labels in their container views
        patientInformation.addSubview(patientName)
        patientInformation.addSubview(patientSex)
        patientInformation.addSubview(patientBirthday)
        patientInformation.addSubview(patientSize)
        patientInformation.addSubview(patientWeight)
        
        //put the respective labels in their container views
        timelineInformation.addSubview(iconTimeline)
        timelineInformation.addSubview(iconStatus)
        timelineInformation.addSubview(date)
        timelineInformation.addSubview(mainTextInfo)
        timelineInformation.addSubview(sideTextInfo)
        
        
        //Define the Layout constrains for the outer container view
        self.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 100),
            containerView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 40),
            containerView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -40),
            containerView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
        
        //Define the Layout constrains for the inner patientInformation container view
        containerView.addSubview(patientInformation)
        patientInformation.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            patientInformation.heightAnchor.constraint(equalToConstant: 50),
            patientInformation.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            patientInformation.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            patientInformation.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            patientInformation.topAnchor.constraint(equalTo: containerView.topAnchor),
        ])
        
        //Define the Layout constrains for the inner timelineInformation container view
        containerView.addSubview(timelineInformation)
        timelineInformation.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timelineInformation.heightAnchor.constraint(equalToConstant: 50),
            timelineInformation.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            timelineInformation.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            timelineInformation.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            timelineInformation.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
        
        patientInformation.backgroundColor = UIColor.red
        timelineInformation.backgroundColor = UIColor(red: 33/255, green: 40/255, blue: 75/255, alpha: 1)
        
        patientInformation.layer.cornerRadius = 10
        patientInformation.layer.borderWidth = 2
        patientInformation.layer.borderColor = UIColor.green.cgColor
        
        timelineInformation.layer.cornerRadius = 10
        timelineInformation.layer.borderWidth = 2
        timelineInformation.layer.borderColor = UIColor.gray.cgColor
        
        //this gets replaced by the function variables later
        patientName.text = "MaxMüller"
        patientSex.text = "M"
        patientBirthday.text = "25.03.1948 (70)"
        patientSize.text = "169cm"
        patientWeight.text = "71kg"
        
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
        
        
        iconTimeline.image = UIImage(named:"buttonSendInformation")
        iconTimeline.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconTimeline.topAnchor.constraint(equalTo: timelineInformation.topAnchor, constant: 5),
            iconTimeline.bottomAnchor.constraint(equalTo: timelineInformation.bottomAnchor, constant: -5),
            iconTimeline.leftAnchor.constraint(equalTo: timelineInformation.leftAnchor, constant: 30),
            iconTimeline.centerYAnchor.constraint(equalTo: timelineInformation.centerYAnchor),
        ])
        
    }

    @objc func buttonAction(sender: UIButton!) {
      print("Button tapped")
    }
    
}
