//
//  SubjectProfileTableTableViewController.swift
//  ProMind
//
//  Created by Tan Wee Keat on 27/8/21.
//

import UIKit
import LanguageManager_iOS

/**
 The delegate of SubjectMasterDetailViewController must conform to MasterViewControllerDelegate.
 */
protocol MasterViewControllerDelegate: AnyObject {
    /// To update DetailViewController after selecting a question.
    /// - Parameters:
    ///     - masterViewController: The MasterViewController instance that invokes this method.
    ///     - question: The selected question.
    ///     - options: The list of options available for selection for a given question.
    func masterViewController(_ masterViewController: ExperimentProfileMasterViewController, didSelectQuestion question: String, optionsForQuestion options: [String]?)
}


/**
 Use extension to add a "localized" method to all String instances which updates global setting UserDefault to change app language at run time.
 **/
extension String {
    var localized: String {
        if let _ = UserDefaults.standard.string(forKey: "i18n_language") {} else {
            UserDefaults.standard.set("en", forKey: "i18n_language")
            UserDefaults.standard.synchronize()
        }

        let lang = UserDefaults.standard.string(forKey: "i18n_language")

        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        
        guard let path = path else {
            return NSLocalizedString(self, comment: "")
        }
        
        let bundle = Bundle(path: path)

        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
}
 

// We automatically conform to UITableViewDelegate because we are using UITableViewController
class ExperimentProfileMasterViewController: UITableViewController {
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var languageSwitch: UISegmentedControl!
    
    weak var delegate: MasterViewControllerDelegate?
    
    private var canStart = true
    private var currentIndexPath = IndexPath(row: 0, section: 0)
    
    private let appLanguage = AppLanguage.shared
    
    @IBAction func languageSwitch(_ sender: UISegmentedControl) {
        switch (sender).selectedSegmentIndex {
        case 0:
            appLanguage.setLanguage(.English)
        case 1:
            appLanguage.setLanguage(.Malay)
        case 2:
            appLanguage.setLanguage(.Chinese)
        default:
            break
        }
    }
    
    
    @IBOutlet weak var patientIdTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("ExperimentProfileMasterViewController :: viewDidLoad")
        
        splitViewController?.preferredDisplayMode = .oneBesideSecondary // To display both master and detail views together
        splitViewController?.presentsWithGesture = false // To prevent users from showing/hiding master view
        
        ageTextField.delegate = self
        patientIdTextField.delegate = self
        
        // To handle tap events, specifically hide keyboard on tap.
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.cancelsTouchesInView = false
        splitViewController?.view.addGestureRecognizer(tap)
        
        // To assign self to be the delegate of DetailViewController (To update Master from Detail).
        guard let rightNavController = splitViewController?.viewControllers.last as? UINavigationController else {
            fatalError("ExperimentProfileMasterViewController :: Downcasting Error")
        }
        
        let detailViewController = rightNavController.viewControllers.first as? ExperimentProfileDetailViewController
        detailViewController?.delegate = self
        
        let alert = UIAlertController(
            title: "Experiment Details",
            message: "For trial, please select 'Trial' under Experiment Type.\n\nOtherwise, please select 'Test' and fill up all the required information.",
            preferredStyle: .alert
        )
        self.displayAlert(
            alert,
            actions: [
                UIAlertAction(title: "Dismiss", style: .cancel, handler: { action in
                    DispatchQueue.main.async { alert.dismiss(animated: true, completion: nil) }
                })
            ]
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let currentLanguage = appLanguage.getCurrentLanguage()
        
        switch currentLanguage {
        case "en":
            languageSwitch.selectedSegmentIndex = 0
        case "ms":
            languageSwitch.selectedSegmentIndex = 1
        case "zh-Hans":
            languageSwitch.selectedSegmentIndex = 2
        default:
            print("User language is neither English, Malay nor Chinese!")
            print(currentLanguage)
        }
        
        
        print("ExperimentProfileMasterViewController :: viewWillAppear")
        // Experiment.shared = Experiment()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // To select section 0, row 0 automatically
        tableView.selectRow(at: currentIndexPath, animated: false, scrollPosition: .none)
        tableView.delegate?.tableView?(tableView, didSelectRowAt: currentIndexPath)
    }
    
    @IBAction func genderValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            Experiment.shared.gender = .Male
        } else {
            Experiment.shared.gender = .Female
        }
    }
    
    private func displayAlert(_ alert: UIAlertController, actions: [UIAlertAction], autoDismissalTime: DispatchTimeInterval? = nil) {
        for action in actions {
            alert.addAction(action)
        }
        
        self.present(alert, animated: true, completion: nil)
        
        if let dismissalTime = autoDismissalTime {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + dismissalTime) {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
}

// MARK: - UITableViewController Implementation
extension ExperimentProfileMasterViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Edittd (1 : 3 -> 2: 5): Added two new section: Language, Patient ID and View Result
        return Experiment.shared.experimentType == .Trial ? 2 : 8
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentIndexPath = indexPath
        
        print("Selected section \(indexPath.section), row \(indexPath.row)")
        
        guard let cell = tableView.cellForRow(at: indexPath) else {
            fatalError("ExperimentProfileMasterViewController :: Unable to retrieve tableViewCell from indexPath")
        }
        
        // Inform DetailViewController that a cell has been selected
        if let identifier = cell.reuseIdentifier {
            let options = K.ExperimentProfile.Master.questions[identifier]
            delegate?.masterViewController(self, didSelectQuestion: identifier, optionsForQuestion: options)
        }
    }
}

