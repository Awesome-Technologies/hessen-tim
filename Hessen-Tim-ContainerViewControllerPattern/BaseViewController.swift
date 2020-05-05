//
//  ViewController.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 13.03.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import UIKit
import SMART

class CommentTextView: UITextView {
    
    init(frame: CGRect) {
        super.init(frame: frame, textContainer: nil)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    func setup(){
        
        // Use RGB colour
        self.backgroundColor = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 0.8)
        
        // Update UITextView font size and colour
        self.font = UIFont.systemFont(ofSize: 20)
        self.textColor = UIColor.black
        
        self.font = UIFont.boldSystemFont(ofSize: 20)
        self.font = UIFont(name: "Verdana", size: 25)
        
        // Capitalize all characters user types
        self.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        
        // Enable auto-correction and Spellcheck
        self.autocorrectionType = UITextAutocorrectionType.yes
        self.spellCheckingType = UITextSpellCheckingType.yes
        
        // Make UITextView Editable
        self.isEditable = true
        
        self.delegate = self
        //self.text = "\u{2022} "
        
        
    }
    
    func showText(text: String){
        if(text == " "){
            self.text = "\u{2022} "
        }else{
            self.text = text + ("\n\n\u{2022} ")
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            var updatedText: String = textView.text! + ("\n\n\u{2022} ")
            textView.text = updatedText
            return false
            
        }
        return true
        
    }
}


/*
 Helping Tutorials:
 
 https://naveenr.net/beginning-container-views-in-ios/
 
 */

class BaseViewController: UIViewController {
    
    //UIView that overlays the BaseView in a light gray, when splitView bar is visible
    var customView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    let window = UIApplication.shared.keyWindow!
    
    var observationType: ObservationType? {
        didSet {
            loadViewIfNeeded()
        }
    }
    
    var observationObject:Observation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        collapseMaster = UIBarButtonItem(title: "Information >", style: .done, target: self, action: #selector(collapse))
        self.navigationItem.rightBarButtonItem = collapseMaster
        
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(toPrevScreen))
        
        setTitle(type: observationType!)
        
        //Initialization information for the gray sidebar
        customView = UIView(frame: window.bounds)
        self.customView.backgroundColor = UIColor.gray.withAlphaComponent(0.0)
        
        //Notifications to get information from the sidebar, when the gray overlay has to be turned on or off
        NotificationCenter.default.addObserver(self, selector: #selector(addGraySubview(_:)), name: Notification.Name(rawValue: "addGraySubview"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeGraySubview(_:)), name: Notification.Name(rawValue: "removeGraySubview"), object: nil)
        
        //Institute.shared.loadPreviewImagesInBackground(type: self.navigationItem.title!, completion: { (mediaItems) in
        Institute.shared.loadPreviewImagesInBackground(type: self.navigationItem.title!, completion: {
            DispatchQueue.main.async {
                print("Added Preview Imagessss")
                //self.setCategory()
                //Institute.shared.getOrderedImageSubset(category: category)
                print(Institute.shared.getOrderedImageSubset(category: self.navigationItem.title!))
                for media in Institute.shared.getOrderedImageSubset(category: self.navigationItem.title!) {
                    self.addGalleryPreviewImage(imageName: media)
                    /*
                    if media != nil {
                        //We put every preview Image in the cache
                        Institute.shared.saveImageInDirectory(imageData: media, name:String(media.id!.description))
                        self.addGalleryPreviewImage(imageName: media.id!.description)
                        
                    }
                    */
                    
                }
                
            }
            
        })
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(UserLoginCredentials.shared.selectedProfile == .ConsultationClinic){
            takePictureButton.isHidden = true
        }
    }
    
    
    var galleryVC:GalleryViewController?
    var cameraVC:CameraPictureViewController?
    var collapseMaster:UIBarButtonItem!
    var textView = UITextView()
    var dateLabel: UILabel = UILabel()
    
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
    @IBOutlet weak var saveComment: UIButton!
    @IBOutlet weak var clearComment: UIButton!
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        view.backgroundColor = UIColor.init(red: 38/255, green: 47/255, blue: 83/255, alpha: 1)
        
        if let vc = segue.destination as? GalleryViewController {
            galleryVC = vc
            galleryVC?.delegate = cameraVC
            galleryVC?.baseDelegate = self
            
        }
        
