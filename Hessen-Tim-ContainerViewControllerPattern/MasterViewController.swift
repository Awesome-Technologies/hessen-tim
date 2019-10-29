//
//  MasterViewController.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 12.06.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var addButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        addButton = UIBarButtonItem(title: "close", style: .done, target: self, action: #selector(collapse))
        navigationItem.leftBarButtonItem = nil

        tableView.rowHeight = 65

        self.view.backgroundColor = UIColor.init(red: 38/255, green: 47/255, blue: 83/255, alpha: 1)
        self.navigationController?.setToolbarHidden(false, animated: true)

        /**Create a UIView, that is shown in the toolbar of the navigationController
         and that holds the buttons for saving and making calls
         */
        let viewFN = UIView(frame: CGRect.init(x: 0, y: 0, width: (self.navigationController?.view.frame.width)!, height: 120))
        viewFN.backgroundColor = UIColor.init(red: 38/255, green: 47/255, blue: 83/255, alpha: 1)

        //Some values for the button creation
        let buttonWidth = 100
        let buttonHight = 100
        let rigt_left_margin = 20

        //Add Button to save the order
        let button1 = UIButton(frame: CGRect.init(x: 0 + rigt_left_margin, y: 0, width: buttonWidth, height: buttonHight))
        button1.center.y = viewFN.center.y
        button1.setImage(UIImage(named: "Speichern"), for: .normal)
        button1.contentVerticalAlignment = .fill
        button1.contentHorizontalAlignment = .fill
        button1.addTarget(self, action: #selector(self.speichern), for: .touchUpInside)

        //Add button to make a simple call
        let button2 = UIButton(frame: CGRect.init(x: 10, y: 0, width: buttonWidth, height: buttonHight))
        button2.center = viewFN.center
        button2.setImage(UIImage(named: "Anruf"), for: .normal)
        button2.contentVerticalAlignment = .fill
        button2.contentHorizontalAlignment = .fill
        button2.addTarget(self, action: #selector(self.anrufen), for: .touchUpInside)

        //Add button to make a video call
        let button3 = UIButton(frame: CGRect.init(x: Int(viewFN.frame.size.width) - buttonWidth - rigt_left_margin, y: 0, width: buttonWidth, height: buttonHight))
        button3.center.y = viewFN.center.y
        button3.setImage(UIImage(named: "Videotelefonie"), for: .normal)
        button3.contentVerticalAlignment = .fill
        button3.contentHorizontalAlignment = .fill
        button3.addTarget(self, action: #selector(self.videoanruf), for: .touchUpInside)

        //Add the buttons to the UIView
        viewFN.addSubview(button1)
        viewFN.addSubview(button2)
        viewFN.addSubview(button3)

        //Add the UIView to the toolbar
        self.navigationController?.toolbar.addSubview(viewFN)


    }

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
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

        let backgroundView = UIView()
        /*
        backgroundView.backgroundColor = UIColor.blue
        backgroundView.backgroundColor!.withAlphaComponent(0.3)
        backgroundView.alpha = 0.0
        */
        //backgroundView.backgroundColor = UIColor.clear
        backgroundView.backgroundColor = UIColor.init(red: 38/255, green: 47/255, blue: 83/255, alpha: 0.5)
        cell.selectedBackgroundView = backgroundView

        return cell
    }

    override func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.performSegue(withIdentifier: "patientData", sender: self)

            self.splitViewController?.preferredDisplayMode = UISplitViewController.DisplayMode.allVisible
            self.navigationItem.leftBarButtonItem = nil
            let detailVC = self.splitViewController?.secondaryViewController
            print(self.splitViewController?.title)
            print(self.splitViewController?.isCollapsed)
        }
        else{
            self.performSegue(withIdentifier: "cameraData", sender: self)
            self.splitViewController?.preferredDisplayMode = UISplitViewController.DisplayMode.primaryHidden
            self.navigationItem.leftBarButtonItem = addButton
            let detailVC = self.splitViewController?.secondaryViewController
            print(detailVC?.title)
            print(self.splitViewController?.isCollapsed)
        }
    }

    override func tableView(_ tableView: UITableView,willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){

        cell.contentView.alpha = 0.0

        if indexPath.row == 0 {
            cell.backgroundView = UIImageView(image: UIImage(named: "TablePatientendaten.png")!)

        } else if indexPath.row == 1 {
            cell.backgroundView = UIImageView(image: UIImage(named: "TabAnamnese.png")!)
        } else if indexPath.row == 2 {
            cell.backgroundView = UIImageView(image: UIImage(named: "TabArztbriefe.png")!)
        } else if indexPath.row == 3 {
            cell.backgroundView = UIImageView(image: UIImage(named: "TabMonitoring.png")!)
        } else if indexPath.row == 4 {
            cell.backgroundView = UIImageView(image: UIImage(named: "TabBeatmung.png")!)
        } else if indexPath.row == 5 {
            cell.backgroundView = UIImageView(image: UIImage(named: "TabBlutgasanalyse.png")!)
        } else if indexPath.row == 6 {
            cell.backgroundView = UIImageView(image: UIImage(named: "TabPerfusoren.png")!)
        } else if indexPath.row == 7 {
            cell.backgroundView = UIImageView(image: UIImage(named: "TabMibi.png")!)
        } else if indexPath.row == 8 {
            cell.backgroundView = UIImageView(image: UIImage(named: "TabRadiologie.png")!)
        } else if indexPath.row == 9 {
            cell.backgroundView = UIImageView(image: UIImage(named: "TabLabor.png")!)
        } else if indexPath.row == 10 {
            cell.backgroundView = UIImageView(image: UIImage(named: "TabSonstige.png")!)
         }
    }

    @objc func collapse(){
        //https://stackoverflow.com/questions/35005887/trouble-using-a-custom-image-for-splitviewcontroller-displaymodebuttonitem-uiba
        UIApplication.shared.sendAction(splitViewController!.displayModeButtonItem.action!, to: splitViewController!.displayModeButtonItem.target, from: nil, for: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
    }

    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell  = tableView.cellForRow(at: indexPath)
        cell!.contentView.backgroundColor = .red
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
