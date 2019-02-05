//
//  Memory.swift
//  Remember
//
//  Created by Daniel Duan on 1/14/19.
//  Copyright © 2019 Daniel Duan. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class Memory: Object {
    @objc dynamic var objectName: String = ""
    @objc dynamic var image: NSData = NSData()
    @objc dynamic var desc: String = ""
    
}
