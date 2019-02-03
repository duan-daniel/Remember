//
//  Memory.swift
//  Remember
//
//  Created by Daniel Duan on 1/14/19.
//  Copyright © 2019 Daniel Duan. All rights reserved.
//

import Foundation
import UIKit

class Memory {
    var objectName: String
    var image: UIImage
    var description: String
    
    init(objectName: String, imageOfObject: UIImage, description: String) {
        self.objectName = objectName
        self.image = imageOfObject
        self.description = description
    }
}
