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

    @IBAction func testSelected(_ sender: UIButton) {
        let test = sender.currentTitle!
                
        switch test {
            case Strings.TrailMakingTest:
                navigate(destination: Strings.TMT)
            case Strings.DigitSpanTest:
                navigate(destination: Strings.DST)
            default:
                print("MainViewController.testSelected(): Something went wrong")
        }
    }
    
    func navigate(destination: String) {
        self.performSegue(withIdentifier: destination, sender: self)
    }
    
    // To prepare for new view controller before navigation.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        switch segue.identifier {
            case Strings.TMT:
                let tmtMainViewController = segue.destination as! TMTMainViewController // Force downcast UIViewController to TMTMainViewController
                tmtMainViewController.text = "Sample Data TMT"
            case Strings.DST:
                let dstMainViewController = segue.destination as! DSTMainViewController
                dstMainViewController.text = "Sample Data DST"
            default:
                print("MainViewController.prepare(): No segue identifier is matched")
        }

    }
}

