//
//  Description.swift
//  Remember
//
//  Created by Daniel Duan on 1/30/19.
//  Copyright © 2019 Daniel Duan. All rights reserved.
//

import UIKit
import RealmSwift

class DescriptionViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var memory: Memory!
    var receivedImage: UIImage!
    
    let realm = try! Realm()
    
    //MARK: - SetUp Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }
    
    func setUpViews() {
        descriptionTextView.delegate = self

        // connect outlet's to memory's properties
        self.navigationItem.title = memory.objectName
        image.image = UIImage(data: memory?.image as! Data)
        descriptionTextView.text = memory.desc
        
        // round the image
        image.layer.cornerRadius = 20
        image.clipsToBounds = true
        
        // add "done" button on top of keyboard
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneClicked))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        descriptionTextView.inputAccessoryView = toolBar
        
        // if there is no description for the object yet
        if descriptionTextView.text == "" {
            descriptionTextView.text = "Write a description..."
            descriptionTextView.textColor = UIColor.lightGray
        }
    }
    
    // Called when the user begins to edit the text view
    // If the textView contains a placeholder (i.e. it's lightGray), update
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    // Called when user finishes editing the text view
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write a description..."
            textView.textColor = UIColor.lightGray
        }
        // save it to realm database
        do {
            try realm.write {
                memory.desc = textView.text
            }
        } catch {
            print("Error \(error)")
        }
        
    }
    
    @objc func doneClicked() {
        view.endEditing(true)
    }
    
    
    
}
