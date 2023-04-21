//
//  TestResultViewController.swift
//  ProMind
//
//  Created by HAIKUO YU on 17/4/23.
//

import UIKit

class TestResultViewController: UIViewController {
    private let indexPath: IndexPath
    private let testType: ProMindTestType
    
    private let tmtRecordCoreDataModel = TMTRecordCoreDataModel.shared
    private let dstRecordCoreDataModel = DSTRecordCoreDataModel.shared
    
    init(indexPath: IndexPath, testType: ProMindTestType) {
        self.indexPath = indexPath
        self.testType = testType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tmtRecordCoreDataModel.fetchRecords()
        dstRecordCoreDataModel.fetchRecords()
    }
    
    private func displayResults() {
        switch testType {
        case .trialMakingTest:
            let testRecord: TMTRecord = tmtRecordCoreDataModel.savedEntities[indexPath.row]
            
        case .digitSpanTest:
            let testRecord: DSTRecord = dstRecordCoreDataModel.savedEntities[indexPath.row]
        }
    }
    
}
