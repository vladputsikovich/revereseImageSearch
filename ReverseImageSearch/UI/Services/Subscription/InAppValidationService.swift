//
//  InAppValidationService.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 31.05.23.
//

import Foundation
import StoreKit
import SwiftyStoreKit

fileprivate struct Constant {
    static let kAppStoreSharedSecret = "1b90ee12f9a1467c9e3524409c45c473"
    static let validationDateKey = "validationDate"
}

enum InAppError {
    case restorePurchaseExpired
    case purchaseError(localizedDescription: String)
    case nothingToRestore
    case restoreFail(localizedDescription: String)
}

class InAppValidationService {

    private(set) var validationDate: Date? {
        didSet {
            saveDefaults()
        }
    }

    init() {
        loadDefaults()
    }

    func validate(completion: @escaping ((Bool, InAppError?) -> Void)) {
        #if DEBUG
        let service = AppleReceiptValidator.VerifyReceiptURLType.sandbox
        #else
        let service = AppleReceiptValidator.VerifyReceiptURLType.production
        #endif
        let appleValidator = AppleReceiptValidator(service: service, sharedSecret: Constant.kAppStoreSharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            let productsSet = AppStoreProducts.allCases.map { return $0.rawValue }
            switch result {
            case .success(let receipt):
                let purchaseResult = SwiftyStoreKit.verifySubscriptions(
                    ofType: .autoRenewable,
                    productIds: Set(productsSet),
                    inReceipt: receipt)
                switch purchaseResult {
                case .purchased(let expiryDate, let receiptItems), .inGracePeriod(let expiryDate, let receiptItems, _):
                    if expiryDate > Date() {
                        self.validationDate = expiryDate
                        completion(true, nil)
                    } else {
                        completion(false, .restorePurchaseExpired)
                    }
                case .expired(_, _):
                    completion(false, .restorePurchaseExpired)
                case .notPurchased:
                    completion(false, .nothingToRestore)
                }
            case .error(let error):
                print("Receipt verification failed: \(error)")
                completion(false, .restoreFail(localizedDescription: error.localizedDescription))
            }
        }
    }

    func saveDefaults() {
        let defaults = UserDefaults.standard
        defaults.set(validationDate, forKey: Constant.validationDateKey)
    }

    func loadDefaults() {
        let defaults = UserDefaults.standard
        if let date = defaults.value(forKey: Constant.validationDateKey) as? Date {
            validationDate = date
        }
    }
}


