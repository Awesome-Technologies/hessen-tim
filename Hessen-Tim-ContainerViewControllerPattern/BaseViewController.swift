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
    }
    
    var galleryVC:GalleryViewController?
    var cameraVC:CameraPictureViewController?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        view.backgroundColor = UIColor.init(red: 38/255, green: 47/255, blue: 83/255, alpha: 1)
        
        if let vc = segue.destination as? GalleryViewController {
            galleryVC = vc
            
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
    
}





extension BaseViewController: GalleryDelegate {
    func addGalleryImage(imageName: String) {
        //print("added an Image")
        galleryVC?.insertItemTest(imageName: imageName)
    }
}
