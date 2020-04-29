//
//  DiagnosticReportTableViewCell.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 28.03.20.
//  Copyright © 2020 Michael Rojkov. All rights reserved.
//

import Foundation
import UIKit


//https://blog.usejournal.com/easy-tableview-setup-tutorial-swift-4-ad48ec4cbd45
class DiagnosticReportTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let cellView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red:41.0/255.0, green:45.0/255.0, blue:86.0/255.0, alpha:1.0)
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let icon: UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage(named:"consilButton.png")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
        
    }()
    
    let consilReport: UILabel = {
        let label = UILabel()
        label.text = "Konsilbericht"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let dateIssued: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let preview: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func setupView() {
        addSubview(cellView)
        cellView.addSubview(icon)
        cellView.addSubview(consilReport)
        cellView.addSubview(dateIssued)
        cellView.addSubview(preview)
        self.selectionStyle = .none
        
        NSLayoutConstraint.activate([
            cellView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            cellView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
            cellView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10),
            cellView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        icon.heightAnchor.constraint(equalToConstant: 40).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 55).isActive = true
        icon.centerYAnchor.constraint(equalTo: cellView.centerYAnchor).isActive = true
        icon.leftAnchor.constraint(equalTo: cellView.leftAnchor, constant: 20).isActive = true
        
        consilReport.heightAnchor.constraint(equalToConstant: 50).isActive = true
        consilReport.widthAnchor.constraint(equalToConstant: 100).isActive = true
        consilReport.centerYAnchor.constraint(equalTo: cellView.centerYAnchor).isActive = true
        consilReport.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 50).isActive = true
        
        dateIssued.heightAnchor.constraint(equalToConstant: 50).isActive = true
        dateIssued.widthAnchor.constraint(equalToConstant: 200).isActive = true
        dateIssued.centerYAnchor.constraint(equalTo: cellView.centerYAnchor).isActive = true
        dateIssued.leftAnchor.constraint(equalTo: consilReport.rightAnchor, constant: 50).isActive = true
        
        preview.heightAnchor.constraint(equalToConstant: 50).isActive = true
        preview.widthAnchor.constraint(equalToConstant: 450).isActive = true
        preview.centerYAnchor.constraint(equalTo: cellView.centerYAnchor).isActive = true
        preview.rightAnchor.constraint(equalTo: cellView.rightAnchor, constant: 50).isActive = true
        
    }
    
}
