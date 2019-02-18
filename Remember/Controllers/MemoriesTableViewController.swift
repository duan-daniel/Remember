//
//  MemoriesViewController.swift
//  Remember
//
//  Created by Daniel Duan on 1/19/19.
//  Copyright © 2019 Daniel Duan. All rights reserved.
//

import UIKit
import RealmSwift
import StatefulViewController

class MemoriesTableViewController: UITableViewController, StatefulViewController {
    
    // array of memories
    var memoriesArray: Results<Memory>?
    let realm = try! Realm()
    
    // for state controller
    let emptyStateView = UIView()
    let noStateView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMemories()
        tableView.rowHeight = 152
        tableView.separatorStyle = .none
        
    }
    
    // load memories from realm database
    func loadMemories() {
        memoriesArray = realm.objects(Memory.self)
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // set up empty data set
        createEmptyView()
        
        let stateMachine = ViewStateMachine(view: view)
        stateMachine["empty"] = emptyStateView
        stateMachine["none"] = noStateView
        
        // if there is at least one object in the memories array
        if memoriesArray != nil && memoriesArray!.count > 0 {
            stateMachine.transitionToState(.view("none"), animated: true) {
            }
        }
        // if memories array is empty, display the empty state view
        else {
            stateMachine.transitionToState(.view("empty"), animated: true) {
            }
        }
        
        tableView.reloadData()

    }
    
    func createEmptyView() {
        let emptyStateLabel = UILabel()
        emptyStateLabel.frame = CGRect(x: 0, y: 200, width: self.view.frame.width, height: 120)
        emptyStateLabel.text = "No Memories Yet!"
        emptyStateLabel.textAlignment = .center
        
        emptyStateView.addSubview(emptyStateLabel)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return memoriesArray?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memoryCell", for: indexPath) as! MemoriesTableViewCell
        let memory = memoriesArray?[indexPath.row]
        
        // round the image
        cell.imageOfObject.layer.cornerRadius = 10
        cell.imageOfObject.clipsToBounds = true
        cell.imageOfObject.image = UIImage(data: memory?.image as! Data)
    
        cell.nameOfObject.text = memory?.objectName
        
        let formatter : DateFormatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        let dateStr : String = formatter.string(from:   NSDate.init(timeIntervalSinceNow: 0) as Date)
        
        cell.dateLastVisited.text = dateStr
        
        cell.viewOfContent.layer.cornerRadius = 10
        cell.viewOfContent.layer.masksToBounds = true
        
        return cell
        
        
    }
 
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        if identifier == "displayMemory" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let destination = segue.destination as! DescriptionViewController
            
            let memoryToDisplay = memoriesArray?[indexPath.row]
            destination.memory = memoryToDisplay

        }
        

    }

}
