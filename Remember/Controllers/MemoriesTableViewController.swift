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
        cell.imageOfObject.image = memory.image
        cell.nameOfObject.text = memory.objectName
        
        let formatter : DateFormatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        let dateStr : String = formatter.string(from:   NSDate.init(timeIntervalSinceNow: 0) as Date)
        
        cell.dateLastVisited.text = dateStr
        
        return cell
        
        
    }
 
    // MARK: - Navigation

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
