//
//  LoadingView.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 02.06.20.
//  Copyright © 2020 Michael Rojkov. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    
    var loadingtext: UITextField!
    var grayPanel: UIView!
    var width: Int = 500
    
    
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
        self.layer.cornerRadius = 50
    }
    
    //func setWidth()
    
    func addLayoutConstraints(){
        backgroundColor = UIColor.white
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: self.superview!.centerXAnchor),
            self.centerYAnchor.constraint(equalTo: self.superview!.centerYAnchor),
        ])
    }
    
    
    func addGrayBackPanel(){
        grayPanel = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        //grayPanel.backgroundColor = UIColor.darkGray
        grayPanel.backgroundColor = UIColor.init(red: 49.0/255.0, green: 49.0/255.0, blue: 49.0/255.0, alpha: 0.3)
                
        self.superview?.addSubview(grayPanel)
        
        grayPanel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            grayPanel.rightAnchor.constraint(equalTo: self.superview!.rightAnchor, constant: 0),
            grayPanel.bottomAnchor.constraint(equalTo: self.superview!.bottomAnchor, constant: 0),
            grayPanel.topAnchor.constraint(equalTo: self.superview!.topAnchor, constant: 0),
            grayPanel.leftAnchor.constraint(equalTo: self.superview!.leftAnchor, constant: 0),
        ])
    }
    
    func addLoadingText(text: String){
        
        let image = UIImage()
        let imageView = UIImageView(image: image)
        imageView.loadGif(asset: "loading")
        imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        self.addSubview(imageView)
               
        imageView.translatesAutoresizingMaskIntoConstraints = false
               
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: self.heightAnchor, constant: -40),
            imageView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -40),
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
            imageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20),
            
        ])
        
        
        loadingtext = UITextField()
        loadingtext.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        loadingtext.textColor = UIColor.black
        loadingtext.font = .systemFont(ofSize: 60)
        loadingtext.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0)
        loadingtext.textAlignment = NSTextAlignment.left
        loadingtext.text = text
        //consilReportTextView.placeholder = "Klicken Sie hier um Text für den Konsilbericht einzutippen"
        loadingtext.isEnabled = false
        self.addSubview(loadingtext)
        
        //loadingtext.layer.cornerRadius = 10
        //loadingtext.layer.borderWidth = 1
        loadingtext.layer.borderColor = UIColor(red: 0/255, green: 96/255, blue: 167/255, alpha: 1).cgColor
        
        loadingtext.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            //notificationView.widthAnchor.constraint(equalToConstant: 64),
            //notificationView.widthAnchor.constraint(equalTo: testView.heightAnchor),
            //label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            //loadingtext.heightAnchor.constraint(equalToConstant: 200),
            //label.widthAnchor.constraint(equalToConstant: 250),
            loadingtext.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            loadingtext.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
            loadingtext.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20),
            loadingtext.rightAnchor.constraint(equalTo: imageView.leftAnchor, constant: -20),
            
        ])
        
    }
    
    func removeGrayView(){
        grayPanel.removeFromSuperview()
    }

}
