//
//  CameraPictureViewController.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 13.03.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import UIKit
import AVFoundation
import SMART

/**
 //Camera View tutorial from here: https://guides.codepath.com/ios/Creating-a-Custom-Camera-View
 //Drawing functionality from here: https://www.raywenderlich.com/5895-uikit-drawing-tutorial-how-to-make-a-simple-drawing-app
 */

class CameraPictureViewController: UIViewController , AVCapturePhotoCaptureDelegate , CameraPictureDelegate {

    //Delegate
    weak var delegate:GalleryDelegate?
    
    //Outlets
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var savedImagePreviewView: UIImageView!
    //@IBOutlet weak var captureImageView: UIImageView!
    @IBOutlet weak var tempDrawImageView: UIImageView!
    
    //instance variables
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    //Variable that indicates if you can draw on the tempDrawImageScreen
    var drawingActive = false
    
    //Variables for drawing
    var lastPoint = CGPoint.zero
    var color = UIColor.black
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var swiped = false
    
    // The previewImage, that is shown on the screen
    var shownPreviewImageName = ""
    
    
    var photoName = 0
    
    var currentObservation:ObservationType = .NONE
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload), name: NSNotification.Name(rawValue: "load"), object: nil)
    }
    
    @objc func reload() {
        print("Reload Camera")
    }

    /*
    @IBAction func didTakePhoto(_ sender: Any) {
        
        /*
        let videoPreviewLayerOrientation = self.videoPreviewLayer.connection?.videoOrientation
        
        if let photoOutputConnection = self.stillImageOutput.connection(with: .video) {
            photoOutputConnection.videoOrientation = videoPreviewLayerOrientation!
        }

        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
        
        //insertItemTest()
        delegate?.addGalleryImage()
        print("I press the Button!")
 */
        //makePhoto()
        clearTempFolder()
        
    }
    */
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Setup your camera here...
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
            else {
                print("Unable to access back camera!")
                return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            stillImageOutput = AVCapturePhotoOutput()
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
            
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
        
        
    }
    
    
    func setupLivePreview() {
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        videoPreviewLayer.videoGravity = .resizeAspect
        videoPreviewLayer.connection?.videoOrientation = .landscapeRight
        previewView.layer.addSublayer(videoPreviewLayer)
        
        //Step12
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
            //Step 13
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.bounds
            }
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation()
            else { return }
        
        //let image = UIImage(data: imageData)
        //captureImageView.image = image
        
        if let image = UIImage(data: imageData){
            
            //savePhotoToFile(image: image)
            //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            saveImage(imageName: "\(photoName).jpg", image: image)
            
            //insertItemTest()
            delegate?.addGalleryImage(imageName: "\(photoName).jpg")
            
            //captureImageView.image = image
            getImage(imageName: "\(photoName).jpg")
        }
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    //Function called by the photo button from the base View
    func makePhoto(observation: ObservationType){
        
        currentObservation = observation
        
        photoName = photoName+1
        
        let videoPreviewLayerOrientation = self.videoPreviewLayer.connection?.videoOrientation
        
        if let photoOutputConnection = self.stillImageOutput.connection(with: .video) {
            photoOutputConnection.videoOrientation = videoPreviewLayerOrientation!
        }
        
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
        
        print("I press the Button!")
        
    }
    
    func saveImage(imageName: String, image:UIImage){
        //create an instance of the FileManager
        let fileManager = FileManager.default
        //get the image path
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        //get the JPEG data for this image
        let data = image.jpegData(compressionQuality: 1)
        //store it in the document directory
        fileManager.createFile(atPath: imagePath as String, contents: data, attributes: nil)
        
        Institute.shared.saveImage(imageData: data!, observationType: currentObservation)
    }
    
    func getImage(imageName: String){
        let fileManager = FileManager.default
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        if fileManager.fileExists(atPath: imagePath){
            //captureImageView.image = UIImage(contentsOfFile: imagePath)
        }else{
            print("Panic! No Image!")
        }
    }
    
    func clearTempFolder() {
        let fileManager = FileManager.default
        let tempFolderPath = NSTemporaryDirectory()
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: tempFolderPath)
            for filePath in filePaths {
                try fileManager.removeItem(atPath: tempFolderPath + filePath)
            }
        } catch {
            print("Could not clear temp folder: \(error)")
        }
    }
    
    func didSelectImage(photoName: String) {
        let fileManager = FileManager.default
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(photoName)
        if fileManager.fileExists(atPath: imagePath){
            do {
                let imageData = try Data(contentsOf: URL(fileURLWithPath: imagePath))
                
                //Save the name of the image, that is shown on the screen
                shownPreviewImageName = photoName
                print("Shown on the screen: ",shownPreviewImageName)
                
                //the drawing functions should only activated if the view is made visible. If it is already visible another call to the function would make the buttons invisible again
                if(savedImagePreviewView.isHidden) {
                    //Function call to show button for drawing on the screen in the BaseViewController
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "drawButtonFunction"), object: nil)
                }
            
                savedImagePreviewView.isHidden = false
                savedImagePreviewView.image = UIImage(data: imageData)
                
            } catch {
                print("Error loading image!")
            }
        }else{
            print("Panic! No Image!")
        }
    }
    
    /**
     This function hides/unhides the drawing pane and activates/deactivates the touch handling for the drawinf pane
    */
    func activateDrawigFunctions() {
        if(drawingActive) {
            //Set the DrawingPanel to invisible, so the drawings not seen anymore
            tempDrawImageView.isHidden = true
        
            //Set Drawing Variable to false, so drawing touch function are inactive
            drawingActive = false
            
        } else {
            //Set the DrawingPanel to visible, so the drawings are seen
            tempDrawImageView.isHidden = false
            
            //Set Drawing Variable to true, so drawing functions are active
            drawingActive = true
        }
    }
    
    @IBAction func hideSaveImagePreviewView() {
        //savedImagePreviewView.isHidden = true
    }
    
    func closeImagePreview() {
        
        // Delete content of previewView and Hide it
        savedImagePreviewView.image = nil
        savedImagePreviewView.isHidden = true
        
        // Delete content of paintImageView
        tempDrawImageView.image = nil
        
        // Should the drawing functions be still active: disable them
        print("Drawing",drawingActive)
        if(drawingActive) {
            activateDrawigFunctions()
        }
    }
    
    /**
     Gets called, when the user touches the screen
     Start of a drawing event
     Save the touch location in lastPoint so when the user starts drawing, to keep track of where the stroke started.
    */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if(drawingActive) {
            guard let touch = touches.first else {
                return
            }
            swiped = false
            lastPoint = touch.location(in: view)
        }
    }
    
    //Draws lines, als long as the finger is moved on the screen
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(drawingActive) {
            guard let touch = touches.first else {
                return
            }
            
            // 6
            swiped = true
            let currentPoint = touch.location(in: view)
            drawLine(from: lastPoint, to: currentPoint)
            
            // 7
            lastPoint = currentPoint
        }
    }
    
    //Draws a line on the the tempDrawImageView from ate old and the new touch point
    func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
        // 1
        UIGraphicsBeginImageContext(view.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        tempDrawImageView.image?.draw(in: view.bounds)
        
        // 2
        context.move(to: fromPoint)
        context.addLine(to: toPoint)
        
        // 3
        context.setLineCap(.round)
        context.setBlendMode(.normal)
        context.setLineWidth(brushWidth)
        context.setStrokeColor(color.cgColor)
        
        // 4
        context.strokePath()
        
        // 5
        tempDrawImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempDrawImageView.alpha = opacity
        UIGraphicsEndImageContext()
    }
    //Merge the drawinfs so far with the image displayed in the SavedImagePreview
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(drawingActive) {
            if !swiped {
                // draw a single point
                drawLine(from: lastPoint, to: lastPoint)
            }
            
            //savePaintedLines()
        }
    }
    
    func savePaintedLines(){
        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(savedImagePreviewView.frame.size)
        savedImagePreviewView.image?.draw(in: view.bounds, blendMode: .normal, alpha: 1.0)
        tempDrawImageView?.image?.draw(in: view.bounds, blendMode: .normal, alpha: opacity)
        savedImagePreviewView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tempDrawImageView.image = nil
    }
    
    /*
    func savePhotoToFile(image:UIImage){
        
        print("I wanna Save the photo!")
        
        guard let documentDirectoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        //Using force unwrapping here because we're sure "1.jpg" exists. Remember, this is just an example.
        //let img = UIImage(named: "1.jpg")!
        
        // Change extension if you want to save as PNG.
        let imgPath = documentDirectoryPath.appendingPathComponent("MyHessenTimImage.jpg")
        
         print(imgPath)
        
        do {
            //Use .pngData() if you want to save as PNG.
            //.atomic is just an example here, check out other writing options as well. (see the link under this example)
            //(atomic writes data to a temporary file first and sending that file to its final destination)
            try image.jpegData(compressionQuality: 1)?.write(to: imgPath, options: .atomic)
        } catch {
            print(error.localizedDescription)
        }
    }
    */
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
