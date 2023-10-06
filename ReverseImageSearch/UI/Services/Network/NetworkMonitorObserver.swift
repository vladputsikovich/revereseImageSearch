//
//  NetworkMonitorObserver.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 31.05.23.
//

import Foundation
import Network

protocol ServiceType {
    func start()
}

final class NetworkMonitorObserver: ServiceType {
    static let shared = NetworkMonitorObserver()
    private let monitor = NWPathMonitor()
    private(set) var isConnected: Bool = false

    init() {}

    func start() {
        // handle internet connectivity and change path for resource
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            self.isConnected = path.status == .satisfied
        }
        monitor.start(queue: DispatchQueue(label: "InternetConnectionMonitor"))
    }
}
