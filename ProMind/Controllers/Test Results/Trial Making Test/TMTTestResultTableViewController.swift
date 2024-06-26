//
//  TMTTestResultTableViewController.swift
//  ProMind
//
//  Created by HAIKUO YU on 17/4/23.
//

import UIKit

class TMTTestResultTableViewController: UITableViewController {
    public var indexPath: IndexPath = IndexPath()
    
    private let tmtRecordCoreDataModel = TMTRecordCoreDataModel.shared
    private var testRecord: TMTRecord? = nil
    private var currentCell: TMTTestResultTableViewCells = .unselected
    
    @IBOutlet var tmtResultTableView: UITableView!
    
    @IBOutlet weak var patientIdCell: UITableViewCell!
    @IBOutlet weak var experimentDateCell: UITableViewCell!
    @IBOutlet weak var experimentTypeCell: UITableViewCell!
    
    @IBOutlet weak var ageCell: UITableViewCell!
    @IBOutlet weak var genderCell: UITableViewCell!
    @IBOutlet weak var educationLevelCell: UITableViewCell!
    @IBOutlet weak var ethnicityCell: UITableViewCell!
    @IBOutlet weak var annualIncomeCell: UITableViewCell!
    @IBOutlet weak var remarksCell: UITableViewCell!
    
    @IBOutlet weak var startingCirclesCell: UITableViewCell!
    
    @IBOutlet weak var testATotalTimeTakenCell: UITableViewCell!
    @IBOutlet weak var testANumberOfCirclesLeftCell: UITableViewCell!
    @IBOutlet weak var testANumberOfErrorsCell: UITableViewCell!
    @IBOutlet weak var testANumberOfLiftsCell: UITableViewCell!
    @IBOutlet weak var testAScreenshotCell: UITableViewCell!
    
    @IBOutlet weak var testBTotalTimeTakenCell: UITableViewCell!
    @IBOutlet weak var testBNumberOfCirclesLeftCell: UITableViewCell!
    @IBOutlet weak var testBNumberOfErrorsCell: UITableViewCell!
    @IBOutlet weak var testBNumberOfLiftsCell: UITableViewCell!
    @IBOutlet weak var testBScreenshotCell: UITableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("TMT Test Record IndexPath: \(indexPath.description)")
        
        tmtRecordCoreDataModel.fetchRecords()
        testRecord = tmtRecordCoreDataModel.savedEntities[indexPath.row]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTableViewUI()
    }
    
    private func updateTableViewUI() {
        if let testRecord {
            configureNormalCellUI(for: patientIdCell, with: testRecord.patientId)
            
            let date = Date(timeIntervalSince1970: TimeInterval(testRecord.experimentDate))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
            
            configureNormalCellUI(for: experimentDateCell, with: dateFormatter.string(from: date))
            configureNormalCellUI(for: experimentTypeCell, with: testRecord.experimentType)
            
            configureNormalCellUI(for: ageCell, with: String(testRecord.age))
            configureNormalCellUI(for: genderCell, with: testRecord.gender)
            configureNormalCellUI(for: educationLevelCell, with: testRecord.educationLevel)
            configureNormalCellUI(for: ethnicityCell, with: testRecord.ethnicity)
            configureNormalCellUI(for: annualIncomeCell, with: testRecord.annualIncome)
            configureNormalCellUI(for: remarksCell, with: testRecord.remarks)
            
            configureNormalCellUI(for: startingCirclesCell, with: String(testRecord.tmtNumStartingCircles))
            
            configureNormalCellUI(for: testATotalTimeTakenCell, with: String(testRecord.tmtTotalTimeTakenTestA))
            configureNormalCellUI(for: testANumberOfCirclesLeftCell, with: String(testRecord.tmtNumCirclesLeftTestA))
            configureNormalCellUI(for: testANumberOfErrorsCell, with: String(testRecord.tmtNumErrorsTestA))
            configureNormalCellUI(for: testANumberOfLiftsCell, with: String(testRecord.tmtNumLiftsTestA))
            configureScreenshotCellUI(for: testAScreenshotCell)
            
            configureNormalCellUI(for: testBTotalTimeTakenCell, with: String(testRecord.tmtTotalTimeTakenTestB))
            configureNormalCellUI(for: testBNumberOfCirclesLeftCell, with: String(testRecord.tmtNumCirclesLeftTestB))
            configureNormalCellUI(for: testBNumberOfErrorsCell, with: String(testRecord.tmtNumErrorsTestB))
            configureNormalCellUI(for: testBNumberOfLiftsCell, with: String(testRecord.tmtNumLiftsTestB))
            configureScreenshotCellUI(for: testBScreenshotCell)
            
        }
    }
    
    private func configureNormalCellUI(for cell: UITableViewCell, with content: String?) {
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = content
        contentConfiguration.secondaryText = "Modify"
        cell.contentConfiguration = contentConfiguration
    }
    
    private func configureScreenshotCellUI(for cell: UITableViewCell) {
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = "Click to view"
        contentConfiguration.secondaryText = "View"
        cell.contentConfiguration = contentConfiguration
    }
}

// Segue to test result modification scenes.
extension TMTTestResultTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView.cellForRow(at: indexPath) {
        case testAScreenshotCell:
            currentCell = .testAScreenshotCell
            performSegue(withIdentifier: "presentTMTScreenshot", sender: self)
            
        case testBScreenshotCell:
            currentCell = .testBScreenshotCell
            performSegue(withIdentifier: "presentTMTScreenshot", sender: self)
            
        default:
            currentCell = .unselected
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "presentTMTScreenshot":
            let destinationController = segue.destination as! TMTScreenshotViewViewController
            destinationController.indexPath = indexPath
            
            switch currentCell {
            case .testAScreenshotCell:
                destinationController.masterCell = .testAScreenshotCell
            case .testBScreenshotCell:
                destinationController.masterCell = .testBScreenshotCell
            default:
                break
            }
        default:
            print("Unidentified segue found for TMT test result table view!")
            break
        }
    }
}
