//
//  PopUpViewController.swift
//  Remember
//
//  Created by Daniel Duan on 1/11/19.
//  Copyright © 2019 Daniel Duan. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController {

    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var popUpView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // gives the popup rounded corners
        popUpView.layer.cornerRadius = 10
        popUpView.layer.masksToBounds = true
    }
    
    
    @IBAction func takePhotoButtonPressed(_ sender: UIButton) {
        
    }
    
    
    @IBAction func dismissButtonPressed(_ sender: UIButton) {
        
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
