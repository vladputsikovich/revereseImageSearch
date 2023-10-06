//
//  SettingsCoordinator.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 22.06.23.
//

import UIKit
import Firebase
import MessageUI

fileprivate struct Constant {
    static let privacyReferURL = "https://webrain.ltd/text-reader-privacy-policy.html"
    static let termsReferURL = "https://webrain.ltd/text-reader-terms-conditions.html"
    static let appStoreRefer = "https://apps.apple.com/app/id6450782443"
    static let supportMail = "info@webrain.ltd"
    static let appStoreReviewLink = "itms-apps:itunes.apple.com/us/app/apple-store/id6450782443?mt=8&action=write-review"
}

class SettingsCoordinator: NSObject, Coordinator {
    var childCoordinators: [Coordinator] = []

    typealias VoidClosure = (() -> ())

    var onFinish: VoidClosure?
    var subscription: VoidClosure?

    private var showRateUsAlertValue = false
    private var subscriptions = "weekTrial:monthTrial:yearTrial"

    unowned let navigationController: UINavigationController

    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let settings = SettingsContoller()

        setupRemoteConfigDefaults()
        updateViewWithRCValues()
        
        settings.onFinish = { [weak self] in
            guard let self else { return }
            self.onFinish?()
        }

        settings.subscription = { [weak self] in
            guard let self else { return }
            self.subscription?()
        }

