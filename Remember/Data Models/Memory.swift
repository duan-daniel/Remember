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
    
    init(objectName: String, imageOfObject: UIImage) {
        self.objectName = objectName
        self.imageOfObject = imageOfObject
    }
}
