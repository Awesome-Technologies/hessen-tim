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
    
    var currentObservation:ObservationType = .NONE
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload), name: NSNotification.Name(rawValue: "load"), object: nil)
    }
    
    @objc func reload() {
        print("Reload Camera")
    }

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
    
    /**
     Setup the camera and the preview view
     */
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
    
    /**
     captures the taken image and saves it
     */
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation()
            else { return }
        
        if let image = UIImage(data: imageData){
            saveImage(imageName: nil, image: image)
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    /**
     Called by the photo button from the BaseViewController
     */
    func makePhoto(observation: ObservationType){
        
        currentObservation = observation
        
        let videoPreviewLayerOrientation = self.videoPreviewLayer.connection?.videoOrientation
        
        if let photoOutputConnection = self.stillImageOutput.connection(with: .video) {
            photoOutputConnection.videoOrientation = videoPreviewLayerOrientation!
        }
        
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
        
        print("I press the Button!")
        
    }
    
    /**
     Saves a new image in cache and Server or updates an existing image in cache and server
     */
    func saveImage(imageName: String?, image:UIImage){
        print("saveImage")
        
        let data = image.jpegData(compressionQuality: 1)
        
        if (imageName == nil){
            Institute.shared.saveImage(imageData: data!, observationType: currentObservation, completion: { imageName in
                DispatchQueue.main.async {
                    print("We made a photo and want to Add it!!!")
                    self.delegate?.addGalleryFotoImage(imageName: imageName)
                }
                
            })
        }else {
            print("updateImage")
            Institute.shared.updateImageMedia(name: imageName!, imageData: image.jpegData(compressionQuality: 1.0)!, completion: {
                self.delegate?.addGalleryUpdateImage(imageName: imageName!)
            })
        }
        
    }
    
    /*
    func getImage(imageName: String){
        let fileManager = FileManager.default
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        if fileManager.fileExists(atPath: imagePath){
            //captureImageView.image = UIImage(contentsOfFile: imagePath)
        }else{
            print("Panic! No Image!")
        }
    }
    */
    /*
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
    */
    
    /**
     Shows a image on the preview view, when it was selected in the gallery
     */
    func didSelectImage(photoName: String) {
        let imageMedia = Institute.shared.images[photoName]
        if let imageData = imageMedia!.content?.data{
            let decodedData = Data(base64Encoded: imageData.value)!
            //Save the name of the image, that is shown on the screen
            shownPreviewImageName = photoName
            print("Shown on the screen: ",shownPreviewImageName)
            
            self.delegate?.createDateLabel(media: imageMedia!)
            
            previewView.isHidden = true
            savedImagePreviewView.isHidden = false
            savedImagePreviewView.image = UIImage(data: decodedData)
            savedImagePreviewView.contentMode = .scaleAspectFit
        } else {
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
            lastPoint = touch.location(in: tempDrawImageView)
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
            let currentPoint = touch.location(in: tempDrawImageView)
            drawLine(from: lastPoint, to: currentPoint)
            
            // 7
            lastPoint = currentPoint
        }
    }
    
    //Draws a line on the the tempDrawImageView from ate old and the new touch point
    func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
        // 1
        UIGraphicsBeginImageContext(tempDrawImageView.bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        //tempDrawImageView.image?.draw(in: tempDrawImageView.bounds)
        tempDrawImageView.image?.draw(at: CGPoint.zero)
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
    
    
    
    
}