        settings.settingElementAction = { [weak self] element in
            guard let self else { return }
            if let elem = element as? OtherSettingsElement {
                switch elem {
                case .rateUs:
                    if self.showRateUsAlertValue {
                        self.showRateUsAlert()
                    } else {
                        Analytics.logEvent("rate_us_settings", parameters: ["answer": "YES"])
                        self.navigateToRate()
                    }
                case .support:
                    self.navigateToSupport()
                case .share:
                    self.navigateToShare()
                case .privacy:
                    self.navigateToPrivacy()
                case .terms:
                    self.navigateToTerms()
                }
            } else if let elem = element as? BasicSettingsElement {
                switch elem {
                case .defaultSearch:
                    self.openDefaultSearch(delegate: settings, search: Searcher.allCases[DefaultsLayer().defaultSearchEngine])
                case .imageShrinkSize:
                    print(DefaultsLayer().imageShrinkSize)
                    self.openImageShrinkSize(delegate: settings, shrink: Shrink.allCases[DefaultsLayer().imageShrinkSize])
                case .imageQuality:
                    print(DefaultsLayer().imageShrinkSize)
                    self.openImageQuality(delegate: settings, quality: Quality.allCases[DefaultsLayer().imageQuality])
                case .imageEditor:
                    print("check")
                }
            }
        }
        navigationController.pushViewController(settings, animated: true)
    }

    private func navigateToPrivacy() {
        let controller = SiteController(urlString: Constant.privacyReferURL)
        controller.onBackTapped = { [weak self] in
            guard let self else { return }
            self.navigationController.popViewController(animated: true)
        }

        navigationController.pushViewController(controller, animated: true)
    }

    private func navigateToTerms() {
        let controller = SiteController(urlString: Constant.termsReferURL)
        controller.onBackTapped = { [weak self] in
            guard let self else { return }
            self.navigationController.popViewController(animated: true)
        }

        controller.modalPresentationStyle = .fullScreen

        navigationController.pushViewController(controller, animated: true)
    }

    private func navigateToShare() {
        guard let url = URL(string: Constant.appStoreRefer) else { return }
        let items = [url]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        ac.completionWithItemsHandler =  { [weak self] activity, success, items, error in
            guard let self else { return }
        }
        navigationController.present(ac, animated: true)
    }

    private func navigateToSupport() {
        let email = Constant.supportMail
        let messageBody = getPhoneInfo()
        let emailTitle = getAppName()
        let toRecipents = ["\(email)"]
        let mc = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject(emailTitle)
        mc.setMessageBody(messageBody, isHTML: false)
        mc.setToRecipients(toRecipents)
        navigationController.present(mc, animated: true)
    }

    private func navigateToRate() {
        guard let url = URL(string: Constant.appStoreReviewLink) else { return }
        UIApplication.shared.open(url)
    }

    private func openDefaultSearch(delegate: DefaultSearchDelegate, search: Searcher) {
        let defaultSearchCoordinator = DefaultSearchCoordinator(navigationController: navigationController)
        
        childCoordinators.append(defaultSearchCoordinator)
        defaultSearchCoordinator.onFinish = { [weak self] in
            guard let self else { return }
            self.navigationController.dismiss(animated: true)
        }
        
        defaultSearchCoordinator.subscription = { [weak self] in
            guard let self else { return }
            self.subscription?()
        }

        defaultSearchCoordinator.openDefaultSearch(delegate: delegate, search: search)
    }

    private func openImageShrinkSize(delegate: ImageShrinkSizeDelegate, shrink: Shrink) {
        let imageShrinkSizeCoord = ImageShrinkSizeCoordinator(navigationController: navigationController)

        childCoordinators.append(imageShrinkSizeCoord)
        imageShrinkSizeCoord.onFinish = { [weak self] in
            guard let self else { return }
            self.navigationController.dismiss(animated: true)
        }

        imageShrinkSizeCoord.openImageShrink(delegate: delegate, shrink: shrink)
    }

    private func openImageQuality(delegate: ImageQualityDelegate, quality: Quality) {
        let imageQualityCoord = ImageQualityCoordinator(navigationController: navigationController)

        childCoordinators.append(imageQualityCoord)
        imageQualityCoord.onFinish = { [weak self] in
            guard let self else { return }
            self.navigationController.dismiss(animated: true)
        }

        imageQualityCoord.openImageQuality(delegate: delegate, quality: quality)
    }

    // MARK: Rate us alert

    private func showRateUsAlert() {
        let alert = UIAlertController(
            title: L10n.Settings.rateUs,
            message: L10n.App.rateUsInfo,
            preferredStyle: UIAlertController.Style.alert
        )
        alert.addAction(
            UIAlertAction(
                title: L10n.App.no,
                style: UIAlertAction.Style.default,
                handler: { [weak self] action in
                    guard let self = self else { return }
                    Analytics.logEvent("rate_us_settings", parameters: ["answer": "NO"])
                    self.navigateToSupport()
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: L10n.App.yes,
                style: UIAlertAction.Style.default,
                handler: { [weak self] action in
                    guard let self = self else { return }
                    Analytics.logEvent("rate_us_settings", parameters: ["answer": "YES"])
                    self.navigateToRate()
                }
            )
        )
        navigationController.present(alert, animated: true, completion: nil)
    }

    private func getPhoneInfo() -> String {
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return "" }
        let modelName = UIDevice.current.name
        let phoneVersion = UIDevice.current.systemVersion

        let info = "App version: \(appVersion)" + "\n"
                 + "Device: \(modelName)" + "\n"
                 + "OS: \(phoneVersion)"

        return info
    }

    private func getAppName() -> String {
        guard let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String else { return "" }
        return appName
    }

    // MARK: Remote config

    private func setupRemoteConfigDefaults() {
        let defaultValues = [
            "showRateUsAlert": false as NSObject,
            "settingsSubscriptions": "weekTrial:monthTrial:yearTrial" as NSObject
        ]
        RemoteConfig.remoteConfig().setDefaults(defaultValues)
    }

    private func updateViewWithRCValues() {
        showRateUsAlertValue = RemoteConfig.remoteConfig().configValue(forKey: "showRateUsAlert").boolValue
        subscriptions = RemoteConfig
            .remoteConfig()
            .configValue(forKey: "settingsSubscriptions")
            .stringValue ?? "weekTrial:monthTrial:yearTrial"
    }
}

extension SettingsCoordinator: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