extension ExperimentProfileMasterViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == ageTextField {
            textField.keyboardType = .numberPad
            return true
        } else {
            return true
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == ageTextField {
            // if backspace is pressed, return true
            if string == "" {
                return true
            }
            
            // return true if number is provided and if the length of the text is less than three (0 - 999)
            if let _ = string.rangeOfCharacter(from: .decimalDigits), let text = textField.text {
                return text.count < 3
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

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if textField == ageTextField {
            if let age = textField.text {
                Experiment.shared.age = Int(age)
            }
        }
        
        if textField == patientIdTextField {
            if let patientId = textField.text {
                Experiment.shared.patientId = patientId
            }
        }
    }

    @objc func handleTap() {
        ageTextField.resignFirstResponder() // Dismiss keyboard
        patientIdTextField.resignFirstResponder()
    }
}

// MARK: - DetailViewControllerDelegate Implementations
extension ExperimentProfileMasterViewController: DetailViewControllerDelegate {
    func detailViewController(_ detailViewController: ExperimentProfileDetailViewController, selectedQuestion question: String, didSelectOption option: String) {
        print("ExperimentProfileMasterViewController :: Question : \(question) | Option Selected: \(option)")
        
        if question == K.ExperimentProfile.experimentType {
            print("Experiment Type!")
            
            DispatchQueue.main.async { // Reload data must be done in main thread
                self.tableView.reloadData()
                self.tableView.selectRow(at: self.currentIndexPath, animated: false, scrollPosition: .none)
            }
        }
        
        if let cell = tableView.cellForRow(at: currentIndexPath) {
            let tableViewLabels = cell.contentView.subviews // Views of a Table View Cell, e.g., [UILabel("ExperimentType"), UILabel("Trial")]
            if tableViewLabels.count >= 2 {
                let detailLabel = tableViewLabels[1] as! UILabel // Get the second element because that is the label to display the chosen option
                detailLabel.text = option
            }
            
        }
    }
    
    func detailViewController(_ detailViewController: ExperimentProfileDetailViewController, didPressStartButton: UIButton) {
        print("startButtonPressed")
        
        canStart = true
        
        for section in 0 ..< tableView.numberOfSections {
            for row in 0 ..< tableView.numberOfRows(inSection: section) {
                let cell = tableView.cellForRow(at: IndexPath(row: row, section: section))
                
                if let identifier = cell?.reuseIdentifier, let value = Experiment.shared[identifier] {
                    
                    guard Experiment.shared.experimentType != nil else {
                        let alert = UIAlertController(
                            title: "Experiment Type",
                            message: "Please select your experiment type.\n\nFor trial, please select 'Trial'. Otherwise, please select 'Test' and fill up all the required information.",
                            preferredStyle: .alert
                        )
                        self.displayAlert(
                            alert,
                            actions: [
                                UIAlertAction(title: "Dismiss", style: .cancel, handler: { action in
                                    DispatchQueue.main.async { alert.dismiss(animated: true, completion: nil) }
                                })
                            ]
                        )
                        
                        cell?.backgroundColor = UIColor(named: "Light Red")
                        canStart = false
                        return
                    }
                    
                    switch identifier {
                    case K.ExperimentProfile.age, K.ExperimentProfile.gender, K.ExperimentProfile.educationLevel, K.ExperimentProfile.ethnicity, K.ExperimentProfile.annualIncome, K.ExperimentProfile.patientId:
                        if Experiment.shared.experimentType == .Test {
                            if value is NSNull {
                                cell?.backgroundColor = UIColor(named: "Light Red")
                                canStart = false
                            } else {
                                cell?.backgroundColor = .white
                            }
                        } else {
                            cell?.backgroundColor = .white
                        }
                        break
                    default:
                        cell?.backgroundColor = .white
                        break
                    }
                }
            }
        }

        if canStart { 
            let alert = UIAlertController(
                title: "Experiment Details",
                message: "Please confirm your experiment details below.\n\n\(Experiment.shared.toString())",
                preferredStyle: .alert
            )
            self.displayAlert(
                alert,
                actions: [
                    UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                        DispatchQueue.main.async { alert.dismiss(animated: true, completion: nil) }
                    }),
                    UIAlertAction(title: "Begin", style: .default, handler: { action in
                        self.performSegue(withIdentifier: K.goToTestSelectionSegue, sender: self)
                    })
                ]
            )
        } else {
            let alert = UIAlertController(
                title: "Insufficient Information",
                message: "Please fill up all the required information to begin the experiment.",
                preferredStyle: .alert
            )
            self.displayAlert(
                alert,
                actions: [
                    UIAlertAction(title: "Dismiss", style: .cancel, handler: { action in
                        DispatchQueue.main.async { alert.dismiss(animated: true, completion: nil) }
                    })
                ],
                autoDismissalTime: .milliseconds(2000)
            )
        }
    }
}
