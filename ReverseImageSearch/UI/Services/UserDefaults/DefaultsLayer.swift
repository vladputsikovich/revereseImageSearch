//
//  DefaultsLayer.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 26.06.23.
//

import Foundation

enum DefaultsProperty {
    case wasOpened(Bool)
    case isSubscribted(Bool)
    case successSearch(Bool)
    case nextRateDate(String)
    case rateUsShowed(Bool)
    case notificationAccess(Bool)
    case notificationShowed(Bool)
    case willSendNotificationAlertShowed(Bool)
    case defaultSearchEngine(Int)
    case imageShrinkSize(Int)
    case imageQuality(Int)
    case imageEditor(Bool)
    case countFreeSearch(Int)
    case countNoRateUs(Int)
}

enum DefaultsPropertyKey {
    static let wasOpened = "WasOpened"
    static let isSubscribted = "IsSubscripted"
    static let successSearch = "SuccessSearch"
    static let nextRateDate = "NextRateDate"
    static let rateUsShowed = "RateUsShowed"
    static let notificationAccess = "NotificationAccess"
    static let notificationShowed = "NotificationShowed"
    static let willSendNotificationAlertShowed = "WillSendNotificationAlertShowed"

    static let defaultSearchEngine = "DefaultSearchEngine"
    static let imageShrinkSize = "ImageShrinkSize"
    static let imageQuality = "ImageQuality"
    static let imageEditor = "ImageEditor"
    static let countFreeSearch = "CountFreeSearch"
    static let countNoRateUs = "CountNoRateUs"
}

protocol DefaultsProtocol: AnyObject {
    var wasOpened: Bool? { get }

    var isSubscribted: Bool { get }

    var successSearch: Bool { get }

    var nextRateDate: String? { get }

    var rateUsShowed: Bool { get }

    var notificationAccess: Bool { get }

    var notificationShowed: Bool { get }

    var willSendNotificationAlertShowed: Bool { get }

    var defaultSearchEngine: Int { get }

    var imageShrinkSize: Int { get }

    var imageQuality: Int { get }

    var imageEditor: Bool { get }

    var countFreeSearch: Int { get }
    
    var countNoRateUs: Int { get }

    func set(_ property: DefaultsProperty)
}

final class DefaultsLayer: DefaultsProtocol {

    var wasOpened: Bool? {
        UserDefaults.standard.bool(forKey: DefaultsPropertyKey.wasOpened)
    }

    var isSubscribted: Bool {
        UserDefaults.standard.bool(forKey: DefaultsPropertyKey.isSubscribted)
    }

    var successSearch: Bool {
        UserDefaults.standard.bool(forKey: DefaultsPropertyKey.successSearch)
    }

    var rateUsShowed: Bool {
        UserDefaults.standard.bool(forKey: DefaultsPropertyKey.rateUsShowed)
    }

    var nextRateDate: String? {
        UserDefaults.standard.string(forKey: DefaultsPropertyKey.nextRateDate)
    }
    var notificationAccess: Bool {
        UserDefaults.standard.bool(forKey: DefaultsPropertyKey.notificationAccess)
    }

    var notificationShowed: Bool {
        UserDefaults.standard.bool(forKey: DefaultsPropertyKey.notificationShowed)
    }

    var willSendNotificationAlertShowed: Bool {
        UserDefaults.standard.bool(forKey: DefaultsPropertyKey.willSendNotificationAlertShowed)
    }

    var defaultSearchEngine: Int {
        UserDefaults.standard.integer(forKey: DefaultsPropertyKey.defaultSearchEngine)
    }

    var imageShrinkSize: Int {
        UserDefaults.standard.integer(forKey: DefaultsPropertyKey.imageShrinkSize)
    }

    var imageQuality: Int {
        UserDefaults.standard.integer(forKey: DefaultsPropertyKey.imageQuality)
    }

    var imageEditor: Bool {
        UserDefaults.standard.bool(forKey: DefaultsPropertyKey.imageEditor)
    }

    var countFreeSearch: Int {
        UserDefaults.standard.integer(forKey: DefaultsPropertyKey.countFreeSearch)
    }
    
    var countNoRateUs: Int {
        UserDefaults.standard.integer(forKey: DefaultsPropertyKey.countNoRateUs)
    }

    func set(_ property: DefaultsProperty) {
        switch property {
        case .wasOpened(let bool):
            UserDefaults.standard.set(bool, forKey: DefaultsPropertyKey.wasOpened)
        case .isSubscribted(let bool):
            UserDefaults.standard.set(bool, forKey: DefaultsPropertyKey.isSubscribted)
        case .successSearch(let bool):
            UserDefaults.standard.set(bool, forKey: DefaultsPropertyKey.successSearch)
        case .nextRateDate(let value):
            UserDefaults.standard.set(value, forKey: DefaultsPropertyKey.nextRateDate)
        case .rateUsShowed(let bool):
            UserDefaults.standard.set(bool, forKey: DefaultsPropertyKey.rateUsShowed)
        case .notificationAccess(let bool):
            UserDefaults.standard.set(bool, forKey: DefaultsPropertyKey.notificationAccess)
        case .notificationShowed(let bool):
            UserDefaults.standard.set(bool, forKey: DefaultsPropertyKey.notificationShowed)
        case .willSendNotificationAlertShowed(let bool):
            UserDefaults.standard.set(bool, forKey: DefaultsPropertyKey.willSendNotificationAlertShowed)
        case .defaultSearchEngine(let number):
            UserDefaults.standard.set(number, forKey: DefaultsPropertyKey.defaultSearchEngine)
        case .imageShrinkSize(let number):
            UserDefaults.standard.set(number, forKey: DefaultsPropertyKey.imageShrinkSize)
        case .imageQuality(let number):
            UserDefaults.standard.set(number, forKey: DefaultsPropertyKey.imageQuality)
        case .imageEditor(let bool):
            UserDefaults.standard.set(bool, forKey: DefaultsPropertyKey.imageEditor)
        case .countFreeSearch(let number):
            UserDefaults.standard.set(number, forKey: DefaultsPropertyKey.countFreeSearch)
        case .countNoRateUs(let number):
            UserDefaults.standard.set(number, forKey: DefaultsPropertyKey.countNoRateUs)
        }
    }
}

