//
//  TMTMainViewController.swift
//  ProMind
//
//  Created by Tan Wee Keat on 26/6/21.
//

import UIKit

class TMTMainViewController: UIViewController {

    @IBOutlet weak var numberOfCirclesSegmentedControl: UISegmentedControl!
    @IBOutlet weak var numberOfCirclesStackView: UIStackView!
    
    var text: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let font = UIFont(name: K.fontTypeNormal, size: 18) ?? UIFont.systemFont(ofSize: 18)
        numberOfCirclesSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        numberOfCirclesSegmentedControl.selectedSegmentIndex = -1
    }
    
    @IBAction func beginButtonPressed(_ sender: UIButton) {
        if numberOfCirclesSegmentedControl.selectedSegmentIndex != -1 {
            performSegue(withIdentifier: K.TMT.goToTMTGameSegue, sender: self)
        } else {
            let border = UIView(
                frame: CGRect(
                    x: 0,
                    y: 0,
                    width: numberOfCirclesSegmentedControl.bounds.width + 20,
                    height: numberOfCirclesSegmentedControl.bounds.height + 20))
            border.center = numberOfCirclesSegmentedControl.center
            border.backgroundColor = .clear
            border.layer.borderColor = UIColor.red.cgColor
            border.layer.borderWidth = 2.0

            numberOfCirclesStackView.addSubview(border)
            numberOfCirclesStackView.bringSubviewToFront(numberOfCirclesSegmentedControl)
            
            UIView.animate(withDuration: K.animateDuration, delay: 0, options: [.curveLinear, .autoreverse, .repeat]) {
                border.alpha = K.animateAlpha
            } completion: { _ in
                return
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.TMT.goToTMTGameSegue {
            switch numberOfCirclesSegmentedControl.selectedSegmentIndex {
            case 0:
                TMTResultViewController.numCircles = 10
                break
            case 1:
                TMTResultViewController.numCircles = 15
                break
            case 2:
                TMTResultViewController.numCircles = 20
                break
            case 3:
                TMTResultViewController.numCircles = 25
                break
            default:
                TMTResultViewController.numCircles = 25
            }
        }
    }
    
    //    @IBAction func backButtonPressed(_ sender: UIButton) {
//        self.dismiss(animated: true, completion: nil)
//    }
    
}
