//
//  Notifications.swift
//  ProMind
//
//  Created by HAIKUO YU on 21/5/22.
//

import Foundation

protocol NotificationBroadcastDelegate {
    func post(name: String, object: Any?)
    func addObserver(_ observer: Any, selector: Selector, name: String, object: Any?)
    func removeObserver(_ observer: Any, name: String, object: Any?)
    func removeAllObserverFrom(_ observer: Any)
}

class NotificationBroadcast: NotificationBroadcastDelegate {
    
    func post(name: String, object: Any?) {
        let notificationName = Notification.Name(rawValue: name)
        NotificationCenter.default.post(name: notificationName, object: object)
    }
    
    func addObserver(_ observer: Any, selector: Selector, name: String, object: Any?) {
        let notificationName = Notification.Name(rawValue: name)
        NotificationCenter.default.addObserver(observer, selector: selector, name: notificationName, object: object)
    }
    
    func removeObserver(_ observer: Any, name: String, object: Any?) {
        let notificationName = Notification.Name(rawValue: name)
        NotificationCenter.default.removeObserver(observer, name: notificationName, object: object)
    }
    
    func removeAllObserverFrom(_ observer: Any) {
        NotificationCenter.default.removeObserver(observer)
    }
}
