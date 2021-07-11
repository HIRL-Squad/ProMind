//
//  MainViewController.swift
//  ProMind
//
//  Created by Tan Wee Keat on 6/6/21.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Animate Label, can consider using CLTypingLabel
        titleLabel.text = ""
        var charIdx: Double = 0
        let titleText = "ProMind"
        for letter in titleText {
            Timer.scheduledTimer(withTimeInterval: 0.1 * charIdx, repeats: false) { timer in
                self.titleLabel.text?.append(letter)
            }
            charIdx += 1
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    // Use Unconditional Segue instead. Keeping for reference.
    @IBAction func testSelected(_ sender: UIButton) {
        //        let test = sender.currentTitle!
        //
        //        switch test {
        //            case Strings.TrailMakingTest:
        //                navigate(destination: Strings.TMT)
        //            case Strings.DigitSpanTest:
        //                navigate(destination: Strings.DST)
        //            default:
        //                print("MainViewController.testSelected(): Something went wrong")
        //        }
    }
    
    //    func navigate(destination: String) {
    //        self.performSegue(withIdentifier: destination, sender: self)
    //    }
    
    // To prepare for new view controller before navigation.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        switch segue.identifier {
        case K.goToTMTSegue:
            let tmtMainViewController = segue.destination as! TMTMainViewController // Force downcast UIViewController to TMTMainViewController
            tmtMainViewController.text = "Sample Data TMT"
        case K.goToDSTSegue:
            let dstMainViewController = segue.destination as! DSTMainViewController
            dstMainViewController.text = "Sample Data DST"
        default:
            print("MainViewController.prepare(): No segue identifier is matched")
        }
        
    }
}

