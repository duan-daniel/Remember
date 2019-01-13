//
//  PopUpViewController.swift
//  Remember
//
//  Created by Daniel Duan on 1/11/19.
//  Copyright © 2019 Daniel Duan. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController {

    //TODO: Fix Design
    //TODO: Disable User interaction on ARView
    
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var takePhotoButton: UIButton!
    
    var textToDisplay = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // gives the popup rounded corners
        popUpView.layer.cornerRadius = 20
        popUpView.layer.masksToBounds = true
        
        takePhotoButton.layer.cornerRadius = 7
        dismissButton.layer.cornerRadius = 7
        
        textLabel.text = textToDisplay
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.minimumScaleFactor = 0.2
        
    }
    
    @IBAction func takePhotoButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func dismissButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
