//
//  GalleryViewController.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 13.03.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import UIKit
import SwiftGifOrigin


/*
 //--- functionallity of the collection view
 // info from https://stackoverflow.com/questions/31735228/how-to-make-a-simple-collection-view-with-swift
 */

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    //Delegate
    weak var delegate:CameraPictureDelegate?
    weak var baseDelegate: GalleryDelegate?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var newPicture = false
    var category = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        collectionView.layer.borderWidth = 1.0
        collectionView.layer.borderColor = UIColor.lightGray.cgColor
        collectionView.layer.backgroundColor = UIColor.init(red: 65/255, green: 81/255, blue: 124/255, alpha: 1).cgColor
        
        category = self.baseDelegate?.setCategory() as! String
        
        //Set the curent vc in the Institute class
        Institute.shared.galleryVC = self
    }
    
    //var Institute.shared.getOrderedImageSubset(category: "Blutgasanalyse") = [String]()

    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Institute.shared.getOrderedImageSubset(category: category).count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let imageName = Institute.shared.getOrderedImageSubset(category: category)[indexPath.item]
        
        print("we have the index: \(indexPath)")
        print("All Items: " +  Institute.shared.getOrderedImageSubset(category: category).description)
        print("Ordered Subset: " + Institute.shared.getOrderedImageSubset(category: category).description)
        print("we have the Image Name: " + Institute.shared.getOrderedImageSubset(category: category)[indexPath.item])
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! GalleryPictureCollectionViewCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.myLabel.text = imageName
        
        //When an image, that is already in the cache is updated for example, when Lines are drawn
        if let imageData = Institute.shared.images[Institute.shared.getOrderedImageSubset(category: category)[indexPath.item]]?.content?.data{
            print("the image is already in the cache")
            //let imageData = imageMedia.content?.data
            if(imageData != nil){
                cell.loadingImage.isHidden = true
                let decodedData = Data(base64Encoded: imageData.value)!
                cell.galleryImage.image = getImage(imageName: cell.myLabel.text!)
                cell.galleryImage.isHidden = false
                
            }else{
                /*
                print("the image is NOTTT in the cache")
                cell.galleryImage.isHidden = true
                cell.loadingImage.isHidden = false
                cell.loadingImage.loadGif(asset: "loading")
                
                
                //After the load animation for the cell was set, the cell downloads its respective Image itself
                Institute.shared.getMediaWithID(id: Institute.shared.getOrderedImageSubset(category: "Blutgasanalyse")[indexPath.item], completion: { media in
                    DispatchQueue.main.async {
                        print("I LOADED The Image")
                        cell.galleryImage.image = self.getImage(imageName: media)
                        cell.loadingImage.isHidden = true
                        cell.galleryImage.isHidden = false
                    }
                    
                })
                */
            }
        }else{
            print("the image is NOT in the cache")
            cell.galleryImage.isHidden = true
            cell.loadingImage.isHidden = false
            cell.loadingImage.loadGif(asset: "loading")
            
            //After the load animation for the cell was set, the cell downloads its respective Image itself
            Institute.shared.getMediaWithID(id: imageName, completion: { media in
                DispatchQueue.main.async {
                    print("I LOADED The Image")
                    cell.galleryImage.image = self.getImage(imageName: media)
                    cell.loadingImage.isHidden = true
                    cell.galleryImage.isHidden = false
                }
                
            })
            
        }
        
        
        cell.backgroundColor = UIColor.white // make cell more visible in our example project
        if(newPicture){
            print("NEWIMAGE")
            cell.layer.borderColor = UIColor.yellow.cgColor
            cell.layer.borderWidth = 5
            cell.layer.cornerRadius = 4
        } else {
            print("OLDIMAGE")
            //--makes the cell round
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.borderWidth = 1
            cell.layer.cornerRadius = 4
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Handle tap events
        print("You selected cell #\(indexPath.item)!")
        
        // Get a reference to our storyboard cell
        let cell = collectionView.cellForItem(at: indexPath) as! GalleryPictureCollectionViewCell
        
        if(cell.loadingImage.isHidden == true){
        //if(cell.galleryImage.isHidden == false){
            print("loading screen visible")
            baseDelegate?.clearView()
            /**
             HINT: Because we base the selection of the image on the creation of a new subset, the replacement of the local image with the server image works.
             Because the local image (that gets deleted) and the server Image (that replaces the local image) take the same index in the created subset, the right image is displayed,
             even though the names of the images (here the keys in the dict) are completely different
            **/
            //delegate?.didSelectImage(photoName: Institute.shared.getOrderedImageSubset(category: category)[indexPath.row])
            delegate?.didSelectImage(photoName: cell.myLabel.text!)
            
        }
        
    }
 
    // change background color when user touches cell
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.init(white: 1, alpha: 0.6)
    }
    
    // change background color back when user releases touch
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.white
    }
    
    //change the width and Hight of the cells to the hight of the collectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        //return CGSize(width: 100.0, height: 100.0)
        return CGSize(width: collectionView.frame.height-10, height: collectionView.frame.height-10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func insertItemTest(imageName: String, newImage: Bool){
        
        
        print("Add LOADED Image")
        print(imageName)
        
        
        self.newPicture = newImage
        self.collectionView?.performBatchUpdates({
            
            //for row in 0..<collectionView.numberOfItems(inSection: 0){
            for cell in  self.collectionView!.visibleCells {
                if let tableViewCell = cell as? GalleryPictureCollectionViewCell {
                    if(tableViewCell.myLabel.text == imageName){
                        print("Changing the cells titel")
                        tableViewCell.loadingImage.isHidden = true
                        tableViewCell.galleryImage.image = getImage(imageName: imageName)
                        tableViewCell.galleryImage.isHidden = false
                    }
                        
                }else{
                    print("Cell not yet loaded")
                }
                
            }
        }, completion: { (result) in
            if result {
                self.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0), at: UICollectionView.ScrollPosition.right, animated: true)
            }
        })
    }
    
    func insertPreviewImage(imageName: String){
        print("Add PREVIEW Image")
        print(imageName)
        print("category" + self.category)
        print(Institute.shared.getOrderedImageSubset(category: category).description)
        let indexPath = IndexPath(row: Institute.shared.getOrderedImageSubset(category: category).count-1, section: 0)
        self.collectionView?.insertItems(at: [indexPath])
        /*
        self.collectionView?.performBatchUpdates({
            //Institute.shared.getOrderedImageSubset(category: "Blutgasanalyse").append(imageName)
            let indexPath = IndexPath(row: Institute.shared.getOrderedImageSubset(category: category).count-1, section: 0)
            self.collectionView?.insertItems(at: [indexPath])
        }, completion: nil)
        */
        
    }
    
    func insertFotoImage(imageName: String){
        print("Add FOTO Image")
        print(imageName)
        print("category: " + category)
        
        print(Institute.shared.getOrderedImageSubset(category: category).description)
        
        print("//I mande a new foto and I want to place it in a new cell")
        //I mande a new foto and I want to place it in a new cell
        self.collectionView?.performBatchUpdates({
            //Institute.shared.getOrderedImageSubset(category: "Blutgasanalyse").insert(imageName, at: 0)
            let indexPath = IndexPath(row: 0, section: 0)
            self.collectionView?.insertItems(at: [indexPath])
            
        }, completion: nil)
        /*
        if(Institute.shared.getOrderedImageSubset(category: category).contains(imageName)){
            print("//I updated an existing foto")
            //I updated an existing foto
            let indexPath = IndexPath(item: Institute.shared.getOrderedImageSubset(category: category).firstIndex(of: imageName)!, section: 0)
            collectionView.reloadItems(at: [indexPath])
           
        }else {
            print("//I mande a new foto and I want to place it in a new cell")
            //I mande a new foto and I want to place it in a new cell
            self.collectionView?.performBatchUpdates({
                //Institute.shared.getOrderedImageSubset(category: "Blutgasanalyse").insert(imageName, at: 0)
                let indexPath = IndexPath(row: 0, section: 0)
                self.collectionView?.insertItems(at: [indexPath])
                
            }, completion: nil)
        }
        */
    }
    
    func insertUpdateImage(imageName: String){
        print("UpdateImage")
        print(imageName)
        print("category: " + category)
        
        print(Institute.shared.getOrderedImageSubset(category: category).description)
        
        //I updated an existing foto
        let indexPath = IndexPath(item: Institute.shared.getOrderedImageSubset(category: category).firstIndex(of: imageName)!, section: 0)
        collectionView.reloadItems(at: [indexPath])
    }
    
    func getImage(imageName: String) -> UIImage?{
        print("getImage")
        print(imageName)
        
        
        var image : UIImage?
        //print(Institute.shared.images.description)
        print(imageName)
        //print(Institute.shared.images[imageName])
        
        if let imageMedia = Institute.shared.images[imageName]{
            let imageData = imageMedia.content?.data
            if(imageData != nil){
                let decodedData = Data(base64Encoded: imageData!.value)!
                //let jeremyGif = UIImage.gif(name: "jeremy")
                return UIImage(data: decodedData)
                
            }
            
        }else{
            print("Panic! No Image!")
        }
        return nil
    }
    
    /**
     Function gets by the Institute class, when the server finishes loading an image and the local image is replaced with the remote server image
     In the getOrderedImageSubset the new/updated Image from the server has the same index as the still existing old image in the Gallery
     So triggering the reload at that index will reload the right cell
     */
    func reloadGalleryImages(newImage:String) {
        DispatchQueue.main.async {
            let indexPath = IndexPath(item: Institute.shared.getOrderedImageSubset(category: self.category).firstIndex(of: newImage)!, section: 0)
            self.collectionView.reloadItems(at: [indexPath])
        }
    }
    
}
