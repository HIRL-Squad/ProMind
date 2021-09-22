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
    func masterViewController(_ masterViewController: SubjectProfileMasterViewController, didSelectQuestion question: String, optionsForQuestion options: [String]?)
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
    @IBOutlet weak var comorbidityScoreLabel: UILabel!
    
    weak var delegate: MasterViewControllerDelegate?
    
    var enterFromLoadSubjectOption = false
    var isLoadingSubject = false
    var alertMobileNumberTextField: UITextField?
    var alertBirthDatePicker: UIDatePicker?
    
    private var isSaveButtonPressed = false
    private var canProceedToSave = true
    private var currentIndexPath: IndexPath?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("SubjectProfileMasterViewController :: viewDidLoad")
        print("isLoadingSubject: \(isLoadingSubject)")
        
        Subject.shared.delegate = self
        
        mobileNumberTextField.delegate = self
        occupationTextField.delegate = self
        
        splitViewController?.preferredDisplayMode = .oneBesideSecondary // To display both master and detail views together
        splitViewController?.presentsWithGesture = false // To prevent users from showing/hiding master view
                
        // To assign self to be the delegate of DetailViewController (To update Master from Detail).
        guard let rightNavController = splitViewController?.viewControllers.last as? UINavigationController else {
            fatalError("Errors occurred while downcasting SplitViewController (Detail).")
        }
        
        let detailViewController = rightNavController.viewControllers.first as? SubjectProfileDetailViewController
        detailViewController?.delegate = self
        
        // To handle tap events, specifically hide keyboard on tap.
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.cancelsTouchesInView = false
        splitViewController?.view.addGestureRecognizer(tap)
        // detailViewController?.containerView?.addGestureRecognizer(tap) // To fix
        
        if isLoadingSubject {
            displayLoadSubjectAlert()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("SubjectProfileMasterViewController :: viewWillAppear")
        print("enterFromLoadSubjectOption: \(enterFromLoadSubjectOption)")
        
        if !enterFromLoadSubjectOption {
            self.dismiss(animated: true, completion: nil)
        }
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
    
    @IBAction func genderValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            Subject.shared.gender = .Male
        } else {
            Subject.shared.gender = .Female
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        print("saveButtonPressed")
        
        canProceedToSave = true
        isSaveButtonPressed = true
        
        // To reset all pre-selected rows (so, there is no need to implement didDeselectOption).
        for section in 0 ..< tableView.numberOfSections {
            for row in 0 ..< tableView.numberOfRows(inSection: section) {
                let cell = tableView.cellForRow(at: IndexPath(row: row, section: section))
                
                // print("Section \(section) Row \(row): \(cell?.reuseIdentifier): \(Subject.shared[cell?.reuseIdentifier ?? ""])")
                
                if let identifier = cell?.reuseIdentifier, let value = Subject.shared[identifier] {
                     print("\(identifier): \(value)")
                    
                    if value is NSNull {
                        cell?.backgroundColor = UIColor(named: "Light Red")
                        canProceedToSave = false
                    } else {
                        cell?.backgroundColor = .white
                    }
                }
            }
        }
        
        if canProceedToSave {
            saveSubject()
            enterFromLoadSubjectOption = false // TEST
            performSegue(withIdentifier: K.goToTestSelectionSegue, sender: self)
        } else {
            displayAlert(
                title: "Insufficient Information",
                message: "Please fill up all the necessary information",
                action: UIAlertAction(title: "Dismiss", style: .cancel, handler: { action in
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                }),
                dismissalTime: .milliseconds(1500)
            )
        }
    }
    
    private func displayLoadSubjectAlert() {
        // Pop up an alert to prompt users to key in birthDate and last 4 digits of mobile number
        let alert = UIAlertController(title: "Load Subject", message: "Please enter your mobile number and select your birth date to load your personal credentials.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Load", style: .default, handler: { action in
            // Get request
            self.loadSubject()
        }))
        
        alert.addTextField { textField in
            self.alertMobileNumberTextField = textField
            textField.placeholder = "Last 4 digits of mobile number"
            textField.delegate = self
        }
        
        let datePicker = UIDatePicker(frame: CGRect(origin: CGPoint(x: 15, y: 155), size: CGSize(width: 0, height: 0)))
