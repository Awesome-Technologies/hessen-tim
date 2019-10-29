//
//  CustomToolbar.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 06.08.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import UIKit

class CustomToolbar: UIToolbar {

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        var newSize: CGSize = super.sizeThatFits(size)
        newSize.height = 120  // there to set your toolbar height
        
        return newSize
    }
    
}