        if let vc = segue.destination as? CameraPictureViewController {
            cameraVC = vc
            cameraVC?.delegate = self
        }
    }
    
    
    /**
     Take a photo
     */
    @IBAction func takePicture(_ sender: Any) {
        cameraVC?.makePhoto(observation: observationType!)
    }
    
    /**
     Seques back to the MedicalDavacView
     */
    @IBAction func toPrevScreen(_ sender: Any) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.splitView = false
        delegate.setupRootViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    /**
     Shows or hides the commentView that displays Notes taken for the current picture
     */
    @IBAction func showComments(_ sender: Any) {
        
        //  if(commentWindowOpen == false) {
        if(commentButton.currentImage == UIImage(named: "comment-Button")) {
            commentButton.setImage(UIImage(named: "comment-Button-green"), for: .normal)
            
            textView = CommentTextView(frame: CGRect(x: 0, y: 0, width: 600, height: 400))
            textView.center = self.view.center
            textView.textAlignment = NSTextAlignment.justified
            textView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
            
            // Make UITextView web links clickable
            if(UserLoginCredentials.shared.selectedProfile == .PeripheralClinic){
                saveComment.isHidden = false
                clearComment.isHidden = false
                
                textView.isSelectable = true
                textView.dataDetectorTypes = UIDataDetectorTypes.link
            }else if (UserLoginCredentials.shared.selectedProfile == .ConsultationClinic){
                textView.isSelectable = false
            }
            
            
            // Make UITextView corners rounded
            textView.layer.cornerRadius = 5
            textView.layer.borderWidth = 2
            self.view.addSubview(textView)
            textView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                //textView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                textView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 215),
                textView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -200),
                textView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 5),
                textView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -5),
            ])
            
            paintButton.isHidden = true
            
            var med = Institute.shared.images[cameraVC!.shownPreviewImageName]
            
            textView.text = med?.note![0].text?.description
            
        } else {
            textView.removeFromSuperview()
            commentButton.setImage(UIImage(named: "comment-Button"), for: .normal)
            if(UserLoginCredentials.shared.selectedProfile == .PeripheralClinic){
                saveComment.isHidden = true
                clearComment.isHidden = true
                paintButton.isHidden = false
            }
            
        }
        
        
        
    }
    
    /**
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
            
            commentButton.isHidden = true
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
            
            commentButton.isHidden = false
            
        }
    }
    
    @objc func collapse(){
        //https://stackoverflow.com/questions/35005887/trouble-using-a-custom-image-for-splitviewcontroller-displaymodebuttonitem-uiba
        UIApplication.shared.sendAction(splitViewController!.displayModeButtonItem.action!, to: splitViewController!.displayModeButtonItem.target, from: nil, for: nil)
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
    }
    
    /**
     Sets the title of the View according to the selected category type
     */
    func setTitle(type:ObservationType){
        switch type {
        case .Anamnesis:
            self.navigationItem.title = "Anamnese"
        case .MedicalLetter:
            self.navigationItem.title = "Arztbriefe"
        case .Haemodynamics:
            self.navigationItem.title = "Haemodynamik"
        case .Respiration:
            self.navigationItem.title = "Beatmung"
        case .BloodGasAnalysis:
            self.navigationItem.title = "Blutgasanalyse"
        case .Perfusors:
            self.navigationItem.title = "Perfusoren"
        case .InfectiousDisease:
            self.navigationItem.title = "Infektiologie"
        case .Radeology:
            self.navigationItem.title = "Radiologie"
        case .Lab:
            self.navigationItem.title = "Labor"
        case .Others:
            self.navigationItem.title = "Sonstige"
        case .NONE:
            self.navigationItem.title = "NONE"
        default:
            self.navigationItem.title = ""
        }
        
        let attrs = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont(name: "Georgia-Bold", size: 25)!
        ]
        
        UINavigationBar.appearance().titleTextAttributes = attrs
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
    
    /**
     Gets called, when a image in the gallery is selected
     Prepares the elements on the screen to be displayed correctly
     */
    func clear() {
        print("clear")
        clearPaint(self)
        clearComment(self)
        
        redButton.isHidden = true
        greenButton.isHidden = true
        blueButton.isHidden = true
        blackButton.isHidden = true
        whiteButton.isHidden = true
        clearButton.isHidden = true
        saveButton.isHidden = true
        saveComment.isHidden = true
        clearComment.isHidden = true
        takePictureButton.isHidden = true
        
        textView.removeFromSuperview()
        dateLabel.removeFromSuperview()
        paintButton.setImage(UIImage(named: "malen-button"), for: .normal)
        commentButton.setImage(UIImage(named: "comment-Button"), for: .normal)
        
        if(UserLoginCredentials.shared.selectedProfile == .PeripheralClinic){
            paintButton.isHidden = false
        }
        closeButton.isHidden = false
        commentButton.isHidden = false
    }
    
    
    /**
     Closes the preview image and hides oll the visual elements
     */
    @IBAction func closeImagePreview(_ sender: Any) {
        print("I close the PreviewImageView")
        
        // Hide the Paint functions and change Button logo if necesr
        if(cameraVC!.drawingActive) {
            self.activateDrawing(nil)
        }
        //close the previewImage View
        cameraVC?.closeImagePreview()
        // Make the paint buttons invisible and show the take picture button
        closeImagePreview()
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
    
    /**
     Saves the drawings in an image
     */
    @IBAction func savePaint(_ sender: Any) {
        print("savePaint")
        // Merge the drawn lines with the shown picture
        cameraVC?.savePaintedLines()
        // The new Painted Image overwrites the old image in the file directory
        cameraVC?.saveImage(imageName: cameraVC!.shownPreviewImageName, image: cameraVC!.savedImagePreviewView.image!)
    }
    
    /**
     Saves the comments made for an image
     */
    @IBAction func saveComment(_ sender: Any) {
        print("SaveComment")
        Institute.shared.updateImageNote(name: cameraVC!.shownPreviewImageName, imageNote: textView.text, completion: {
            print("comment was saved")
        })
        
    }
    
    /**
     Deletes the appended comments and restores the original comment text
     */
    @IBAction func clearComment(_ sender: Any) {
        print("clearComment")
        let oldText = Institute.shared.images[cameraVC!.shownPreviewImageName]?.note?[0].text?.description
        textView.text = oldText
    }
    
    /**
     closes the image preview and hides all the respective visual elementas
     */
    func closeImagePreview(){
        clearPaint(self)
        clearComment(self)
        
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
        
        textView.removeFromSuperview()
        dateLabel.removeFromSuperview()
        saveComment.isHidden = true
        clearComment.isHidden = true
        
        //Show photo button
        if(UserLoginCredentials.shared.selectedProfile == .PeripheralClinic){
            takePictureButton.isHidden = false
        }

        
        cameraVC?.previewView.isHidden = false
    }
    
    /**
     When a Image is selecred from the gallery a label is created that displayes
     the date and time of the image creation
     */
    func createDateLabel(media: Media){
        //var label: UILabel = UILabel()
        dateLabel.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        dateLabel.font = dateLabel.font.withSize(22)
        dateLabel.textColor = UIColor.white
        dateLabel.layer.masksToBounds = true
        dateLabel.layer.cornerRadius = 10
        dateLabel.layer.borderWidth = 0
        dateLabel.layer.borderColor = UIColor.blue.cgColor
        dateLabel.backgroundColor = UIColor(red: 75/255, green: 99/255, blue: 139/255, alpha: 0.8)
        dateLabel.textAlignment = NSTextAlignment.center
        dateLabel.text = MediaDateFormatter(media: media)
        dateLabel.textAlignment = .center
        self.view.addSubview(dateLabel)
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dateLabel.heightAnchor.constraint(equalToConstant: 40),
            dateLabel.widthAnchor.constraint(equalToConstant: 220),
            //label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            dateLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10),
            //label.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20),
            dateLabel.topAnchor.constraint(equalTo: self.closeButton.topAnchor, constant: 0),
            //label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
        ])
        
    }
    
    /**
     Formats the image creation date into a readalbe format
     */
    func MediaDateFormatter(media: Media)->String{
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSZ"
        
        let clockTime = DateFormatter()
        clockTime.dateFormat = "HH:mm"
        
        let dateTime = DateFormatter()
        dateTime.dateFormat = "dd.MM.yyyy"
        
        var printdate = ""
        if let date = dateFormatterGet.date(from: (media.createdDateTime?.description)!) {
            
            var clock = clockTime.string(from: date)
            var date = dateTime.string(from: date)
            printdate = date + "   " + clock
            
        } else {
            print("There was an error decoding the string")
        }
        return printdate
    }
    
}


