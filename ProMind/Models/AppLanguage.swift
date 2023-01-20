//
//  AppLanguage.swift
//  ProMind
//
//  Created by HAIKUO YU on 20/6/22.
//

import Foundation
import LanguageManager_iOS
import UIKit

class AppLanguage {
    
    enum SupportList {
        case English
        case Malay
        case Chinese
    }
    
    private var currentLanguage: String?
    private let notification = NotificationBroadcast()
    
    private init() {
        currentLanguage = UserDefaults.standard.string(forKey: "i18n_language")
    }
    
    static let shared = AppLanguage()
    
    func getCurrentLanguage() -> String? {
        return currentLanguage
    }
    
    /// Override the global setting for app language.
    /// It takes effect in the next view or after view is re-rendered.
    func setLanguage(_ language: SupportList) {
        switch language {
        case .English:
            currentLanguage = "en"
            UserDefaults.standard.set("en", forKey: "i18n_language")
            notification.post("Update System Language", object: "en")
            print("User selected English as the app language! ")
            
        case .Malay:
            currentLanguage = "ms"
            UserDefaults.standard.set("ms", forKey: "i18n_language")
            notification.post("Update System Language", object: "ms")
            print("User selected Malay as the app language! ")
            
        case .Chinese:
            currentLanguage = "zh-Hans"
            UserDefaults.standard.set("zh-Hans", forKey: "i18n_language")
            notification.post("Update System Language", object: "zh-Hans")
            print("User selected Chinese as the app language! ")
        }
    }
    
    /// Return to the initial view of main storyboard to re-render all UI.
    func reRenderUI() {
        LanguageManager.shared.setLanguage(language: .en) { title -> UIViewController in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            return storyboard.instantiateInitialViewController()!
        } animation: { view in
            view.transform = CGAffineTransform(scaleX: 2, y: 2)
            view.alpha = 0
        }
    }
}
