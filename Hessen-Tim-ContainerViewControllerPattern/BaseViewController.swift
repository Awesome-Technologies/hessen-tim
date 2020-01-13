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
    
    //UIView that overlays the BaseView in a light gray, when splitView bar is visible
    var customView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    let window = UIApplication.shared.keyWindow!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        collapseMaster = UIBarButtonItem(title: "Information >", style: .done, target: self, action: #selector(collapse))
        self.navigationItem.rightBarButtonItem = collapseMaster
        
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(toPrevScreen))
        
        //initialization information for the gray sidebar
        customView = UIView(frame: window.bounds)
        self.customView.backgroundColor = UIColor.gray.withAlphaComponent(0.0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(drawButtonFunction(_:)), name: Notification.Name(rawValue: "drawButtonFunction"), object: nil)
        
        //Notifications to get information from the sidebar, when the gray overlay has to be turned on or off
        NotificationCenter.default.addObserver(self, selector: #selector(addGraySubview(_:)), name: Notification.Name(rawValue: "addGraySubview"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeGraySubview(_:)), name: Notification.Name(rawValue: "removeGraySubview"), object: nil)
      
    }
    
    
    var galleryVC:GalleryViewController?
    var cameraVC:CameraPictureViewController?
    var collapseMaster:UIBarButtonItem!
    var commentWindowOpen = false
    var textView = UITextView()

    @IBOutlet weak var takePictureButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    
    //Outlet of buttons for the painting
    @IBOutlet weak var paintButton: UIButton!
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    @IBOutlet weak var blackButton: UIButton!
    @IBOutlet weak var whiteButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    
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
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.splitView = false
        delegate.setupRootViewController(animated: true)
        
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
    
    /**
     Gets triggered, when paint button is touched
     Activates/deactivates the drawing functions in the cameraPictureView Controller
     Shows/hides the buttons for the drawing functionality
     
    */
    @IBAction func activateDrawing(_ sender: Any?) {
        print("Drawing function")
        cameraVC?.activateDrawigFunctions()
        if(paintButton.currentImage == UIImage(named: "malen-button")) {
            paintButton.setImage(UIImage(named: "malen-button-green"), for: .normal)
            
            //Shows the paint function buttons
            redButton.isHidden = false
            greenButton.isHidden = false
            blueButton.isHidden = false
            blackButton.isHidden = false
            whiteButton.isHidden = false
            clearButton.isHidden = false
            saveButton.isHidden = false
        } else {
            paintButton.setImage(UIImage(named: "malen-button"), for: .normal)
            
            //hides the paint function buttons
            redButton.isHidden = true
            greenButton.isHidden = true
            blueButton.isHidden = true
            blackButton.isHidden = true
            whiteButton.isHidden = true
            clearButton.isHidden = true
            saveButton.isHidden = true
            
        }
    }
    
    @objc func collapse(){
        //https://stackoverflow.com/questions/35005887/trouble-using-a-custom-image-for-splitviewcontroller-displaymodebuttonitem-uiba
        UIApplication.shared.sendAction(splitViewController!.displayModeButtonItem.action!, to: splitViewController!.displayModeButtonItem.target, from: nil, for: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
    }
    
    @objc func drawButtonFunction(_ notification: Notification) {
        if(paintButton.isHidden == false) {
            //Hide pait Buttons
            paintButton.isHidden = true
            commentButton.isHidden = true
            paintButton.isHidden = true
            commentButton.isHidden = true
            redButton.isHidden = true
            greenButton.isHidden = true
            blueButton.isHidden = true
            blackButton.isHidden = true
            whiteButton.isHidden = true
            clearButton.isHidden = true
            saveButton.isHidden = true
            closeButton.isHidden = true
            
            //Show photo button
            takePictureButton.isHidden = false
            
        } else {
            //Show the paint buttons
            paintButton.isHidden = false
            commentButton.isHidden = false
            closeButton.isHidden = false
            
            //Hide the photo button
            takePictureButton.isHidden = true
            
        }
    }
    
    /**
     Function gets trigegred by actions in sidebar, to display gray overlay
     */
    @objc func addGraySubview(_ notification: Notification) {
        print("We insert gray subview")
        self.customView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        self.view.addSubview(customView)
    }
    
    /**
    Function gets trigegred by actions in sidebar, to remove gray overlay
    */
    @objc func removeGraySubview(_ notification: Notification) {
        self.customView.removeFromSuperview()
    }
    
    
    // Function call when the close Button is pressed
    @IBAction func closeImagePreview(_ sender: Any) {
        print("I close the PreviewImageView")
        
        // Hide the Paint functions and change Button logo if necesr
        if(cameraVC!.drawingActive) {
            self.activateDrawing(nil)
        }
        
        //close the previewImage View
        cameraVC?.closeImagePreview()
        
        // Make the paint buttons invisible and show the take picture button
        NotificationCenter.default.post(name: Notification.Name(rawValue: "drawButtonFunction"), object: nil)
    }
    
    // Pic red color for drawing
    @IBAction func picRedColor(_ sender: Any) {
        cameraVC?.color = UIColor(red: 1, green: 0, blue: 0, alpha: 1.0)
    }
    
    // Pic red green for drawing
    @IBAction func picGreenColor(_ sender: Any) {
        cameraVC?.color = UIColor(red: 0, green: 1, blue: 0, alpha: 1.0)
    }
    
    // Pic red blue for drawing
    @IBAction func picBlueColor(_ sender: Any) {
        cameraVC?.color = UIColor(red: 0, green: 0, blue: 1, alpha: 1.0)
    }
    
    // Pic black color for drawing
    @IBAction func picBlackColor(_ sender: Any) {
        cameraVC?.color = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
    }
    
    //Pic white color
    @IBAction func picWhiteColor(_ sender: Any) {
        cameraVC?.color = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
    }
    // Delete the drawings
    @IBAction func clearPaint(_ sender: Any) {
        cameraVC?.tempDrawImageView.image = nil
    }
    
    // Save the drawings
    @IBAction func savePaint(_ sender: Any) {
        // Merge the drawn lines with the shown picture
        cameraVC?.savePaintedLines()
        // The new Painted Image overwrites the old image in the file directory
        cameraVC?.saveImage(imageName: cameraVC!.shownPreviewImageName, image: cameraVC!.savedImagePreviewView.image!)
        // Reload the elements in the collection view to update the displayed images
        galleryVC?.collectionView.reloadData()
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
