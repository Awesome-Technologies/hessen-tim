//
//  MasterViewController.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 12.06.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import UIKit


class CategoryTableViewCell: UITableViewCell{
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryImages: UILabel!
    @IBOutlet weak var highlightView: UIView!
    
}

class MasterViewController: UITableViewController {

    var addButton: UIBarButtonItem!
    
    var selectedCategory = 4
    
    var ImageCategoryCount:Dictionary<ObservationType, String> = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        addButton = UIBarButtonItem(title: "close", style: .done, target: self, action: #selector(collapse))
        navigationItem.leftBarButtonItem = addButton

        tableView.rowHeight = 65

        self.view.backgroundColor = UIColor.init(red: 38/255, green: 47/255, blue: 83/255, alpha: 1)
        
        tableView.separatorColor = UIColor(red:45.0/255.0, green:55.0/255.0, blue:95.0/255.0, alpha:0.0)
        
        /*
        var initialIndexPath = IndexPath(row: selectedCategory, section: 0)
        //self.performSegue(withIdentifier: "mySegue", sender: initialIndexPath)
        self.tableView.selectRow(at: initialIndexPath, animated: true, scrollPosition:UITableView.ScrollPosition.none)
        self.performSegue(withIdentifier: "cameraData", sender: initialIndexPath)
        */
        
        Institute.shared.countImages(completion: { observation, count  in
            //self.setNumberOfImagesInCategory(observation: observation, count: count)
            self.ImageCategoryCount[observation] = String(count)
            DispatchQueue.main.async {
                if (self.splitViewController?.viewControllers != nil){
                    self.tableView.reloadRows(at: [IndexPath(row: observation.ordinal()+1, section: 0)], with: .automatic)
                }
            }
        })
        


    }
    /*
    override func viewDidAppear(_ animated: Bool) {
      // ...
        var initialIndexPath = IndexPath(row: selectedCategory, section: 0)
        //self.tableView.selectRow(at: initialIndexPath, animated: true, scrollPosition:UITableView.ScrollPosition.none)
    }
    */

    // MARK: - Table view data source
    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
    */

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CategoryTableViewCell
        let detailVC = (self.splitViewController?.viewControllers.last as? UINavigationController)?.topViewController as! BaseViewController
        if((detailVC.observationType?.ordinal())!+1 == indexPath.row){
            //cell.contentView.backgroundColor = .red
            cell.backgroundColor = UIColor.init(red: 38/255, green: 47/255, blue: 83/255, alpha: 1)
            cell.highlightView.backgroundColor = UIColor.init(red: 49.0/255.0, green: 49.0/255.0, blue: 49.0/255.0, alpha: 0.2)
        }else{
            //cell.contentView.backgroundColor = UIColor.init(red: 38/255, green: 47/255, blue: 83/255, alpha: 1)
            cell.highlightView.backgroundColor = UIColor.clear
            cell.backgroundColor = UIColor.init(red: 38/255, green: 47/255, blue: 83/255, alpha: 1)
            //cell.backgroundColor = UIColor.init(red: 38/255, green: 47/255, blue: 83/255, alpha: 1)
        }
        
        if indexPath.row == 0 {
            cell.categoryImage.image = UIImage(named: "TabPatientData.png")!
            cell.categoryImages.isHidden = true
        } else if indexPath.row == 1 {
            cell.categoryImage.image = UIImage(named: "TabAnamnesis.png")!
            cell.categoryImages.text = self.ImageCategoryCount[ObservationType.Anamnesis]
        } else if indexPath.row == 2 {
            cell.categoryImage.image = UIImage(named: "TabMedicalLetter.png")!
            cell.categoryImages.text = self.ImageCategoryCount[ObservationType.MedicalLetter]
        } else if indexPath.row == 3 {
            cell.categoryImage.image =  UIImage(named: "TabHaemodynamics.png")!
            cell.categoryImages.text = self.ImageCategoryCount[ObservationType.Haemodynamics]
            print("THIS IS FOR CELL 3")
            print(self.ImageCategoryCount[ObservationType.Haemodynamics])
        } else if indexPath.row == 4 {
            cell.categoryImage.image = UIImage(named: "TabVentilation.png")!
            cell.categoryImages.text = self.ImageCategoryCount[ObservationType.Respiration]
        } else if indexPath.row == 5 {
            cell.categoryImage.image = UIImage(named: "TabBloodGasAnalysis.png")!
            cell.categoryImages.text = self.ImageCategoryCount[ObservationType.BloodGasAnalysis]
        } else if indexPath.row == 6 {
            cell.categoryImage.image = UIImage(named: "TabPerfusors.png")!
            cell.categoryImages.text = self.ImageCategoryCount[ObservationType.Perfusors]
        } else if indexPath.row == 7 {
            cell.categoryImage.image = UIImage(named: "TabInfectiousDisease.png")!
            cell.categoryImages.text = self.ImageCategoryCount[ObservationType.InfectiousDisease]
        } else if indexPath.row == 8 {
            cell.categoryImage.image = UIImage(named: "TabRadeology.png")!
            cell.categoryImages.text = self.ImageCategoryCount[ObservationType.Radeology]
        } else if indexPath.row == 9 {
            cell.categoryImage.image = UIImage(named: "TabLab.png")!
            cell.categoryImages.text = self.ImageCategoryCount[ObservationType.Lab]
        } else if indexPath.row == 10 {
            cell.categoryImage.image = UIImage(named: "TabOther.png")!
            cell.categoryImages.text = self.ImageCategoryCount[ObservationType.Others]
        }
        cell.selectionStyle = UITableViewCell.SelectionStyle.gray
        /*
        if cell.isSelected == true {
            var bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.brown
            cell.selectedBackgroundView = bgColorView
        } else {
            /*
            var bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.gray
            bgColorView.backgroundColor!.withAlphaComponent(0.3)
            bgColorView.alpha = 0.0
            */
            cell.contentView.superview?.backgroundColor = UIColor.clear
            //cell.selectedBackgroundView = bgColorView

