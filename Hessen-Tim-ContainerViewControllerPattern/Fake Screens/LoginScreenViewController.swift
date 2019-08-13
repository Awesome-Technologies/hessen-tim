//
//  LoginScreenViewController.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 01.07.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import UIKit

class LoginScreenViewController: UIViewController {

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

    @IBOutlet weak var loginButton: UIButton!
    
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
    
    @IBAction func loginAction(_ sender: Any) {
        performSegue(withIdentifier: "mainView", sender: self)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
