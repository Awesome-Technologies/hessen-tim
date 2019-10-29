//
//  ViewController.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 13.03.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import UIKit

/*
 Helping Tutorials:
 
 https://naveenr.net/beginning-container-views-in-ios/
 
 */

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        collapseMaster = UIBarButtonItem(title: "Information >", style: .done, target: self, action: #selector(collapse))
        self.navigationItem.rightBarButtonItem = collapseMaster
        
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(toPrevScreen))
      
    }
    
    
    var galleryVC:GalleryViewController?
    var cameraVC:CameraPictureViewController?
    var collapseMaster:UIBarButtonItem!
    var commentWindowOpen = false
    var textView = UITextView()

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        view.backgroundColor = UIColor.init(red: 38/255, green: 47/255, blue: 83/255, alpha: 1)
        
        if let vc = segue.destination as? GalleryViewController {
            galleryVC = vc
            galleryVC?.delegate = cameraVC
            
        }
        
        if let vc = segue.destination as? CameraPictureViewController {
            cameraVC = vc
            cameraVC?.delegate = self
        }
    }
    
    
    //Action
    @IBAction func takePicture(_ sender: Any) {
        cameraVC?.makePhoto()
    }
    
    @IBAction func toPrevScreen(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showComments(_ sender: Any) {
        
        if(commentWindowOpen == false) {
            textView = UITextView(frame: CGRect(x: 0, y: 0, width: 1330, height: 500))
            
            textView.center = self.view.center
            textView.textAlignment = NSTextAlignment.justified
            
            // Use RGB colour
            textView.backgroundColor = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 0.7)
            
            // Update UITextView font size and colour
            textView.font = UIFont.systemFont(ofSize: 20)
            textView.textColor = UIColor.black
            
            textView.font = UIFont.boldSystemFont(ofSize: 20)
            textView.font = UIFont(name: "Verdana", size: 25)
            
            // Capitalize all characters user types
            textView.autocapitalizationType = UITextAutocapitalizationType.allCharacters
            
            // Make UITextView web links clickable
            textView.isSelectable = true
            textView.isEditable = false
            textView.dataDetectorTypes = UIDataDetectorTypes.link
            
            // Make UITextView corners rounded
            textView.layer.cornerRadius = 5
            
            // Enable auto-correction and Spellcheck
            textView.autocorrectionType = UITextAutocorrectionType.yes
            textView.spellCheckingType = UITextSpellCheckingType.yes
            
            // Make UITextView Editable
            textView.isEditable = true
            
            self.view.addSubview(textView)
            
            commentWindowOpen = true
            
        } else {
            textView.removeFromSuperview()
            commentWindowOpen = false
        }
        
        
        
    }
    @objc func collapse(){
        //https://stackoverflow.com/questions/35005887/trouble-using-a-custom-image-for-splitviewcontroller-displaymodebuttonitem-uiba
        UIApplication.shared.sendAction(splitViewController!.displayModeButtonItem.action!, to: splitViewController!.displayModeButtonItem.target, from: nil, for: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
    }
}



extension BaseViewController: GalleryDelegate {
    func addGalleryImage(imageName: String) {
        //print("added an Image")
        galleryVC?.insertItemTest(imageName: imageName)
    }
}


extension BaseViewController {
    func toggleMasterView() {
        let barButtonItem = self.collapseMaster
        UIApplication.shared.sendAction(barButtonItem!.action!, to: barButtonItem!.target, from: nil, for: nil)
    }
}
