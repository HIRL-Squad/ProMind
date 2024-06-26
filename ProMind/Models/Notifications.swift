//
//  Notifications.swift
//  ProMind
//
//  Created by HAIKUO YU on 21/5/22.
//

import Foundation

protocol NotificationBroadcastDelegate {
    func post(_ name: String, object: Any?)
    func addObserver<NotificationName>(_ observer: Any, _ selector: Selector, _ name: NotificationName, object: Any?)
    func removeObserver<NotificationName>(_ observer: Any, _ name: NotificationName, object: Any?)
    func removeAllObserverFrom(_ observer: Any)
}

class NotificationBroadcast: NotificationBroadcastDelegate {
    
    func post(_ name: String, object: Any?) {
        let notificationName = Notification.Name(rawValue: name)
        NotificationCenter.default.post(name: notificationName, object: object)
    }
    
    func addObserver<NotificationName>(_ observer: Any, _ selector: Selector, _ name: NotificationName, object: Any?) {
        switch name {
        case _ where name is String:
            let notificationName = Notification.Name(rawValue: name as! String)
            NotificationCenter.default.addObserver(observer, selector: selector, name: notificationName, object: object)
        case _ where name is Notification.Name:
            let notificationName = name as! Notification.Name
            NotificationCenter.default.addObserver(observer, selector: selector, name: notificationName, object: object)
        default:
            print("Notification Type Error! ")
        }
        
    }
    
    func removeObserver<NotificationName>(_ observer: Any, _ name: NotificationName, object: Any?) {
        switch name {
        case _ where name is String:
            let notificationName = Notification.Name(rawValue: name as! String)
            NotificationCenter.default.removeObserver(observer, name: notificationName, object: object)
        case _ where name is Notification.Name:
            let notificationName = name as! Notification.Name
            NotificationCenter.default.removeObserver(observer, name: notificationName, object: object)
        default:
            print("Notification Type Error! ")
        }
    }
    
    func removeAllObserverFrom(_ observer: Any) {
        NotificationCenter.default.removeObserver(observer)
    }
}
