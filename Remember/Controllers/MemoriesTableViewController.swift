//
//  MemoriesViewController.swift
//  Remember
//
//  Created by Daniel Duan on 1/19/19.
//  Copyright © 2019 Daniel Duan. All rights reserved.
//

import UIKit

class MemoriesTableViewController: UITableViewController {

    var memoriesArray = [Memory]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 152
        tableView.separatorStyle = .none
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("view did appear gets called")
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return memoriesArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memoryCell", for: indexPath) as! MemoriesTableViewCell
        let memory = memoriesArray[indexPath.row]
        
        cell.imageOfObject.layer.cornerRadius = 10
        cell.imageOfObject.clipsToBounds = true
        cell.imageOfObject.image = memory.image
    
        cell.nameOfObject.text = memory.objectName
        
        let formatter : DateFormatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        let dateStr : String = formatter.string(from:   NSDate.init(timeIntervalSinceNow: 0) as Date)
        
        cell.dateLastVisited.text = dateStr
        
        cell.viewOfContent.layer.cornerRadius = 10
        cell.viewOfContent.layer.masksToBounds = true
        
        return cell
        
        
    }

    func makeRoundedImage(image: UIImage, radius: Float) -> UIImage {
        var imageLayer = CALayer()
        imageLayer.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        imageLayer.contents = image.cgImage
        
        imageLayer.masksToBounds = true
        imageLayer.cornerRadius = CGFloat(radius)
        
        UIGraphicsBeginImageContext(image.size)
        imageLayer.render(in: UIGraphicsGetCurrentContext()!)
        var roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return roundedImage!
    }
 
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        if identifier == "displayMemory" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let destination = segue.destination as! DescriptionViewController
            
            let memoryToDisplay = memoriesArray[indexPath.row]
            destination.memory = memoryToDisplay

        }
        

    }

}
