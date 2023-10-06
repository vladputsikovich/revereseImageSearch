//
//  AppConfiguration.swift
//  ReverseImageSearch
//
//  Created by Tomashchik Daniil on 14.07.23.
//

import Foundation

struct AppConfiguration {
    enum Environment {
        case debug
        case testFlight
        case appStore
    }
    
    private static let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    
    private static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    static var environment: Environment {
        if isDebug {
            return .debug
        } else if isTestFlight {
            return .testFlight
        } else {
            return .appStore
        }
    }
}
