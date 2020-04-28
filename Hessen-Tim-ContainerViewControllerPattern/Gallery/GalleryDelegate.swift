//
//  GalleryDelegate.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 14.03.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import Foundation
import SMART

//https://naveenr.net/beginning-container-views-in-ios/

protocol GalleryDelegate:class {
    func addGalleryImage(imageName: String, newImage: Bool)
    func addGalleryPreviewImage(imageName: String)
    func addGalleryFotoImage(imageName: String)
    func addGalleryUpdateImage(imageName: String)
    func clearView()
    func setCategory() -> String
    func createDateLabel(media: Media)
}
