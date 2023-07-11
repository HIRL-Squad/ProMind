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
    private var isPresentingTestResultView: Bool = false
    
    private let tmtRecordCoreDataModel = TMTRecordCoreDataModel.shared
    private let dstRecordCoreDataModel = DSTRecordCoreDataModel.shared
    
    private var testResultScrollView: UIScrollView?
    private var synthesizerNotSpeakingStackView: UIStackView?
    private var voiceNotRecognizedStackView: UIStackView?
    
    private var tmtRecordTableView: UITableView?
    private var dstRecordTableView: UITableView?
    
    private var tmtRecordIndexPath: IndexPath?
    private var dstRecordIndexPath: IndexPath?
    
    private var synthesizerNotSpeakingLableView: UILabel?
    private var voiceNotRecognizedLableView: UILabel?
    private var silentModeImageView: UIImageView?
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tmtRecordCoreDataModel.fetchRecords()
        dstRecordCoreDataModel.fetchRecords()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        delegate?.detailViewController(self, didPressStartButton: sender)
    }
    
    private func resetContainerView() {
        optionChoiceTableView?.removeFromSuperview()
        optionChoiceTableView = nil
        
        tmtRecordTableView?.removeFromSuperview()
        tmtRecordTableView = nil
        
        dstRecordTableView?.removeFromSuperview()
        dstRecordTableView = nil
        
        testResultScrollView?.removeFromSuperview()
        testResultScrollView = nil
        
        synthesizerNotSpeakingStackView?.removeFromSuperview()
        synthesizerNotSpeakingStackView = nil
        
        voiceNotRecognizedStackView?.removeFromSuperview()
        voiceNotRecognizedStackView = nil
        
        synthesizerNotSpeakingLableView?.removeFromSuperview()
        synthesizerNotSpeakingLableView = nil
        
        voiceNotRecognizedLableView?.removeFromSuperview()
        voiceNotRecognizedLableView = nil
        
        silentModeImageView?.removeFromSuperview()
        silentModeImageView = nil
        
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
    
    private func setUpTestResultScrollViewConstraints() {
        testResultScrollView!.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            testResultScrollView!.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            testResultScrollView!.leftAnchor.constraint(equalTo: view.leftAnchor),
            testResultScrollView!.rightAnchor.constraint(equalTo: view.rightAnchor),
            testResultScrollView!.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setUpTMTRecordTableViewConstraints() {
        tmtRecordTableView!.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            tmtRecordTableView!.widthAnchor.constraint(equalTo: testResultScrollView!.widthAnchor),
            tmtRecordTableView!.heightAnchor.constraint(equalTo: testResultScrollView!.heightAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setUpDSTRecordTableViewConstraints() {
        dstRecordTableView!.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            dstRecordTableView!.widthAnchor.constraint(equalTo: testResultScrollView!.widthAnchor),
            dstRecordTableView!.heightAnchor.constraint(equalTo: testResultScrollView!.heightAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setUpSynthesizerNotSpeakingStackViewConstraints() {
        synthesizerNotSpeakingStackView!.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            synthesizerNotSpeakingStackView!.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            synthesizerNotSpeakingStackView!.leftAnchor.constraint(equalTo: view.leftAnchor),
            synthesizerNotSpeakingStackView!.rightAnchor.constraint(equalTo: view.rightAnchor),
            synthesizerNotSpeakingStackView!.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setUpVoiceNotRecognizedStackViewConstraints() {
        voiceNotRecognizedStackView!.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            voiceNotRecognizedStackView!.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            voiceNotRecognizedStackView!.leftAnchor.constraint(equalTo: view.leftAnchor),
            voiceNotRecognizedStackView!.rightAnchor.constraint(equalTo: view.rightAnchor),
            voiceNotRecognizedStackView!.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setUpSynthesizerNotSpeakingLableViewConstraints() {
        synthesizerNotSpeakingLableView!.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            synthesizerNotSpeakingLableView!.leadingAnchor.constraint(equalTo: synthesizerNotSpeakingStackView!.leadingAnchor, constant: 16),
            synthesizerNotSpeakingLableView!.trailingAnchor.constraint(equalTo: synthesizerNotSpeakingStackView!.trailingAnchor, constant: -16),
            synthesizerNotSpeakingLableView!.topAnchor.constraint(equalTo: synthesizerNotSpeakingStackView!.topAnchor, constant: 84),
            synthesizerNotSpeakingLableView!.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setUpVoiceNotRecognizedLabelViewConstraints() {
        voiceNotRecognizedLableView!.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            voiceNotRecognizedLableView!.leadingAnchor.constraint(equalTo: voiceNotRecognizedStackView!.leadingAnchor, constant: 16),
            voiceNotRecognizedLableView!.trailingAnchor.constraint(equalTo: voiceNotRecognizedStackView!.trailingAnchor, constant: -16),
            voiceNotRecognizedLableView!.topAnchor.constraint(equalTo: voiceNotRecognizedStackView!.topAnchor, constant: 84),
            voiceNotRecognizedLableView!.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setUpSilentModeImageViewConstraints() {
        silentModeImageView!.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            synthesizerNotSpeakingLableView!.topAnchor.constraint(equalTo: synthesizerNotSpeakingLableView!.bottomAnchor, constant: 16),
            synthesizerNotSpeakingLableView!.centerXAnchor.constraint(equalTo: synthesizerNotSpeakingStackView!.centerXAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func getTroubleShootingLabelFrame() -> CGRect {
        let size = CGSize(width: view.frame.width - 32, height: view.frame.height)
        return CGRect(origin: CGPoint(x: 16, y: 0), size: size)
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
            isPresentingTestResultView = false
            
            let label = initUILabel(text: "Occupation/Faculty/Course of Study (Maximum 80 characters)")
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
            
        case K.ExperimentProfile.trialMakingTestResults:
            isPresentingTestResultView = true
            print("Configuring TableView for displaying Trial Making Test results...")
            
            testResultScrollView = UIScrollView()
            view.addSubview(testResultScrollView!)
            setUpTestResultScrollViewConstraints()
            
            tmtRecordTableView = UITableView(frame: view.frame, style: .insetGrouped)
            tmtRecordTableView!.register(UITableViewCell.self, forCellReuseIdentifier: "testResult")
            tmtRecordTableView!.delegate = self
            tmtRecordTableView!.dataSource = self
            
            testResultScrollView!.addSubview(tmtRecordTableView!)
            setUpTMTRecordTableViewConstraints()
            
            
        case K.ExperimentProfile.digitSpanTestResults:
            isPresentingTestResultView = true
            print("Configuring TableView for displaying Digit Span Test results...")
            
            testResultScrollView = UIScrollView()
            view.addSubview(testResultScrollView!)
            setUpTestResultScrollViewConstraints()
            
            dstRecordTableView = UITableView(frame: view.frame, style: .insetGrouped)
            dstRecordTableView!.register(UITableViewCell.self, forCellReuseIdentifier: "testResult")
            dstRecordTableView!.delegate = self
            dstRecordTableView!.dataSource = self
            
            testResultScrollView!.addSubview(dstRecordTableView!)
            setUpDSTRecordTableViewConstraints()
            
        case K.ExperimentProfile.synthesizerNotSpeaking:
            isPresentingTestResultView = false
            print("Displaying synthesizer not speaking troubleshooting instructions. ")
            
            synthesizerNotSpeakingStackView = UIStackView(frame: view.frame)
            view.addSubview(synthesizerNotSpeakingStackView!)
            setUpSynthesizerNotSpeakingStackViewConstraints()
            
            synthesizerNotSpeakingLableView = UILabel(frame: getTroubleShootingLabelFrame())
            let instructions = ProMindIssueTroubleshooter(issue: .synthesizerNotSpeaking, fontSize: 18).getInstructions()
            synthesizerNotSpeakingLableView!.attributedText = instructions
            synthesizerNotSpeakingLableView!.numberOfLines = 0
            synthesizerNotSpeakingLableView!.sizeToFit()
            
            synthesizerNotSpeakingStackView!.addSubview(synthesizerNotSpeakingLableView!)
            setUpSynthesizerNotSpeakingLableViewConstraints()
            
            // silentModeImageView = UIImageView(image: UIImage(named: "No sound.jpg"))
            
            // synthesizerNotSpeakingStackView!.addSubview(silentModeImageView!)
            // setUpSilentModeImageViewConstraints()
            
        case K.ExperimentProfile.voiceNotRecognized:
            isPresentingTestResultView = false
            
            print("Displaying voice not recognized troubleshooting instructions. ")
            
            voiceNotRecognizedStackView = UIStackView()
            view.addSubview(voiceNotRecognizedStackView!)
            setUpVoiceNotRecognizedStackViewConstraints()
            
            voiceNotRecognizedLableView = UILabel(frame: getTroubleShootingLabelFrame())
            let instructions = ProMindIssueTroubleshooter(issue: .voiceNotRecognized, fontSize: 18).getInstructions()
            voiceNotRecognizedLableView!.attributedText = instructions
            voiceNotRecognizedLableView!.numberOfLines = 0
            voiceNotRecognizedLableView!.sizeToFit()
            
            voiceNotRecognizedStackView!.addSubview(voiceNotRecognizedLableView!)
            setUpVoiceNotRecognizedLabelViewConstraints()
            
            
        default: // Table View
            print("Question: \(question)")
            isPresentingTestResultView = false
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
    
    /// Section 0 - Trail Making Test
    /// Section 1 - Digit Span Test
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isPresentingTestResultView {
            switch tableView {
            case tmtRecordTableView:
                return "Trail Making Test"
            case dstRecordTableView:
                return "Digit Span Test"
            default:
                return "Error Happened"
            }
        } else {
            return section == 0 ? K.ExperimentProfile.Detail.sectionTitles[currentQuestion ?? ""] : ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isPresentingTestResultView {
            switch tableView {
            case tmtRecordTableView:
                print("TMT Record: \(tmtRecordCoreDataModel.getNumberOfRecords())")
                return tmtRecordCoreDataModel.getNumberOfRecords()
            case dstRecordTableView:
                print("DST Record: \(dstRecordCoreDataModel.getNumberOfRecords())")
                return dstRecordCoreDataModel.getNumberOfRecords()
            default:
                return 0
            }
        } else {
            return currentOptions?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isPresentingTestResultView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "testResult", for: indexPath)
            var content = cell.defaultContentConfiguration()
            
            switch tableView {
            case tmtRecordTableView:
                let date = Date(timeIntervalSince1970: TimeInterval(tmtRecordCoreDataModel.savedEntities[indexPath.row].experimentDate))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
                content.text = dateFormatter.string(from: date)
                content.secondaryText = "Patient ID: " + tmtRecordCoreDataModel.savedEntities[indexPath.row].patientId!
                
            case dstRecordTableView:
                let date = Date(timeIntervalSince1970: TimeInterval(dstRecordCoreDataModel.savedEntities[indexPath.row].experimentDate))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
                content.text = dateFormatter.string(from: date)
                content.secondaryText = "Patient ID: " + dstRecordCoreDataModel.savedEntities[indexPath.row].patientId!
                
            default:
                content.text = "Error Happened"
            }
            
            cell.contentConfiguration = content
            return cell
            
        } else {
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
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // To reset all pre-selected rows (so, there is no need to implement didDeselectOption).
        if isPresentingTestResultView {
            switch tableView {
            case tmtRecordTableView:
                tmtRecordIndexPath = indexPath
                performSegue(withIdentifier: ProMindSegues.presentTMTTestRecord.rawValue, sender: self)
            case dstRecordTableView:
                dstRecordIndexPath = indexPath
                performSegue(withIdentifier: ProMindSegues.presentDSTTestRecord.rawValue, sender: self)
            default:
                break
            }
        } else {
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

extension ExperimentProfileDetailViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case ProMindSegues.presentTMTTestRecord.rawValue:
            let navigationController = segue.destination as! UINavigationController
            let tableViewController = navigationController.topViewController as! TMTTestResultTableViewController
            tableViewController.indexPath = tmtRecordIndexPath!
        case ProMindSegues.presentDSTTestRecord.rawValue:
            let navigationController = segue.destination as! UINavigationController
            let tableViewController = navigationController.topViewController as! DSTTestResultTableViewController
            tableViewController.indexPath = dstRecordIndexPath!
        case ProMindSegues.presentVoiceNotRecognizedTroubleshootingPage.rawValue:
            break
        case ProMindSegues.presentSynthesizerNotSpeakingTroubleshootingPage.rawValue:
            break
        default:
            break
        }
    }
}
