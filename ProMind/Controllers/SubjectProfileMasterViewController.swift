//
//  SubjectProfileTableTableViewController.swift
//  ProMind
//
//  Created by Tan Wee Keat on 27/8/21.
//

import UIKit


/**
 The delegate of SubjectMasterDetailViewController must conform to MasterViewControllerDelegate.
 */
protocol MasterViewControllerDelegate: AnyObject {
    /// To update DetailViewController after selecting a question.
    /// - Parameters:
    ///     - masterViewController: The MasterViewController instance that invokes this method.
    ///     - question: The selected question.
    ///     - options: The list of options available for selection for a given question.
    func masterViewController(_ masterViewController: SubjectProfileMasterViewController, didSelectQuestion question: String, optionsForQuestion options: [String])
}

// We automatically conform to UITableViewDelegate because we are using UITableViewController
class SubjectProfileMasterViewController: UITableViewController {
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIButton!

    @IBOutlet weak var patientTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var birthDatePicker: UIDatePicker!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var subjectIdLabel: UILabel!
    
    @IBOutlet weak var occupationTextField: UITextField!
    
    @IBOutlet weak var sarcfScoreLabel: UILabel!
    
    weak var delegate: MasterViewControllerDelegate?
    
    private var isSaveButtonPressed = false
    private var currentIndexPath: IndexPath?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("SubjectProfileMasterViewController :: viewDidLoad")
        
        Subject.shared.delegate = self
        
        mobileNumberTextField.delegate = self
        occupationTextField.delegate = self
        
        // tableView.layer.borderColor = UIColor(named: "Grey")?.cgColor
        // tableView.layer.borderWidth = 1.0
        
        // To handle tap events, specifically hide keyboard on tap.
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.cancelsTouchesInView = false
        splitViewController?.view.addGestureRecognizer(tap)
        
        splitViewController?.preferredDisplayMode = .oneBesideSecondary // To display both master and detail views together
        splitViewController?.presentsWithGesture = false // To prevent users from showing/hiding master view
                
        // To assign self to be the delegate of DetailViewController (To update Master from Detail).
        guard let rightNavController = splitViewController?.viewControllers.last as? UINavigationController else {
            fatalError("Errors occurred while downcasting SplitViewController (Detail).")
        }
        
        let detailViewController = rightNavController.viewControllers.first as? SubjectProfileDetailViewController
        detailViewController?.delegate = self
    }

    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func patientTypeValueChanged(_ sender: UISegmentedControl) {
        if patientTypeSegmentedControl.selectedSegmentIndex == 0 {
            Subject.shared.isPatient = true
        } else {
            Subject.shared.isPatient = false
        }
    }
    
    @IBAction func birthDateValueChanged(_ sender: UIDatePicker) {
        Subject.shared.birthDate = Int64(sender.date.timeIntervalSince1970)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == mobileNumberTextField {
            textField.keyboardType = .numberPad
        } else {
            textField.keyboardType = .asciiCapable
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == mobileNumberTextField {
            Subject.shared.mobileNumber = textField.text
        } else {
            Subject.shared.occupation = textField.text
        }
    }
    
    @IBAction func genderValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            Subject.shared.gender = .Male
        } else {
            Subject.shared.gender = .Female
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        print("saveButtonPressed")
        
        isSaveButtonPressed = true
        
        // To reset all pre-selected rows (so, there is no need to implement didDeselectOption).
        for section in 0 ..< tableView.numberOfSections {
            for row in 0 ..< tableView.numberOfRows(inSection: section) {
                let cell = tableView.cellForRow(at: IndexPath(row: row, section: section))
                
                print("Section \(section) Row \(row): \(cell?.reuseIdentifier): \(Subject.shared[cell?.reuseIdentifier ?? ""])")
                
                if let identifier = cell?.reuseIdentifier, let value = Subject.shared[identifier] {
                     print("\(identifier): \(value)")
                    
                    if value is NSNull {
                        cell?.backgroundColor = UIColor(named: "Light Red")
                    } else {
                        cell?.backgroundColor = .white
                    }
                }
                
                // print()
            }
        }
                
        // performSegue(withIdentifier: K.goToTestSelectionSegue, sender: self)
    }
    
    // MARK: - Table View
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentIndexPath = indexPath
        
        print("Selected section \(indexPath.section), row \(indexPath.row)")
        
        guard let cell = tableView.cellForRow(at: indexPath) else {
            fatalError("SubjectProfileMasterViewController :: Unable to retrieve tableViewCell from indexPath")
        }
        
        // Inform DetailViewController that a cell has been selected
        if let identifier = cell.reuseIdentifier, let options = K.SubjectProfile.Master.questions[identifier] {
            delegate?.masterViewController(self, didSelectQuestion: identifier, optionsForQuestion: options)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if isSaveButtonPressed {
            if let identifier = cell.reuseIdentifier, let value = Subject.shared[identifier] {
//                 print("\(identifier): \(value)")
                
                if value is NSNull {
                    cell.backgroundColor = UIColor(named: "Light Red")
                } else {
                    cell.backgroundColor = .white
                }
            }
        }
    }
    
    private func refreshTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK: - DetailViewControllerDelegate Implementations
extension SubjectProfileMasterViewController: DetailViewControllerDelegate {
    func detailViewController(_ detailViewController: SubjectProfileDetailViewController, selectedQuestion question: String, didSelectOption option: String) {
        guard let indexPath = currentIndexPath else { return }
        
        print("SubjectProfileMasterViewController :: Option Selected: \(option)")
        
        if let cell = tableView.cellForRow(at: indexPath) {
            let tableViewLabels = cell.contentView.subviews // [UILabel("Subject Type"), UILabel("trial")]
            let detailLabel = tableViewLabels[1] as! UILabel
            detailLabel.text = option
        }
    }
}

// MARK: - UITextFieldDelegate Implementation
extension SubjectProfileMasterViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Constraints only apply to Mobile Number
        if textField == mobileNumberTextField {
            // if backspace is pressed, return true
            if string == "" {
                return true
            }
            
            // return true if number is provided and if the length of the text is less than four
            if let _ = string.rangeOfCharacter(from: .decimalDigits), let text = textField.text {
                return text.count < 4
            }
            return false
        } else {
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Dismiss keyboard
        return true
    }
    
    @objc func handleTap() {
        // Dismiss keyboard
        mobileNumberTextField.resignFirstResponder()
        occupationTextField.resignFirstResponder()
    }
}

// MARK: - SubjectDelegate Implementation
extension SubjectProfileMasterViewController: SubjectDelegate {
    func subject(_ subject: Subject, didSetSubjectId subjectId: String?) {
        subjectIdLabel.text = subjectId
        refreshTableView()
    }
    
    func subject(_ subject: Subject, didUpdateSarcfScores scores: [Int]) {
        var totalScore = 0
        scores.forEach { score in
            if score != -1 {
                totalScore += score
            }
        }
        sarcfScoreLabel.text = "\(totalScore)"
    }
}