            //cell.selectionStyle = UITableViewCell.SelectionStyle.gray
        }
        */
        /*
        let backgroundView = UIView()
        /*
        backgroundView.backgroundColor = UIColor.blue
        backgroundView.backgroundColor!.withAlphaComponent(0.3)
        backgroundView.alpha = 0.0
        */
        //backgroundView.backgroundColor = UIColor.clear
        backgroundView.backgroundColor = UIColor.init(red: 38/255, green: 47/255, blue: 83/255, alpha: 0.5)
        cell.selectedBackgroundView = backgroundView
        cell.backgroundColor = UIColor.init(red: 38/255, green: 47/255, blue: 83/255, alpha: 1)
        */
        
        
        return cell
    }

    override func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let delegate = UIApplication.shared.delegate as! AppDelegate
            delegate.splitView = false
            delegate.setupRootViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }
        else{
            
            var type = ObservationType.NONE
            switch indexPath.row {
            case 1:
                type = ObservationType.Anamnesis
            case 2:
                type = ObservationType.MedicalLetter
            case 3:
                type = ObservationType.Haemodynamics
            case 4:
                type = ObservationType.Respiration
            case 5:
                type = ObservationType.BloodGasAnalysis
            case 6:
                type = ObservationType.Perfusors
            case 7:
                type = ObservationType.InfectiousDisease
            case 8:
                type = ObservationType.Radeology
            case 9:
                type = ObservationType.Lab
            case 10:
                type = ObservationType.Others
            default:
                type = ObservationType.NONE
            }
            
            self.performSegue(withIdentifier: "cameraData", sender: self)
            self.splitViewController?.preferredDisplayMode = UISplitViewController.DisplayMode.primaryHidden
            self.navigationItem.leftBarButtonItem = addButton
            let detailVC = (self.splitViewController?.viewControllers.last as? UINavigationController)?.topViewController as! BaseViewController
            detailVC.observationType = type
            print(detailVC.title)
            print(self.splitViewController?.isCollapsed)
            tableView.reloadData()
        }
    }
    /*
    override func tableView(_ tableView: UITableView,willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
        
        //cell.contentView.alpha = 0.0

        if indexPath.row == 0 {
            //cell.backgroundView = UIImageView(image: UIImage(named: "TabPatientData.png")!)
            //cell.imageView?.image = UIImage(named: "TabPatientData.png")!

        } else if indexPath.row == 1 {
            cell.backgroundView = UIImageView(image: UIImage(named: "TabAnamnesis.png")!)
        } else if indexPath.row == 2 {
            cell.backgroundView = UIImageView(image: UIImage(named: "TabMedicalLetter.png")!)
        } else if indexPath.row == 3 {
            cell.backgroundView = UIImageView(image: UIImage(named: "TabHaemodynamics.png")!)
        } else if indexPath.row == 4 {
            cell.backgroundView = UIImageView(image: UIImage(named: "TabVentilation.png")!)
        } else if indexPath.row == 5 {
            cell.backgroundView = UIImageView(image: UIImage(named: "TabBloodGasAnalysis.png")!)
        } else if indexPath.row == 6 {
            cell.backgroundView = UIImageView(image: UIImage(named: "TabPerfusors.png")!)
        } else if indexPath.row == 7 {
            cell.backgroundView = UIImageView(image: UIImage(named: "TabInfectiousDisease.png")!)
        } else if indexPath.row == 8 {
            cell.backgroundView = UIImageView(image: UIImage(named: "TabRadeology.png")!)
        } else if indexPath.row == 9 {
            cell.backgroundView = UIImageView(image: UIImage(named: "TabLab.png")!)
        } else if indexPath.row == 10 {
            cell.backgroundView = UIImageView(image: UIImage(named: "TabOther.png")!)
         }
        
        cell.contentView.backgroundColor = UIColor.init(red: 38/255, green: 47/255, blue: 83/255, alpha: 1)
        cell.backgroundColor = UIColor.init(red: 38/255, green: 47/255, blue: 83/255, alpha: 1)
        
    }
    */

    @objc func collapse(){
        //https://stackoverflow.com/questions/35005887/trouble-using-a-custom-image-for-splitviewcontroller-displaymodebuttonitem-uiba
        UIApplication.shared.sendAction(splitViewController!.displayModeButtonItem.action!, to: splitViewController!.displayModeButtonItem.target, from: nil, for: nil)
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
    }

    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell  = tableView.cellForRow(at: indexPath)
        //cell!.contentView.backgroundColor = .red
    }
    

    @objc func speichern(){
        print("Fall gespeichert")
    }

    @objc func anrufen(){
        print("Anruf machen")
    }

    @objc func videoanruf(){
        print("videoanruf machens")
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
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
