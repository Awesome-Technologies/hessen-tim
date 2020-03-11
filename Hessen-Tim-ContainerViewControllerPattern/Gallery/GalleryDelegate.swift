//
//  GalleryDelegate.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 14.03.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import Foundation

//https://naveenr.net/beginning-container-views-in-ios/

protocol GalleryDelegate:class {
    func addGalleryImage(imageName: String, newImage: Bool) 
}
