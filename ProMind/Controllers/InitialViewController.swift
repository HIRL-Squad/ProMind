//
//  SubjectOptionViewController.swift
//  ProMind
//
//  Created by Tan Wee Keat on 26/8/21.
//

import UIKit
import Speech

class InitialViewController: UIViewController {
    
    private let notification = NotificationBroadcast()
    
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
                            
                            // TODO: Update time to 3 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                self.performSegue(withIdentifier: K.goToExperimentProfileSegue, sender: self)
                            }
                            
                        } else {
                            self.handlePermissionFailedForSpeechRecognition(title: "This app must have access to microphone to work.", msg: "Denied")
                        }
                    }
                    
                    break
                case .denied:
                    // User said no
                    print("SFSpeechRecognizer :: User denied access to speech recognition!")
                    self.handlePermissionFailedForSpeechRecognition(title: "This app must have access to speech recognition to work.", msg: "Denied")
                    break
                case .restricted:
                    // Device is not permitted
                    print("SFSpeechRecognizer :: Speech recognition restricted on this device!")
                    self.handlePermissionFailedForSpeechRecognition(title: "This app must have access to speech recognition to work.", msg: "Restricted")
                    break
                case .notDetermined:
                    // Don't know yet
                    print("SFSpeechRecognizer :: Speech recognition not yet authorised!")
                    self.handlePermissionFailedForSpeechRecognition(title: "This app must have access to speech recognition to work.", msg: "Not Determined")
                    break
                default:
                    print("SFSpeechRecognizer :: Something went wrong while requesting authorisation for speech recognition!")
                    self.handlePermissionFailedForSpeechRecognition(title: "This app must have access to speech recognition to work.", msg: "Unknown")
                }
            }
        }
        
        // Check for Internet connection.
        if NetworkMonitor.shared.isConnected {
            print("Internet :: Connected!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.performSegue(withIdentifier: K.goToExperimentProfileSegue, sender: self)
            }
            
        } else {
            print("Internet :: Not Connected!")
            presentAlertForInternet(title: "No Internet Connection", msg: "This app needs Internet access to enable speech recognition and submit test results!")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 13.0, *) {
            notification.addObserver(self, #selector(applicationDidBecomeActive), UIScene.didActivateNotification, object: nil)
        } else {
            notification.addObserver(self, #selector(applicationDidBecomeActive), UIApplication.didBecomeActiveNotification, object: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if NetworkMonitor.shared.isConnected {
            print("Internet :: Connected!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.performSegue(withIdentifier: K.goToExperimentProfileSegue, sender: self)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        notification.removeAllObserverFrom(self)
    }
    
    private func handlePermissionFailedForSpeechRecognition(title: String, msg: String) {
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
    
    private func presentAlertForInternet(title: String, msg: String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            let url = URL(string: UIApplication.openSettingsURLString)!
            UIApplication.shared.open(url)
        })
        alertController.addAction(UIAlertAction(title: "Close", style: .cancel))
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
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

// Functions will be triggered when the application active state changes.
extension InitialViewController {
    @objc private func applicationDidBecomeActive() {
        if NetworkMonitor.shared.isConnected {
            print("Internet :: Connected!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.performSegue(withIdentifier: K.goToExperimentProfileSegue, sender: self)
            }
        }
    }
}
