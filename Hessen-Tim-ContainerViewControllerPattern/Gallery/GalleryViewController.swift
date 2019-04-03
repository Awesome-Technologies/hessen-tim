//
//  GalleryViewController.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 13.03.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import UIKit


/*
 //--- functionallity of the collection view
 // info from https://stackoverflow.com/questions/31735228/how-to-make-a-simple-collection-view-with-swift
 */

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        collectionView.layer.borderWidth = 1.0
        collectionView.layer.borderColor = UIColor.lightGray.cgColor
        collectionView.layer.backgroundColor = UIColor.init(red: 65/255, green: 81/255, blue: 124/255, alpha: 1).cgColor
        
    }
    
    
    let reuseIdentifier = "cell" // also enter this string as the cell identifier in the storyboard
    //var items = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48"]
    //var items = ["1", "2"]
    var items = [String]()

    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! GalleryPictureCollectionViewCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.myLabel.text = self.items[indexPath.item].replacingOccurrences(of: ".jpg", with: "")
        
        //loads The Image, that was saved when the Photo was taken
        cell.galleryImage.image = getImage(imageName: self.items[indexPath.item])
        
        cell.backgroundColor = UIColor.white // make cell more visible in our example project
        print("we have the index: \(indexPath)")
        //collectionView.reloadData()
        //collectionView.scrollToItem(at: indexPath, at: .right, animated: true)
        
        //--makes the cell round
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 4

        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }
 
    /*
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let i = IndexPath(item: 3, section: 0)
        collectionView.reloadData()
        collectionView.scrollToItem(at: i, at: .left, animated: true)
        print("Selected")
    }
    */
    
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
    
    func insertItemTest(imageName: String){
        /*
         //Update DataSource
         let newComment = "3"
         items.append(newComment)
         
         let indexPath = IndexPath(item: self.items.count - 1, section: 0)
         var indexPaths: [IndexPath] = [indexPath]
         
         // finally update the collection view
         self.collectionView?.performBatchUpdates({ () -> Void in
         collectionView.insertItems(at: indexPaths)
         }, completion: nil)
         */
        self.collectionView?.performBatchUpdates({
            let indexPath = IndexPath(row: self.items.count, section: 0)
            items.append(imageName) //add your object to data source first
            self.collectionView?.insertItems(at: [indexPath])
        }, completion: nil)
    }
    
    func getImage(imageName: String) -> UIImage?{
        
        var image : UIImage?
        
        let fileManager = FileManager.default
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        if fileManager.fileExists(atPath: imagePath){
            image = UIImage(contentsOfFile: imagePath)
        }else{
            print("Panic! No Image!")
        }
        
        return image
    }
    
    
    /*
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidth: CGFloat = flowLayout.itemSize.width
        let cellSpacing: CGFloat = flowLayout.minimumInteritemSpacing
        let cellCount = CGFloat(collectionView.numberOfItems(inSection: section))
        var collectionWidth = collectionView.frame.size.width
        if #available(iOS 11.0, *) {
            collectionWidth -= collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right
        }
        let totalWidth = cellWidth * cellCount + cellSpacing * (cellCount - 1)
        if totalWidth <= collectionWidth {
            let edgeInset = (collectionWidth - totalWidth) / 2
            return UIEdgeInsets(top: flowLayout.sectionInset.top, left: edgeInset, bottom: flowLayout.sectionInset.bottom, right: edgeInset)
        } else {
            return flowLayout.sectionInset
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
