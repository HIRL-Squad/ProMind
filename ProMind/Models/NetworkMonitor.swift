//
//  NetworkMonitor.swift
//  ProMind
//
//  Created by HAIKUO YU on 29/12/22.
//

import Foundation
import Network

final class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor
    
    public private(set) var isConnected: Bool = false
    public private(set) var connectionType: ConnectionType?
    
    enum ConnectionType {
        case wifi
        case cellular
        case wiredEthernet
        case unknown
    }
    
    private init() {
        monitor = NWPathMonitor()
    }
    
    public func startMonitoring() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
            
            self?.getConnectionType(path)
        }
    }
    
    public func stopMonitoring() {
        monitor.cancel()
    }
    
    private func getConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
            print("User is connecting to wifi. ")
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
            print("User is connecting to cellular. ")
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .wiredEthernet
            print("User is connecting to wiredEthernet. ")
        } else {
            connectionType = .unknown
            print("User is connecting to unknown Internet sources! ")
        }
    }
}
