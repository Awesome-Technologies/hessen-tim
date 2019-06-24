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
        
        collapseMaster = UIBarButtonItem(title: "Information", style: .done, target: self, action: #selector(collapse))
        self.navigationItem.rightBarButtonItem = collapseMaster
      
    }
    
    
    var galleryVC:GalleryViewController?
    var cameraVC:CameraPictureViewController?
    var collapseMaster:UIBarButtonItem!
    
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
