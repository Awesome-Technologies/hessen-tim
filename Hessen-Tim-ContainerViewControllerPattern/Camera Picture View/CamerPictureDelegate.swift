//
//  CamerPictureDelegat.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Marco Festini on 03.04.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import Foundation

protocol CameraPictureDelegate:class {
    func didSelectImage(photoName: String)
}