/**
 Designated delegate functions
 */
extension BaseViewController: GalleryDelegate {
    func addGalleryImage(imageName: String, newImage: Bool) {
        //print("added an Image")
        //print(imageName)
        galleryVC?.insertItemTest(imageName: imageName, newImage: newImage)
    }
    
    func addGalleryPreviewImage(imageName: String) {
        //print("added an Image")
        //print(imageName)
        galleryVC?.insertPreviewImage(imageName: imageName)
    }
    
    func addGalleryFotoImage(imageName: String) {
        //print("added an Image")
        //print(imageName)
        galleryVC?.insertFotoImage(imageName: imageName)
    }
    
    func addGalleryUpdateImage(imageName: String){
        galleryVC?.insertUpdateImage(imageName: imageName)
    }
    
    func clearView() {
        self.clear()
    }
    
    func setCategory() -> String {
        var stringCategory = ""
        switch observationType {
        case .Anamnesis:
            stringCategory = "Anamnese"
        case .MedicalLetter:
            stringCategory = "Arztbriefe"
        case .Haemodynamics:
            stringCategory = "Haemodynamik"
        case .Respiration:
            stringCategory = "Beatmung"
        case .BloodGasAnalysis:
            stringCategory = "Blutgasanalyse"
        case .Perfusors:
            stringCategory = "Perfusoren"
        case .InfectiousDisease:
            stringCategory = "Infektiologie"
        case .Radeology:
            stringCategory = "Radiologie"
        case .Lab:
            stringCategory = "Labor"
        case .Others:
            stringCategory = "Sonstige"
        case .NONE:
            stringCategory = "NONE"
        default:
            stringCategory = ""
        }
        
        print("setCategory" + stringCategory)
        //galleryVC?.category = stringCategory
        return stringCategory
    }
    
}


extension BaseViewController {
    func toggleMasterView() {
        let barButtonItem = self.collapseMaster
        UIApplication.shared.sendAction(barButtonItem!.action!, to: barButtonItem!.target, from: nil, for: nil)
    }
}
