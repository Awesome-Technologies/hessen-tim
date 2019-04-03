//
//  CameraPictureViewController.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 13.03.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import UIKit
import AVFoundation

/*
 //Camera View tutorial from here: https://guides.codepath.com/ios/Creating-a-Custom-Camera-View
 */

class CameraPictureViewController: UIViewController , AVCapturePhotoCaptureDelegate , CameraPictureDelegate {

    //Delegate
    weak var delegate:GalleryDelegate?
    
    //Outlets
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var savedImagePreviewView: UIImageView!
    //@IBOutlet weak var captureImageView: UIImageView!
    
    //instance variables
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    var photoName = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    func makePhoto(){
        
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
            
                savedImagePreviewView.isHidden = false
                savedImagePreviewView.image = UIImage(data: imageData)
            } catch {
                print("Error loading image!")
            }
        }else{
            print("Panic! No Image!")
        }
    }
    
    @IBAction func hideSaveImagePreviewView() {
        savedImagePreviewView.isHidden = true
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
