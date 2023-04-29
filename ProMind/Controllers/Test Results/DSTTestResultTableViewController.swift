//
//  DSTTestResultTableViewController.swift
//  ProMind
//
//  Created by HAIKUO YU on 17/4/23.
//

import UIKit

class DSTTestResultTableViewController: UITableViewController {
    public var indexPath: IndexPath = IndexPath()
    
    private let dstRecordCoreDataModel = DSTRecordCoreDataModel.shared
    private var testRecord: DSTRecord? = nil
    
    @IBOutlet weak var patientIdCell: UITableViewCell!
    @IBOutlet weak var experimentDateCell: UITableViewCell!
    @IBOutlet weak var experimentTypeCell: UITableViewCell!
    
    @IBOutlet weak var ageCell: UITableViewCell!
    @IBOutlet weak var genderCell: UITableViewCell!
    @IBOutlet weak var educationLevelCell: UITableViewCell!
    @IBOutlet weak var ethnicityCell: UITableViewCell!
    @IBOutlet weak var annualIncomeCell: UITableViewCell!
    @IBOutlet weak var remarksCell: UITableViewCell!
    
    @IBOutlet weak var fstLongestConsecutiveCorrectnessCell: UITableViewCell!
    @IBOutlet weak var fstNumberOfCorrectTrialsCell: UITableViewCell!
    @IBOutlet weak var fstMaximumCorrectDigitsCell: UITableViewCell!
    @IBOutlet weak var fstTotalTimeTakenCell: UITableViewCell!
    @IBOutlet weak var fstAudioRecordingCell: UITableViewCell!
    
    @IBOutlet weak var bstLongestConsecutiveCorrectnessCell: UITableViewCell!
    @IBOutlet weak var bstNumberOfCorrectnessTrialsCell: UITableViewCell!
    @IBOutlet weak var bstMaximumCorrectDigitsCell: UITableViewCell!
    @IBOutlet weak var bstTotalTimeTakenCell: UITableViewCell!
    @IBOutlet weak var bstAudioRecordingCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DST Test Result IndexPath: \(indexPath.description)")
        
        dstRecordCoreDataModel.fetchRecords()
        testRecord = dstRecordCoreDataModel.savedEntities[indexPath.row]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTableViewUI()
    }
    
    private func updateTableViewUI() {
        if let testRecord {
            configureNormalCellUI(for: patientIdCell, with: testRecord.patientId)
            configureNormalCellUI(for: experimentDateCell, with: String(testRecord.experimentDate))
            configureNormalCellUI(for: experimentTypeCell, with: testRecord.experimentType)
            
            configureNormalCellUI(for: ageCell, with: String(testRecord.age))
            configureNormalCellUI(for: genderCell, with: testRecord.gender)
            configureNormalCellUI(for: educationLevelCell, with: testRecord.educationLevel)
            configureNormalCellUI(for: ethnicityCell, with: testRecord.ethnicity)
            configureNormalCellUI(for: annualIncomeCell, with: testRecord.annualIncome)
            configureNormalCellUI(for: remarksCell, with: testRecord.remarks)
            
            configureNormalCellUI(for: fstLongestConsecutiveCorrectnessCell, with: String(testRecord.fstLongestSequence))
            configureNormalCellUI(for: fstNumberOfCorrectTrialsCell, with: String(testRecord.fstNumCorrectTrials))
            configureNormalCellUI(for: fstMaximumCorrectDigitsCell, with: String(testRecord.fstMaxDigits))
            configureNormalCellUI(for: fstTotalTimeTakenCell, with: String(testRecord.fstTotalTimeTaken))
            configureAudioRecordingCellUI(for: fstAudioRecordingCell)
            
            configureNormalCellUI(for: bstLongestConsecutiveCorrectnessCell, with: String(testRecord.bstLongestSequence))
            configureNormalCellUI(for: bstNumberOfCorrectnessTrialsCell, with: String(testRecord.bstNumCorrectTrials))
            configureNormalCellUI(for: bstMaximumCorrectDigitsCell, with: String(testRecord.bstMaxDigits))
            configureNormalCellUI(for: bstTotalTimeTakenCell, with: String(testRecord.bstTotalTimeTaken))
            configureAudioRecordingCellUI(for: bstAudioRecordingCell)
        }
    }
    
    private func configureNormalCellUI(for cell: UITableViewCell, with content: String?) {
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = content
        contentConfiguration.secondaryText = "Modify"
        cell.contentConfiguration = contentConfiguration
    }
    
    private func configureAudioRecordingCellUI(for cell: UITableViewCell) {
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = "Click to view"
        contentConfiguration.secondaryText = "View"
        cell.contentConfiguration = contentConfiguration
    }
}
