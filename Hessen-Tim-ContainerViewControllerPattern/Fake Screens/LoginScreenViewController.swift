//
//  LoginScreenViewController.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 01.07.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import UIKit
import SwiftGifOrigin
import SMART
import RxSwift
import RxRelay

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
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserLoginCredentials.shared.delegate = self
        
        // Enable login button only when the device is connected to the server
        Repository.instance.connectionStatus
            .map({ $0 == .connected })
            .bind(to: loginButton.rx.isEnabled)
            .disposed(by: bag)
    }
    
    func checkForAutologin() {
        self.addLoadingView()
        Repository.instance.getAllResources(ofType: Endpoint.self, true) { result in
            switch result {
            case .success(let requestResult):
                let deviceId = UserLoginCredentials.shared.deviceId
                requestResult.resultValue.forEach { endpoint in
                    guard let contacts = endpoint.contact else { return }
                    let containsDeviceId = contacts.contains(where: { contactPoint -> Bool in
                        guard let json = contactPoint.value?.string, let jsonData = json.data(using: .utf8), let epData = EndpointData.from(json: jsonData) else { return false }
                        return epData.deviceId == deviceId
                    })
                    if containsDeviceId {
                        let ids = UserLoginCredentials.shared.cachedOrganizationIds
                        ids.forEach { (key: ProfileType, value: (organizationId: String, endpointId: String)) in
                            if endpoint.id?.string == value.endpointId {
                                self.selectedProfile = key
                            }
                        }
                        if self.selectedProfile != .NONE {
                            self.removeLoadingView()
                            self.performLogin()
                            return
                        }
                    }
                }
            case .failure(let error):
                print("Error fetching Endpoints from the server: \(error.localizedDescription)")
            }
            self.removeLoadingView()
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
        if (selectedProfile == .NONE) {
            highlightAllMissingElements()
        } else {
            performLogin()
        }
    }
    
    func performLogin() {
        Repository.instance.setup {
            callOnMainThread {
                self.removeLoadingView()
                UserLoginCredentials.shared.delegate = nil
                UserLoginCredentials.shared.selectedProfile = self.selectedProfile
                self.performSegue(withIdentifier: "mainView", sender: self)
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
    
    func removeLoadingView() {
        callOnMainThread {
            self.loadingView.removeGrayView()
            self.loadingView.removeFromSuperview()
        }
    }

}

extension LoginScreenViewController: UserLoginCredentialsDelegate {
    func didUpdateCachedOrganizationIds(newIds: [ProfileType : (organization: String, endpoint: String)]) {
        if newIds.count > 0 {
            checkForAutologin()
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
