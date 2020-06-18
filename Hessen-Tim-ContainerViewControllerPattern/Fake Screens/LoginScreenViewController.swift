//
//  LoginScreenViewController.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 01.07.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import UIKit
import SwiftGifOrigin

class LoginScreenViewController: UIViewController {
    
    var selectedProfile:ProfileType = .NONE
    var loadingView = LoadingView(frame: CGRect(x: 0, y: 0, width: 500, height: 200))

    @IBOutlet weak var screen2ImageView: UIImageView!
    @IBOutlet weak var loginName: UITextField! {
        didSet {
            loginName.tintColor = UIColor.lightGray
            loginName.setIcon(UIImage(named: "login-name")!)
        }
    }
    
    @IBOutlet weak var loginPw: UITextField! {
        didSet {
            loginPw.tintColor = UIColor.lightGray
            loginPw.setIcon(UIImage(named: "login-pw")!)
        }
    }
    @IBOutlet weak var peripheralClinic: UIButton!
    @IBOutlet weak var consultationClinic: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
    super.viewDidLoad()
        
        /**
         Check if a token is present. If at this point, a token is not present in the user defaults, it means that the user as logged out
         and wants to logg in once aggain
         */
        if let oldPushDeviceToken = UserDefaults.standard.string(forKey: "current_device_token"){
            
            addLoadingView()
            
            Institute.shared.connect { error in
                if error == nil {
                    //get my Organization Profile
                    Institute.shared.checkOrganizationsForLogin(completion: { login in
                        if(login != .NONE){
                            UserLoginCredentials.shared.selectedProfile = login
                            print("Login data complete")
                            //get me to the next screen
                            DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "mainView", sender: self)
                            }
                        }else{
                            print("We are not registered and should log in")
                            DispatchQueue.main.async {
                                self.loadingView.removeGrayView()
                                self.loadingView.removeFromSuperview()
                            }
                        }
                    })
                    
                }
            }
            
        }else{
            print("We are not registered and should log in")
        }
    
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Do any additional setup after loading the view
        loginName.borderStyle = UITextField.BorderStyle.none
        
        //loginName.backgroundColor = .clear
        loginName.layer.cornerRadius = 15
        loginName.layer.borderWidth = 0
        loginName.layer.borderColor = UIColor.blue.cgColor
        
        loginPw.borderStyle = UITextField.BorderStyle.none
        loginPw.layer.cornerRadius = 15
        loginPw.layer.borderWidth = 0
        loginPw.layer.borderColor = UIColor.blue.cgColor
        loginPw.isSecureTextEntry = true
        
        
        loginButton.clipsToBounds = true;
        loginButton.layer.cornerRadius = 15
        
        
    }
    @IBAction func selectPeripheralClinic(_ sender: Any) {
        peripheralClinic.layer.cornerRadius = 35
        peripheralClinic.layer.borderWidth = 4
        peripheralClinic.layer.borderColor = UIColor.green.cgColor
        consultationClinic.layer.borderWidth = 0
        
        selectedProfile = .PeripheralClinic
        
    }
    
    @IBAction func selectConsultationClinic(_ sender: Any) {
        consultationClinic.layer.cornerRadius = 35
        consultationClinic.layer.borderWidth = 4
        consultationClinic.layer.borderColor = UIColor.green.cgColor
        peripheralClinic.layer.borderWidth = 0
        
        selectedProfile = .ConsultationClinic
    }
    
    
    @IBAction func loginAction(_ sender: Any) {
        if(selectedProfile == .NONE){
            highlightAllMissingElements()
        }else{
            Institute.shared.connect { error in
                if error == nil {
                    self.addLoadingView()
                    /**
                     Check if a token is present. If at this point, a token is not present in the user defaults, it means that the user as logged out
                     and wants to logg in once aggain
                     */
                    if let oldPushDeviceToken = UserDefaults.standard.string(forKey: "current_device_token"){
                        print("We have a token already")
                    }else{
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                            print("New default Token: \(UserDefaults.standard.string(forKey: "current_device_token"))")
                        }
                    }
                    
                    UserLoginCredentials.shared.selectedProfile = self.selectedProfile
                    Institute.shared.registerProfile(profileType: self.selectedProfile, completion: {
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "mainView", sender: self)
                        }
                    })
                } else {
                    print("We have a connection error")
                }
            }
            
            
        }
    }
    
    /**
     highlight all testfields with missing input with a shake animation and a red border
     */
    func highlightAllMissingElements(){
        
        for view in self.view.subviews {
            if (view is UIButton) {
                var button = view as! UIButton
                if (button == peripheralClinic || button == consultationClinic){
                    button.layer.cornerRadius = 35
                    button.layer.borderWidth = 4
                    button.layer.borderColor = UIColor.red.cgColor
                    button.shake()
                }
            }
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
    
    func addLoadingView(){
        DispatchQueue.main.async {
            //var loadingView = LoadingView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            self.view.addSubview(self.loadingView)
            self.loadingView.addGrayBackPanel()
            self.loadingView.addLayoutConstraints()
            self.loadingView.addLoadingText(text: "Lade Profil")
            self.view.bringSubviewToFront(self.loadingView)
        }
    }

}

// https://medium.com/nyc-design/swift-4-add-icon-to-uitextfield-48f5ebf60aa1
extension UITextField {
    func setIcon(_ image: UIImage) {
        let iconView = UIImageView(frame:
            CGRect(x: 10, y: 8, width: 45, height: 45))
        iconView.image = image
        let iconContainerView: UIView = UIView(frame:
            CGRect(x: 20, y: 0, width: 60, height: 60))
        iconContainerView.addSubview(iconView)
        leftView = iconContainerView
        leftViewMode = .always
    }
}

// https://www.ios-blog.com/tutorials/swift/how-to-change-the-placeholder-color-using-swift-extensions-or-user-defined-runtime-attributes/
extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}
