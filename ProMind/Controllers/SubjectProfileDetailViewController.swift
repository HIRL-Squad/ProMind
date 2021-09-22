//
//  SubjectProfileViewController.swift
//  ProMind
//
//  Created by Tan Wee Keat on 27/8/21.
//

import UIKit

/**
 The delegate of SubjectProfileDetailViewController must conform to DetailViewControllerDelegate.
 */
protocol DetailViewControllerDelegate: AnyObject {
    /// To update MasterViewController after selecting an option for a given question.
    /// - Parameters:
    ///     - detailViewController: The DetailViewController instance that invokes this method.
    ///     - question: The current question being updated.
    ///     - option: The selected option for a given question.
    func detailViewController(_ detailViewController: SubjectProfileDetailViewController, selectedQuestion question: String, didSelectOption option: String)
    func detailViewController(_ detailViewController: SubjectProfileDetailViewController, selectedQuestion question: String, didSelectOptions options: [String])
}

class SubjectProfileDetailViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    
    // @IBOutlet weak var optionChoiceTableView: UITableView!
    private var optionChoiceTableView: UITableView?
    
    private var views: [UIView] = []
    
    weak var delegate: DetailViewControllerDelegate? // Who is the delegate for DetailViewController?
    
    private var currentQuestion: String?
    private var currentOptions: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // To handle tap events, specifically hide keyboard on tap.
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        tap.cancelsTouchesInView = false
        containerView.addGestureRecognizer(tap)
        
        guard let leftNavController = splitViewController?.viewControllers.first as? UINavigationController else {
            fatalError("Errors occurred while downcasting SplitViewController (Master).")
        }
        
        // To assign self to be the delegate of MasterViewController (To update Detail from Master)
        let masterViewController = leftNavController.viewControllers.first as? SubjectProfileMasterViewController
        masterViewController?.delegate = self
    }
    
    private func resetContainerView() {
        optionChoiceTableView?.removeFromSuperview()
        optionChoiceTableView = nil
        
        for v in views {
            v.removeFromSuperview()
        }
        views = []
    }
    
    private func initUILabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        
        views.append(label)
        return label
    }
    
    private func initUITextField(placeholder: String, text: String?) -> UITextFieldWithPadding {
        let textField = UITextFieldWithPadding()
        textField.delegate = self
        textField.placeholder = placeholder
        textField.text = text
        textField.autocorrectionType = .no
        textField.layer.borderWidth = K.borderWidthThin
        textField.layer.borderColor = UIColor.black.cgColor
        // textField.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
        
        views.append(textField)
        return textField
    }
    
    private func activateConstraints(view: UIView, constraints: [NSLayoutConstraint]) {
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - MasterViewControllerDelegate Implementations
extension SubjectProfileDetailViewController: MasterViewControllerDelegate {
    func masterViewController(_ masterViewController: SubjectProfileMasterViewController, didSelectQuestion question: String, optionsForQuestion options: [String]?) {
        self.currentQuestion = question
        print("didSelectQuestion: \(question)")
        
        // Reset all views
        resetContainerView()
        
        switch question {
        case K.SubjectProfile.medicationHistory:
            let label = initUILabel(text: "Current Medications/Traditional Medicines/Supplements")
            containerView.addSubview(label)
            activateConstraints(view: label, constraints: [
                NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 32),
                NSLayoutConstraint(item: label, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1.0, constant: -32),
                NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1.0, constant: 32)
            ])
            
            let textField = initUITextField(placeholder: K.SubjectProfile.Detail.medicationHistoryPlaceholder, text: Subject.shared.medicationHistory)
            containerView.addSubview(textField)
            activateConstraints(view: textField, constraints: [
                NSLayoutConstraint(item: textField, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 32),
                NSLayoutConstraint(item: textField, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1.0, constant: -32),
                NSLayoutConstraint(item: textField, attribute: .top, relatedBy: .equal, toItem: label, attribute: .bottom, multiplier: 1.0, constant: 16),
            ])
            
            break
        case K.SubjectProfile.bloodMeasurements:
            // BP1
            let label1 = initUILabel(text: "Systolic Blood Pressure (mmHg)")
            containerView.addSubview(label1)
            activateConstraints(view: label1, constraints: [
                NSLayoutConstraint(item: label1, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 32),
                NSLayoutConstraint(item: label1, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1.0, constant: -32),
                NSLayoutConstraint(item: label1, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1.0, constant: 32)
            ])
                        
            var text1: String?
            if let bp = Subject.shared.bloodPressure[0] {
                text1 = "\(bp)"
            }
            
            let textField1 = initUITextField(placeholder: K.SubjectProfile.Detail.bloodPressureSystolicPlaceholder, text: text1)
            containerView.addSubview(textField1)
            activateConstraints(view: textField1, constraints: [
                NSLayoutConstraint(item: textField1, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 32),
                NSLayoutConstraint(item: textField1, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1.0, constant: -32),
                NSLayoutConstraint(item: textField1, attribute: .top, relatedBy: .equal, toItem: label1, attribute: .bottom, multiplier: 1.0, constant: 16),
            ])
            
            // BP2
            let label2 = initUILabel(text: "Diastolic Blood Pressure (mmHg)")
            containerView.addSubview(label2)
            activateConstraints(view: label2, constraints: [
                NSLayoutConstraint(item: label2, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 32),
                NSLayoutConstraint(item: label2, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1.0, constant: -32),
                NSLayoutConstraint(item: label2, attribute: .top, relatedBy: .equal, toItem: textField1, attribute: .bottom, multiplier: 1.0, constant: 32)
            ])
            
            var text2: String?
            if let bp = Subject.shared.bloodPressure[1] {
                text2 = "\(bp)"
            }
            
            let textField2 = initUITextField(placeholder: K.SubjectProfile.Detail.bloodPressureDiastolicPlaceholder, text: text2)
            containerView.addSubview(textField2)
            activateConstraints(view: textField2, constraints: [
                NSLayoutConstraint(item: textField2, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 32),
                NSLayoutConstraint(item: textField2, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1.0, constant: -32),
                NSLayoutConstraint(item: textField2, attribute: .top, relatedBy: .equal, toItem: label2, attribute: .bottom, multiplier: 1.0, constant: 16),
            ])
            
            // BG
            let label3 = initUILabel(text: "Blood Glucose (%HbA1c)")
            containerView.addSubview(label3)
            activateConstraints(view: label3, constraints: [
                NSLayoutConstraint(item: label3, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 32),
                NSLayoutConstraint(item: label3, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1.0, constant: -32),
                NSLayoutConstraint(item: label3, attribute: .top, relatedBy: .equal, toItem: textField2, attribute: .bottom, multiplier: 1.0, constant: 32)
            ])
            
            var text3: String?
            if let bg = Subject.shared.bloodGlucose {
                text3 = "\(bg)"
            }
            
            let textField3 = initUITextField(placeholder: K.SubjectProfile.Detail.bloodGlucosePlaceholder, text: text3)
            containerView.addSubview(textField3)
            activateConstraints(view: textField3, constraints: [
                NSLayoutConstraint(item: textField3, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 32),
                NSLayoutConstraint(item: textField3, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1.0, constant: -32),
                NSLayoutConstraint(item: textField3, attribute: .top, relatedBy: .equal, toItem: label3, attribute: .bottom, multiplier: 1.0, constant: 16),
            ])
            
            // Cholesterol
            let label4 = initUILabel(text: "Cholesterol LDL (mg/dL)")
            containerView.addSubview(label4)
            activateConstraints(view: label4, constraints: [
                NSLayoutConstraint(item: label4, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 32),
                NSLayoutConstraint(item: label4, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1.0, constant: -32),
                NSLayoutConstraint(item: label4, attribute: .top, relatedBy: .equal, toItem: textField3, attribute: .bottom, multiplier: 1.0, constant: 32)
            ])
            
            var text4: String?
            if let cholesterol = Subject.shared.cholesterolLDL {
                text4 = "\(cholesterol)"
            }
            
            let textField4 = initUITextField(placeholder: K.SubjectProfile.Detail.cholesterolPlaceholder, text: text4)
            containerView.addSubview(textField4)
            activateConstraints(view: textField4, constraints: [
                NSLayoutConstraint(item: textField4, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 32),
                NSLayoutConstraint(item: textField4, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1.0, constant: -32),
                NSLayoutConstraint(item: textField4, attribute: .top, relatedBy: .equal, toItem: label4, attribute: .bottom, multiplier: 1.0, constant: 16),
            ])
            
            break
        case K.SubjectProfile.testScores:
            let label1 = initUILabel(text: "Mini-Mental State Examination (MMSE) Score")
            containerView.addSubview(label1)
            activateConstraints(view: label1, constraints: [
                NSLayoutConstraint(item: label1, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 32),
                NSLayoutConstraint(item: label1, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1.0, constant: -32),
                NSLayoutConstraint(item: label1, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1.0, constant: 32)
            ])
            
            var text1: String?
            if let mmse = Subject.shared.mmseScore {
                text1 = "\(mmse)"
            }
            
            let textField1 = initUITextField(placeholder: K.SubjectProfile.Detail.mmsePlaceholder, text: text1)
            containerView.addSubview(textField1)
            activateConstraints(view: textField1, constraints: [
                NSLayoutConstraint(item: textField1, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 32),
                NSLayoutConstraint(item: textField1, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1.0, constant: -32),
                NSLayoutConstraint(item: textField1, attribute: .top, relatedBy: .equal, toItem: label1, attribute: .bottom, multiplier: 1.0, constant: 16),
            ])
            
            let label2 = initUILabel(text: "Montreal Cognitive Assessment (MoCA) Score")
            containerView.addSubview(label2)
            activateConstraints(view: label2, constraints: [
                NSLayoutConstraint(item: label2, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 32),
                NSLayoutConstraint(item: label2, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1.0, constant: -32),
                NSLayoutConstraint(item: label2, attribute: .top, relatedBy: .equal, toItem: textField1, attribute: .bottom, multiplier: 1.0, constant: 32)
            ])
            
            var text2: String?
            if let moca = Subject.shared.mocaScore {
                text2 = "\(moca)"
            }
            
            let textField2 = initUITextField(placeholder: K.SubjectProfile.Detail.mocaPlaceholder, text: text2)
            containerView.addSubview(textField2)
            activateConstraints(view: textField2, constraints: [
                NSLayoutConstraint(item: textField2, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 32),
                NSLayoutConstraint(item: textField2, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1.0, constant: -32),
                NSLayoutConstraint(item: textField2, attribute: .top, relatedBy: .equal, toItem: label2, attribute: .bottom, multiplier: 1.0, constant: 16),
            ])
        case K.SubjectProfile.generalNote:
            let label = initUILabel(text: "Description")
            containerView.addSubview(label)
            activateConstraints(view: label, constraints: [
                NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 32),
                NSLayoutConstraint(item: label, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1.0, constant: -32),
                NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1.0, constant: 32)
            ])
            
            let textField = initUITextField(placeholder: K.SubjectProfile.Detail.generalNotePlaceHolder, text: Subject.shared.generalNote)
            containerView.addSubview(textField)
            activateConstraints(view: textField, constraints: [
                NSLayoutConstraint(item: textField, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 32),
                NSLayoutConstraint(item: textField, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1.0, constant: -32),
                NSLayoutConstraint(item: textField, attribute: .top, relatedBy: .equal, toItem: label, attribute: .bottom, multiplier: 1.0, constant: 16),
            ])
            
            break
        case K.SubjectProfile.charlestonComorbidity:
            setupTableView(allowsMultipleSelection: true)
            self.currentOptions = options
            refreshTableView()
            break
        default:
            setupTableView(allowsMultipleSelection: false)
            currentOptions = options
            refreshTableView()
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate Implementations
extension SubjectProfileDetailViewController: UITableViewDataSource, UITableViewDelegate {
    static let optionChoiceCellIdentifier = "optionChoiceCell"
    
