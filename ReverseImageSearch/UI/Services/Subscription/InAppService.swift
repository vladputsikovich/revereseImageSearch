//
//  InAppService.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 31.05.23.
//

import Foundation
import StoreKit
import SwiftyStoreKit

enum AppStoreProducts: String, CaseIterable, Decodable {
    case weekSubs = "com.webrain.imagesearch.week"
    case monthSubs = "com.webrain.imagesearch.month"
    case yearSubs = "com.webrain.imagesearch.year"
    case weekTrialSubs = "com.webrain.imagesearch.weekTrial"
    case monthTrialSubs = "com.webrain.imagesearch.monthTrial"
    case yearTrialSubs = "com.webrain.imagesearch.yearTrial"
    static var allCasesSet: Set<String> {
        return Set(AppStoreProducts.allCases.map({ $0.rawValue }))
    }
    init?(product: SKProduct) {
        guard let appStoreProduct = AppStoreProducts.init(rawValue: product.productIdentifier) else { return nil }
        self = appStoreProduct
    }
}

enum SubsState {
    case unknown
    case isSubscript
    case noSubscript
}

class InAppService {

    static let shared = InAppService()
    private let validator = InAppValidationService()
    var productsValues = [AppStoreProducts: SKProduct]()

    private let defaults = DefaultsLayer()

    private init() {
        fetchProducts()
    }

    func validate(complitionHandler: @escaping (SubsState) -> ()) {
        if let validationDate = validator.validationDate, validationDate > Date() {
            complitionHandler(.isSubscript)
            defaults.set(.isSubscribted(true))
        } else {
            defaults.set(.isSubscribted(false))
        }
        SwiftyStoreKit.completeTransactions() { [weak self] purchases in
            guard let self else { return }
            purchases.forEach({
                if $0.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction($0.transaction)
                }
            })
            let activePurchases = purchases
                .filter({
                    $0.transaction.transactionState == .purchased || $0.transaction.transactionState == .restored
                })
            guard !activePurchases.isEmpty else {
                complitionHandler(.unknown)
                return
            }
            self.validator.validate { success, _ in
                if success {
                    complitionHandler(.isSubscript)
                    NotificationCenter.default.post(
                        name: NSNotification.Name("com.user.isSubscribed"),
                        object: nil
                    )

                } else {
                    complitionHandler(.noSubscript)
                    self.defaults.set(.isSubscribted(false))
                }
            }
        }
        validator.validate { [weak self] success, _ in
            guard let self else { return }
            if success {
                complitionHandler(.isSubscript)
                NotificationCenter.default.post(
                    name: NSNotification.Name("com.user.isSubscribed"),
                    object: nil
                )
                self.defaults.set(.isSubscribted(true))
            } else {
                complitionHandler(.noSubscript)
                self.defaults.set(.isSubscribted(false))
            }
        }
    }

    private func fetchProducts() {
        SwiftyStoreKit.retrieveProductsInfo(AppStoreProducts.allCasesSet) { [weak self] result in
            guard let self else { return }
            result.retrievedProducts.forEach({
                guard let product = AppStoreProducts(product: $0) else { return }
                self.productsValues[product] = $0
            })
        }
    }

    func getProductInfo(_ product: AppStoreProducts, completion: @escaping (SKProduct?) -> Void) {
        if let product = productsValues[product] {
            completion(product)
            return
        }
        SwiftyStoreKit.retrieveProductsInfo([product.rawValue]) { result in
            if let product = result.retrievedProducts.first {
                completion(product)
                return
            } else if let invalidProductId = result.invalidProductIDs.first {
                NSLog("Invalid product identifier: \(invalidProductId)")
            } else if let error = result.error {
                NSLog("Error: \(error)")
            }
            completion(nil)
        }
    }

    func subscribe(product: AppStoreProducts,
                   onInAppDisappear: (() -> Void)?,
                   onSubscription: (() -> Void)?,
                   onError: ((InAppError?) -> Void)?) {
        SwiftyStoreKit.purchaseProduct(product.rawValue, atomically: false) { [weak self] result in
            guard let self else { return }
            onInAppDisappear?()
            switch result {
            case .success(let appStoreProduct):
                if appStoreProduct.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(appStoreProduct.transaction)
                }
                self.validator.validate(completion: { success, error in
                    if appStoreProduct.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(appStoreProduct.transaction)
                    }
                    if success {
                        self.defaults.set(.isSubscribted(true))
                        onSubscription?()
                    } else {
                        onError?(error)
                    }
                })
                print("Purchase Success: \(appStoreProduct.productId)")
            case .error(let error):
                switch error.code {
                case .unknown: NSLog("Unknown error. Please contact support")
                case .clientInvalid: NSLog("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: NSLog("The purchase identifier was invalid")
                case .paymentNotAllowed: NSLog("The device is not allowed to make the payment")
                case .storeProductNotAvailable: NSLog("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: NSLog("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: NSLog("Could not connect to the network")
                case .cloudServiceRevoked: NSLog("User has revoked permission to use this cloud service")
                default: NSLog((error as NSError).localizedDescription)
                }

                if error.code == .paymentCancelled {
                    onError?(nil)
                } else {
                    onError?(.purchaseError(localizedDescription: error.localizedDescription))
                }
            }
        }
    }

    func restorePurchases(onInAppDisappear: (() -> Void)?,
                          onSubscription: (() -> Void)?,
                          onError: ((InAppError?) -> Void)?) {
        SwiftyStoreKit.restorePurchases { [weak self] results in
            guard let self else { return }
            onInAppDisappear?()
            if results.restoredPurchases.count > 0 {
                for purchase in results.restoredPurchases {
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                }
                self.validator.validate { success, error in
                    if success {
                        self.defaults.set(.isSubscribted(true))
                        onSubscription?()
                    } else {
                        onError?(error)
                    }
                }
            } else if let error = results.restoreFailedPurchases.first {
                onError?(.restoreFail(localizedDescription: error.0.localizedDescription))
            } else {
                onError?(.nothingToRestore)
            }
        }
    }
}

