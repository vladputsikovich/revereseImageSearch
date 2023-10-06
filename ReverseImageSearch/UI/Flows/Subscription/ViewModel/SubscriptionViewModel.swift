//
//  SubscriptionViewModel.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 31.05.23.
//

import UIKit
import Firebase

class SubscriptionViewModel {

    private var subscriptions: [String]

    private var isReview = true

    init(subscriptions: [String]) {
        self.subscriptions = subscriptions
        setupRemoteConfigDefaults()
        updateViewWithRCValues()
    }

    func getSubscriptionInfo() -> [SubscriptionInfo] {
        var subscriptionInfo: [SubscriptionInfo] = []

        subscriptions.forEach { subs in
            switch subs {
            case "week":
                subscriptionInfo.append(getInfo(subscription: .weekSubs))
            case "weekTrial":
                subscriptionInfo.append(getInfo(subscription: .weekTrialSubs))
            case "month":
                subscriptionInfo.append(getInfo(subscription: .monthSubs))
            case "monthTrial":
                subscriptionInfo.append(getInfo(subscription: .monthTrialSubs))
            case "year":
                subscriptionInfo.append(getInfo(subscription: .yearSubs))
            case "yearTrial":
                subscriptionInfo.append(getInfo(subscription: .yearTrialSubs))
            default:
                print("ERORO")
            }
        }
        return subscriptionInfo
    }

    private func getInfo(subscription: AppStoreProducts) -> SubscriptionInfo {
        var subsInfo: SubscriptionInfo?
        InAppService.shared.getProductInfo(subscription) { [weak self] product in
            guard let self else { return }
            switch subscription {
            case .weekSubs:
                subsInfo = SubscriptionInfo(
                    title: L10n.Subscription.popular,
                    price: product?.localizedPrice ?? "",
                    period: L10n.Subscription.week,
                    subscription: subscription
                )
            case .monthSubs:
                subsInfo = SubscriptionInfo(
                    title: L10n.Subscription.optimal,
                    price: product?.localizedPrice ?? "",
                    period: L10n.Subscription.month,
                    subscription: subscription
                )
            case .yearSubs:
                subsInfo = SubscriptionInfo(
                    title: L10n.Subscription.bestPrice,
                    price: product?.localizedPrice ?? "",
                    period: L10n.Subscription.year,
                    subscription: subscription
                )
            case .weekTrialSubs:
                subsInfo = SubscriptionInfo(
                    title: freeTrial(text: "\(self.unitName(unitRawValue: UInt(product?.introductoryPrice?.subscriptionPeriod.unit.rawValue ?? 0), count: product?.introductoryPrice?.subscriptionPeriod.numberOfUnits ?? 0))"),
                    price: product?.localizedPrice ?? "",
                    period: L10n.Subscription.week,
                    subscription: subscription
                )
            case .monthTrialSubs:
                subsInfo = SubscriptionInfo(
                    title: freeTrial(text: "\(self.unitName(unitRawValue: UInt(product?.introductoryPrice?.subscriptionPeriod.unit.rawValue ?? 0), count: product?.introductoryPrice?.subscriptionPeriod.numberOfUnits ?? 0))"),
                    price: product?.localizedPrice ?? "",
                    period: L10n.Subscription.month,
                    subscription: subscription
                )
            case .yearTrialSubs:
                subsInfo = SubscriptionInfo(
                    title: freeTrial(text: "\(self.unitName(unitRawValue: UInt(product?.introductoryPrice?.subscriptionPeriod.unit.rawValue ?? 0), count: product?.introductoryPrice?.subscriptionPeriod.numberOfUnits ?? 0))"),
                    price: product?.localizedPrice ?? "",
                    period: L10n.Subscription.year,
                    subscription: subscription
                )
            }
        }
        return subsInfo ?? SubscriptionInfo(title: "", price: "", period: "", subscription: .yearSubs)
    }

    private func freeTrial(text: String) -> String {
        return isReview ? L10n.Subscription.freeTrialReview(text) : L10n.Subscription.freeTrial(text)
    }

    private func unitName(unitRawValue: UInt, count: Int) -> String {
        switch unitRawValue {
        case 0: return L10n.Subscription.days(count)
        case 1: return L10n.Subscription.weeks(count)
        case 2: return L10n.Subscription.months(count)
        case 3: return L10n.Subscription.years(count)
        default: return ""
        }
    }

    // MARK: Remote config

    private func setupRemoteConfigDefaults() {
        let defaultValues = [
            "isReview": true as NSObject
        ]
        RemoteConfig.remoteConfig().setDefaults(defaultValues)
    }

    private func updateViewWithRCValues() {
        isReview = RemoteConfig.remoteConfig().configValue(forKey: "isReview").boolValue
    }
}

