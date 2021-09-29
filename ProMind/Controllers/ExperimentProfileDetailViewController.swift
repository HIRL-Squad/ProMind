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
    func detailViewController(_ detailViewController: ExperimentProfileDetailViewController, selectedQuestion question: String, didSelectOption option: String)
    
    /// To update MasterViewController TableView after when startButton is pressed.
    /// - Parameters:
    ///     - detailViewController: The DetailViewController instance that invokes this method.
    ///     - didPressStartButton: The start button that was pressed.
    func detailViewController(_ detailViewController: ExperimentProfileDetailViewController, didPressStartButton: UIButton)
}

class ExperimentProfileDetailViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    
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
            fatalError("ExperimentProfileDetailViewController :: Downcasting Error")
        }
        
        // To assign self to be the delegate of MasterViewController (To update Detail from Master)
        let masterViewController = leftNavController.viewControllers.first as? ExperimentProfileMasterViewController
        masterViewController?.delegate = self
    }
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        delegate?.detailViewController(self, didPressStartButton: sender)
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
        // textField.autocorrectionType = .no
        textField.backgroundColor = .white
        textField.layer.borderWidth = K.borderWidthThin
        textField.layer.borderColor = UIColor.black.cgColor
        
        views.append(textField)
        return textField
    }
    
    private func activateConstraints(view: UIView, constraints: [NSLayoutConstraint]) {
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - MasterViewControllerDelegate Implementations
extension ExperimentProfileDetailViewController: MasterViewControllerDelegate {
    func masterViewController(_ masterViewController: ExperimentProfileMasterViewController, didSelectQuestion question: String, optionsForQuestion options: [String]?) {
        self.currentQuestion = question
        print("didSelectQuestion: \(question)")
        
        // Reset all views
        resetContainerView()
        
        switch question {
        case K.ExperimentProfile.remarks:
            let label = initUILabel(text: "Remarks (Maximum 80 characters)")
            containerView.addSubview(label)
            activateConstraints(view: label, constraints: [
                NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 32),
                NSLayoutConstraint(item: label, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1.0, constant: -32),
                NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1.0, constant: 32)
            ])
            
            let textField = initUITextField(placeholder: K.ExperimentProfile.Detail.remarksPlaceholder, text: Experiment.shared.remarks)
            containerView.addSubview(textField)
            activateConstraints(view: textField, constraints: [
                NSLayoutConstraint(item: textField, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 32),
                NSLayoutConstraint(item: textField, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1.0, constant: -32),
                NSLayoutConstraint(item: textField, attribute: .top, relatedBy: .equal, toItem: label, attribute: .bottom, multiplier: 1.0, constant: 16),
            ])
            
            break
        default: // Table View
            setupTableView(allowsMultipleSelection: false)
            currentOptions = options
            DispatchQueue.main.async { // Reload data must be done in main thread
                self.optionChoiceTableView?.reloadData() 
            }
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate Implementations
extension ExperimentProfileDetailViewController: UITableViewDataSource, UITableViewDelegate {
    static let optionChoiceCellIdentifier = "optionChoiceCell"
    
    private func setupTableView(allowsMultipleSelection: Bool) {
        optionChoiceTableView = UITableView(frame: containerView.bounds, style: .insetGrouped)
        optionChoiceTableView?.allowsMultipleSelection = allowsMultipleSelection
        containerView.addSubview(optionChoiceTableView!)
        
        optionChoiceTableView!.register(UITableViewCell.self, forCellReuseIdentifier: ExperimentProfileDetailViewController.optionChoiceCellIdentifier)
        optionChoiceTableView!.delegate = self
        optionChoiceTableView!.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? K.ExperimentProfile.Detail.sectionTitles[currentQuestion ?? ""] : ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentOptions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // print("SubjectProfileDetailViewController :: cellForRowAt :: indexPath: \(indexPath) | currentQuestion: \(currentQuestion ?? "No Question Provided")")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.optionChoiceCellIdentifier, for: indexPath)
        cell.textLabel?.text = currentOptions?[indexPath.row]
        
        guard let question = currentQuestion else { fatalError("didSelectRowAt :: Error: No question was selected.") }
        
        // To update accessoryView of a tableViewCell for a given tableView
        if Experiment.shared[question] as? String == currentOptions?[indexPath.row] {
            cell.accessoryType = .checkmark
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        
        return cell
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // To reset all pre-selected rows (so, there is no need to implement didDeselectOption).
        for section in 0 ..< tableView.numberOfSections {
            for row in 0 ..< tableView.numberOfRows(inSection: section) {
                let cell = tableView.cellForRow(at: IndexPath(row: row, section: section))
                cell?.accessoryType = .none
            }
        }
        
        guard let question = currentQuestion, let selectedOption = currentOptions?[indexPath.row] else { fatalError("didSelectRowAt :: Error: No option was selected.") }
        
//        print("ExperimentProfileDetailViewController :: IndexPath: \(indexPath)")
//        print("ExperimentProfileDetailViewController :: Question: \(question)")
//        print("ExperimentProfileDetailViewController :: Option Selected: \(selectedOption)")
    
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark // To update accessoryView of the selected tableViewCell.
        Experiment.shared[question] = selectedOption as AnyObject? // To set the value
        delegate?.detailViewController(self, selectedQuestion: question, didSelectOption: selectedOption)
    }
}

// MARK: - UITextFieldDelegate Implementation
extension ExperimentProfileDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Dismiss keyboard
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return textField.text?.count ?? 0 <= 50
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.keyboardType = .alphabet
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        switch textField.placeholder {
        case K.ExperimentProfile.Detail.remarksPlaceholder:
            Experiment.shared.remarks = textField.text
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
