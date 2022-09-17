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
    }
    
    func getCurrentLanguage() -> String? {
        return UserDefaults.standard.string(forKey: "i18n_language")
    }
    
    /// Override the global setting for app language.
    /// It takes effect in the next view or after view is re-rendered.
    func setLanguage(_ language: SupportList) {
        switch language {
        case .English:
            UserDefaults.standard.set("en", forKey: "i18n_language")
            print("User selected English as the app language! ")
        case .Malay:
            UserDefaults.standard.set("ml", forKey: "i18n_language")
            print("User selected Malay as the app language! ")
        }
    }
    
    /// Return to the initial view of main storyboard to re-render all UI.
    func rerenderUI() {
        LanguageManager.shared.setLanguage(language: .en) { title -> UIViewController in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            return storyboard.instantiateInitialViewController()!
        } animation: { view in
            view.transform = CGAffineTransform(scaleX: 2, y: 2)
            view.alpha = 0
        }
    }
}
