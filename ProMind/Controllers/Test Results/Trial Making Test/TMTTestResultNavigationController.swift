//
//  TMTTestResultNavigationController.swift
//  ProMind
//
//  Created by HAIKUO YU on 4/5/23.
//

import UIKit

class TMTTestResultNavigationController: UINavigationController {
    public var indexPath: IndexPath = IndexPath()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Trail Making Test Results"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! TMTTestResultTableViewController
        controller.indexPath = indexPath
    }
}
