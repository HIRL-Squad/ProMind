//
//  AppDelegate.swift
//  ProMind
//
//  Created by Tan Wee Keat on 6/6/21.
//

import UIKit
import IQKeyboardManagerSwift
import Speech

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        // Check Speech Permission
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    // Good to go
                    print("SFSpeechRecognizer :: Authorised!")
                    break
                case .denied:
                    // User said no
                    print("SFSpeechRecognizer :: User denied access to speech recognition!")
                    self.handlePermissionFailed(msg: "Denied")
                    break
                case .restricted:
                    // Device is not permitted
                    print("SFSpeechRecognizer :: Speech recognition restricted on this device!")
                    self.handlePermissionFailed(msg: "Restricted")
                    break
                case .notDetermined:
                    // Don't know yet
                    print("SFSpeechRecognizer :: Speech recognition not yet authorised!")
                    self.handlePermissionFailed(msg: "Not Determined")
                    break
                default:
                    print("SFSpeechRecognizer :: Something went wrong while requesting authorisation for speech recognition!")
                    self.handlePermissionFailed(msg: "Unknown")
                }
            }
        }
        
        return true
    }
    
    private func handlePermissionFailed(msg: String) {
        // Present an alert asking the user to change their settings.
        let ac = UIAlertController(
            title: "This app must have access to speech recognition to work.",
            message: "Code: \(msg)! Please consider updating your settings.",
            preferredStyle: .alert
        )
        ac.addAction(UIAlertAction(title: "Open settings", style: .default) { _ in
            let url = URL(string: UIApplication.openSettingsURLString)!
            UIApplication.shared.open(url)
        })
        ac.addAction(UIAlertAction(title: "Close", style: .cancel))
        // present(ac, animated: true)
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