//            let datePicker = UIDatePicker()
        datePicker.date = Date(timeIntervalSince1970: 946684800)
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        self.alertBirthDatePicker = datePicker
        
        // Try to add constraints again later
        
        alert.view.addSubview(datePicker)
        alert.view.addConstraint(NSLayoutConstraint(item: alert.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 250))

        self.present(alert, animated: true, completion: nil)
    }
        
    private func loadSubject() {
        // If successful, load the information
        guard let textField = alertMobileNumberTextField,
              let mobileNumber = textField.text,
              let datePicker = alertBirthDatePicker else {
            print("Mobile Number or Birth Date not selected.")
            self.dismiss(animated: true, completion: nil)
            return
        }
                        
        let birthDate = Int64(datePicker.date.timeIntervalSince1970)
        let subjectId = "\(mobileNumber)@\(birthDate)"
        print("subjectId: \(subjectId)")
        
        let url = URL(string: "\(K.URL.getSubject)/\(subjectId)")
        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let response = response as? HTTPURLResponse,
                  error == nil else {
                print("Error occurred when sending a GET request: \(error?.localizedDescription ?? "Unknown Error")")
                
                DispatchQueue.main.async {
                    self.displayAlert(
                        title: "Subject Not Found",
                        message: "The subject that you are looking for does not exist. Please create a new subject instead.\nError:\n\(error?.localizedDescription ?? "Unknown Error")",
                        action: UIAlertAction(title: "Dismiss", style: .cancel, handler: { _ in
                            DispatchQueue.main.async {
                                self.dismiss(animated: true, completion: nil)
                            }
                        }),
                        dismissalTime: nil
                    )
                }
                
                return
            }
            
            guard (200 ... 299) ~= response.statusCode else {
                print("Status Code should be 2xx, but is \(response.statusCode)")
                print("Response = \(response)")
                
                DispatchQueue.main.async {
                    self.displayAlert(
                        title: "Subject Not Found",
                        message: "The subject that you are looking for does not exist. Please create a new subject instead.\nResponse:\n\(response)",
                        action: UIAlertAction(title: "Dismiss", style: .cancel, handler: { _ in
                            DispatchQueue.main.async {
                                self.dismiss(animated: true, completion: nil)
                            }
                        }),
                        dismissalTime: nil
                    )
                }
                
                return
            }
                        
            let responseString = String(data: data, encoding: .utf8)
            print("subject:\n\(responseString ?? "Unable to decode response")")
            
            do {
                let decoder = JSONDecoder()
                let subject = try decoder.decode(Subject.self, from: data)
                
                Subject.shared = subject
                
                DispatchQueue.main.async {
                    self.displayAlert(
                        title: "Subject Loaded",
                        message: "\(subject.toString())",
                        action: UIAlertAction(title: "Begin", style: .default, handler: { _ in
                            self.enterFromLoadSubjectOption = false
                            self.performSegue(withIdentifier: K.goToTestSelectionSegue, sender: self)
                        }),
                        dismissalTime: nil
                    )
                }
            } catch {
                print("Error occurred while decoding Subject")
            }


        }
            
        task.resume()
        // Else, let the user know and prompt them to return to main screen to create new subject.
    }
    
    private func displayAlert(title: String?, message: String?, action: UIAlertAction?, dismissalTime: DispatchTimeInterval?) {
        let alert: UIAlertController? = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let action = action {
            alert?.addAction(action)
        }
        
        self.present(alert!, animated: true, completion: nil)
        
        if let time = dismissalTime {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
                alert?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    private func saveSubject() {
        print("Saving Subject")
        
        let url = URL(string: K.URL.createSubject)
        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        // Set HTTP Request Header
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonBody = try encoder.encode(Subject.shared)
            print("POST Data: \n\(String(data: jsonBody, encoding: .utf8)!)")
            request.httpBody = jsonBody
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data,
                      let response = response as? HTTPURLResponse,
                      error == nil else {
                    print("Error occurred when sending a POST request: \(error?.localizedDescription ?? "Unknown Error")")
                    
                    // Possible connection error
                    // Save to cache for persistent later
                    
                    return
                }
                
                guard (200...299) ~= response.statusCode else {
                    print("Status Code should be 2xx, but is \(response.statusCode)")
                    print("Response = \(response)")
                    return
                }
                
                print("Response Code: \(response.statusCode)")
                let responseString = String(data: data, encoding: .utf8)
                print("Response String = \(responseString ?? "Unable to decode response")")
            }
            
            task.resume()
        } catch let encodingError {
            print("Unexpected error occurred while encoding: \(encodingError)")
        }
    }
    
    // MARK: - Table View
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentIndexPath = indexPath
        
        print("Selected section \(indexPath.section), row \(indexPath.row)")
        
        guard let cell = tableView.cellForRow(at: indexPath) else {
            fatalError("SubjectProfileMasterViewController :: Unable to retrieve tableViewCell from indexPath")
        }
        
        // Inform DetailViewController that a cell has been selected
        if let identifier = cell.reuseIdentifier {
            let options = K.SubjectProfile.Master.questions[identifier]
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
    
    func detailViewController(_ detailViewController: SubjectProfileDetailViewController, selectedQuestion question: String, didSelectOptions options: [String]) {
        print("SubjectProfileMasterViewController :: Options Selected: \(options)")
    }
}

// MARK: - UITextFieldDelegate Implementation
extension SubjectProfileMasterViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == mobileNumberTextField || textField == alertMobileNumberTextField {
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Constraints only apply to Mobile Number
        if textField == mobileNumberTextField || textField == alertMobileNumberTextField {
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
        alertMobileNumberTextField?.resignFirstResponder()
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
    
    func subject(_ subject: Subject, didUpdateCharlestonComorbidity charlestonComorbidity: [String]) {
        comorbidityScoreLabel.text = "\(charlestonComorbidity.count)"
    }
}
