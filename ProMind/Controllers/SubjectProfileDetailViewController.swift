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
}

class SubjectProfileDetailViewController: UIViewController {
    @IBOutlet weak var optionChoiceTableView: UITableView!
    
    weak var delegate: DetailViewControllerDelegate? // Who is the delegate for DetailViewController?
    
    private var currentQuestion: String?
    private var currentOptions: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let leftNavController = splitViewController?.viewControllers.first as? UINavigationController else {
            fatalError("Errors occurred while downcasting SplitViewController (Master).")
        }
        
        // To assign self to be the delegate of MasterViewController (To update Detail from Master)
        let masterViewController = leftNavController.viewControllers.first as? SubjectProfileMasterViewController
        masterViewController?.delegate = self
        
        // self.optionChoices = masterViewController?.options["subjectType"]
        
        optionChoiceTableView.delegate = self
        optionChoiceTableView.dataSource = self
    }
    
    private func refreshTableView() {
        // Reload data must be done in main thread
        DispatchQueue.main.async {
            self.optionChoiceTableView.reloadData()
        }
    }
}

// MARK: - MasterViewControllerDelegate Implementations
extension SubjectProfileDetailViewController: MasterViewControllerDelegate {
    func masterViewController(_ masterViewController: SubjectProfileMasterViewController, didSelectQuestion question: String, optionsForQuestion options: [String]) {
        self.currentQuestion = question
        self.currentOptions = options
        
        refreshTableView()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate Implementations
extension SubjectProfileDetailViewController: UITableViewDataSource, UITableViewDelegate {
    static let optionChoiceCellIdentifier = "optionChoiceCell"
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return K.SubjectProfile.Detail.sectionTitles[currentQuestion ?? ""]
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentOptions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // print("SubjectProfileDetailViewController :: cellForRowAt :: indexPath: \(indexPath) | currentQuestion: \(currentQuestion ?? "No Question Provided")")

        let cell = tableView.dequeueReusableCell(withIdentifier: Self.optionChoiceCellIdentifier, for: indexPath)
        cell.textLabel?.text = currentOptions?[indexPath.row]
        
//         print("Subject.shared[\(currentQuestion)!]: \(Subject.shared[currentQuestion!])")
//         print("currentOptions?[indexPath.row]: \(currentOptions?[indexPath.row])")
        
        // To update accessoryView of a tableViewCell for a given tableView
        if Subject.shared[currentQuestion!] as? String == currentOptions?[indexPath.row] {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
//        if currentQuestion == "subjectType" && Subject.shared.subjectType == currentOptions?[indexPath.row] {
//            cell.accessoryType = .checkmark
//        } else if currentQuestion == "site" && Subject.shared.site == currentOptions?[indexPath.row] {
//            cell.accessoryType = .checkmark
//        } else {
//            cell.accessoryType = .none
//        }
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let question = currentQuestion, let selectedOption = currentOptions?[indexPath.row] else {
            fatalError("Errors occurred while selecting an option.")
        }
        
//        print("SubjectProfileDetailViewController :: IndexPath: \(indexPath)")
//        print("SubjectProfileDetailViewController :: Question: \(question)")
//        print("SubjectProfileDetailViewController :: Option Selected: \(selectedOption)")
        
        // To reset all pre-selected rows (so, there is no need to implement didDeselectOption).
        for section in 0 ..< tableView.numberOfSections {
            for row in 0 ..< tableView.numberOfRows(inSection: section) {
                let cell = tableView.cellForRow(at: IndexPath(row: row, section: section))
                cell?.accessoryType = .none
            }
        }
        
        delegate?.detailViewController(self, selectedQuestion: question, didSelectOption: selectedOption)
                
        // To update accessoryView of the selected tableViewCell.
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        
        // To set the value
//        switch currentQuestion {
//        case K.SubjectProfile.subjectType:
//            Subject.shared.subjectType = currentOptions?[indexPath.row]
//            break
//        case K.SubjectProfile.site:
//            Subject.shared.site = currentOptions?[indexPath.row]
//            break
//        default:
//            print("No matching question")
//        }
        
        // To set the value
        Subject.shared[currentQuestion!] = currentOptions?[indexPath.row] as AnyObject?
    }
}