    private func setupTableView(allowsMultipleSelection: Bool) {
        optionChoiceTableView = UITableView(frame: containerView.bounds, style: .insetGrouped)
        optionChoiceTableView?.allowsMultipleSelection = allowsMultipleSelection
        containerView.addSubview(optionChoiceTableView!)
        
        optionChoiceTableView!.register(UITableViewCell.self, forCellReuseIdentifier: SubjectProfileDetailViewController.optionChoiceCellIdentifier)
        optionChoiceTableView!.delegate = self
        optionChoiceTableView!.dataSource = self
    }
    
    private func refreshTableView() {
        // Reload data must be done in main thread
        DispatchQueue.main.async {
            self.optionChoiceTableView?.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? K.SubjectProfile.Detail.sectionTitles[currentQuestion ?? ""] : ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentOptions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // print("SubjectProfileDetailViewController :: cellForRowAt :: indexPath: \(indexPath) | currentQuestion: \(currentQuestion ?? "No Question Provided")")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.optionChoiceCellIdentifier, for: indexPath)
        cell.textLabel?.text = currentOptions?[indexPath.row]
        
        guard let question = currentQuestion else {
            fatalError("didSelectRowAt :: Error: No question was selected.")
        }
        
        if question == K.SubjectProfile.charlestonComorbidity {
            let charlestonComorbidity = Subject.shared[question] as! [String]
            for cc in charlestonComorbidity {
                if currentOptions?[indexPath.row] == cc {
                    cell.accessoryType = .checkmark
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
            }
        } else {
            // To update accessoryView of a tableViewCell for a given tableView
            if Subject.shared[currentQuestion!] as? String == currentOptions?[indexPath.row] {
                cell.accessoryType = .checkmark
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {}
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // To reset all pre-selected rows (so, there is no need to implement didDeselectOption).
        for section in 0 ..< tableView.numberOfSections {
            for row in 0 ..< tableView.numberOfRows(inSection: section) {
                let cell = tableView.cellForRow(at: IndexPath(row: row, section: section))
                cell?.accessoryType = .none
            }
        }
        
        guard let question = currentQuestion, let selectedOption = currentOptions?[indexPath.row] else {
            fatalError("didSelectRowAt :: Error: No question or option was selected.")
        }
        
//        print("SubjectProfileDetailViewController :: IndexPath: \(indexPath)")
//        print("SubjectProfileDetailViewController :: Question: \(question)")
//        print("SubjectProfileDetailViewController :: Option Selected: \(selectedOption)")
        
        if question == K.SubjectProfile.charlestonComorbidity {
            var charlestonComorbidity = Subject.shared[question] as! [String]
            charlestonComorbidity.append(selectedOption)
            Subject.shared[question] = charlestonComorbidity as AnyObject?
            
            for section in 0 ..< tableView.numberOfSections {
                for row in 0 ..< tableView.numberOfRows(inSection: section) {
                    
                    let cell = tableView.cellForRow(at: IndexPath(row: row, section: section))
                    for cc in charlestonComorbidity {
                        if cell?.textLabel?.text == cc {
                            cell?.accessoryType = .checkmark
                        }
                    }
                    
                }
            }
            
            delegate?.detailViewController(self, selectedQuestion: question, didSelectOptions: charlestonComorbidity)
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark // To update accessoryView of the selected tableViewCell.
            Subject.shared[question] = currentOptions?[indexPath.row] as AnyObject? // To set the value
            delegate?.detailViewController(self, selectedQuestion: question, didSelectOption: selectedOption)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let question = currentQuestion, let selectedOption = currentOptions?[indexPath.row] else {
            fatalError("didDeselectRowAt :: Error: No question or option was selected.")
        }
        
        if question == K.SubjectProfile.charlestonComorbidity {
            let charlestonComorbidity = Subject.shared[question] as! [String]
            let newList = charlestonComorbidity.filter { $0 != selectedOption }
            
            Subject.shared[question] = newList as AnyObject?
            
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }
    }
}

// MARK: - UITextFieldDelegate Implementation
extension SubjectProfileDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Dismiss keyboard
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField.placeholder {
        case K.SubjectProfile.Detail.bloodPressureSystolicPlaceholder,
             K.SubjectProfile.Detail.bloodPressureDiastolicPlaceholder,
             K.SubjectProfile.Detail.mmsePlaceholder,
             K.SubjectProfile.Detail.mocaPlaceholder: // Integer
            // if backspace is pressed, return true
            if string == "" {
                return true
            }
            
            // return true if number is provided and if the length of the text is less than four
            if let _ = string.rangeOfCharacter(from: .decimalDigits) {
                return true
            }
            
            return false
        case K.SubjectProfile.Detail.bloodGlucosePlaceholder,
             K.SubjectProfile.Detail.cholesterolPlaceholder: // Double
            // if backspace is pressed, return true
            if string == "" {
                return true
            }
            
            if string == "." {
                return textField.text?.filter { $0 == "." }.count == 0 // Return true if there is no "." present, else false.
            }
            
            // return true if number is provided and if the length of the text is less than four
            if let _ = string.rangeOfCharacter(from: .decimalDigits) {
                return true
            }
            
            return false
        default: // String
            return true
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField.placeholder {
        case K.SubjectProfile.Detail.bloodPressureSystolicPlaceholder, K.SubjectProfile.Detail.bloodPressureDiastolicPlaceholder,
             K.SubjectProfile.Detail.mmsePlaceholder, K.SubjectProfile.Detail.mocaPlaceholder: // Integer
            textField.keyboardType = .numberPad
            break
        case K.SubjectProfile.Detail.bloodGlucosePlaceholder, K.SubjectProfile.Detail.cholesterolPlaceholder: // Double
            textField.keyboardType = .decimalPad
            break
        default: // String
            textField.keyboardType = .asciiCapable
            break
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        switch textField.placeholder {
        case K.SubjectProfile.Detail.medicationHistoryPlaceholder:
            Subject.shared.medicationHistory = textField.text
            break
        case K.SubjectProfile.Detail.bloodPressureSystolicPlaceholder:
            if let bpText = textField.text {
                Subject.shared.bloodPressure[0] = Int(bpText)
            }
            break
        case K.SubjectProfile.Detail.bloodPressureDiastolicPlaceholder:
            if let bp = textField.text {
                Subject.shared.bloodPressure[1] = Int(bp)
            }
            break
        case K.SubjectProfile.Detail.bloodGlucosePlaceholder:
            if let bg = textField.text {
                Subject.shared.bloodGlucose = Double(bg)
            }
            break
        case K.SubjectProfile.Detail.cholesterolPlaceholder:
            if let cholesterol = textField.text {
                Subject.shared.cholesterolLDL = Double(cholesterol)
            }
            break
        case K.SubjectProfile.Detail.mmsePlaceholder:
            if let mmse = textField.text {
                Subject.shared.mmseScore = Int(mmse)
            }
            break
        case K.SubjectProfile.Detail.mocaPlaceholder:
            if let moca = textField.text {
                Subject.shared.mocaScore = Int(moca)
            }
            break
        case K.SubjectProfile.Detail.generalNotePlaceHolder:
            Subject.shared.generalNote = textField.text
            break
        default:
            break
        }
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        for v in views {
            if type(of: v) == UITextFieldWithPadding.self {
                v.resignFirstResponder()
            }
        }
    }
}
