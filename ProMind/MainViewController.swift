//
//  MainViewController.swift
//  ProMind
//
//  Created by Tan Wee Keat on 6/6/21.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func testButtonPressed(_ sender: UIButton) {
        print("Button \(sender.tag) tapped... Navigating to \(sender.titleLabel?.text ?? "Something went wrong when button is pressed")...")

        if sender.tag == 0 {
            // Navigate to TMT
        } else if sender.tag == 1 {
            // Navigate to DST
        } else {
            print("Main.testButtonPressed() went wrong")
        }
    }
    
}

