//
//  SubjectOptionViewController.swift
//  ProMind
//
//  Created by Tan Wee Keat on 26/8/21.
//

import UIKit
import Speech

class InitialViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check Speech Permission
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    // Good to go
                    print("SFSpeechRecognizer :: Authorised!")
                    
                    AVAudioSession.sharedInstance().requestRecordPermission { granted in
                        if granted {
                            print("AVAudioSession :: Granted!")
                            
                            // TODO: Update time to 5 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                self.performSegue(withIdentifier: K.goToExperimentProfileSegue, sender: self)
                            }
                            
                        } else {
                            self.handlePermissionFailed(title: "This app must have access to microphone to work.", msg: "Denied")
                        }
                    }
                    
                    break
                case .denied:
                    // User said no
                    print("SFSpeechRecognizer :: User denied access to speech recognition!")
                    self.handlePermissionFailed(title: "This app must have access to speech recognition to work.", msg: "Denied")
                    break
                case .restricted:
                    // Device is not permitted
                    print("SFSpeechRecognizer :: Speech recognition restricted on this device!")
                    self.handlePermissionFailed(title: "This app must have access to speech recognition to work.", msg: "Restricted")
                    break
                case .notDetermined:
                    // Don't know yet
                    print("SFSpeechRecognizer :: Speech recognition not yet authorised!")
                    self.handlePermissionFailed(title: "This app must have access to speech recognition to work.", msg: "Not Determined")
                    break
                default:
                    print("SFSpeechRecognizer :: Something went wrong while requesting authorisation for speech recognition!")
                    self.handlePermissionFailed(title: "This app must have access to speech recognition to work.", msg: "Unknown")
                }
            }
        }
    }
    
    private func handlePermissionFailed(title: String, msg: String) {
        // Present an alert asking the user to change their settings.
        let ac = UIAlertController(
            title: title,
            message: "Code: \(msg)\n\nPlease consider updating your speech recognition and microphone settings.",
            preferredStyle: .alert
        )
        ac.addAction(UIAlertAction(title: "Open settings", style: .default) { _ in
            let url = URL(string: UIApplication.openSettingsURLString)!
            UIApplication.shared.open(url)
        })
        ac.addAction(UIAlertAction(title: "Close", style: .cancel))
        
        DispatchQueue.main.async {
            self.present(ac, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let splitViewController = segue.destination as? UISplitViewController,
              let leftNavController = splitViewController.viewControllers.first as? UINavigationController,
              let _ = leftNavController.viewControllers.first as? ExperimentProfileMasterViewController else {
            fatalError("InitialScreenViewController: Errors occurred while downcasting to SubjectProfileMasterViewController.")
        }
    }
}
