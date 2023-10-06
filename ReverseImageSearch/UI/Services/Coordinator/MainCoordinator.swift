//
//  MainCoordinator.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 31.05.23.
//

import UIKit
import Firebase

enum TypeSubsScreen {
    case onboarding
    case app
}

fileprivate struct Constant {
    static let subsDefaultValue = "weekTrial:monthTrial:yearTrial"
}

class MainCoordinator: NSObject, Coordinator {
    var childCoordinators: [Coordinator] = []

    var onFinish: (() -> ())?

    private let defaults = DefaultsLayer()

    private var onboardingSubs = Constant.subsDefaultValue
    private var appSubs = Constant.subsDefaultValue

    unowned let navigationController: UINavigationController

    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        navigateToSplashScreen()
    }

    private func navigateToSplashScreen() {
        let splash = SplashCoordinator(navigationController: navigationController)
        childCoordinators.append(splash)
        splash.onFinish = { [weak self] in
            guard let self else { return }
            self.navigateTo()
        }
        splash.start()
    }

    private func navigateTo() {
        setupRemoteConfigDefaults()
        updateViewWithRCValues()
        guard let wasOpened = DefaultsLayer().wasOpened else {
            navigateToOnboarding()
            return
        }
        if wasOpened {
            navigateToMain()
        } else {
            navigateToOnboarding()
        }
    }

    private func navigateToOnboarding() {
        let onboarding = OnboardingCoordinator(navigationController: navigationController)
        childCoordinators.append(onboarding)
        onboarding.onFinish = { [weak self] in
            guard let self else { return }
            self.navigateToSubs(type: .onboarding)
        }
        onboarding.start()
    }

    private func navigateToMain() {
        let main = MainScreenCoordinator(navigationController: navigationController)
        childCoordinators.append(main)

        main.subscription = { [weak self] in
            guard let self else { return }
            self.presentSubscription(type: .app)
        }
        main.start()
    }

    private func navigateToSubs(type: TypeSubsScreen) {
        updateViewWithRCValues()
        let subscription = SubscriptionCoordinator(navigationController: navigationController)
        childCoordinators.append(subscription)
        subscription.onFinish = { [weak self] in
            guard let self else { return }
            self.navigateToMain()
        }
        switch type {
        case .onboarding:
            subscription.presentSubscriptionController(with: onboardingSubs, animated: false)
        case .app:
            subscription.presentSubscriptionController(with: appSubs, animated: true)
        }
    }

    private func presentSubscription(type: TypeSubsScreen) {
        updateViewWithRCValues()
        let subscription = SubscriptionCoordinator(navigationController: navigationController)
        childCoordinators.append(subscription)
        subscription.onFinish = { [weak self] in
            guard let self else { return }
            self.navigationController.dismiss(animated: true)
        }
        switch type {
        case .onboarding:
            subscription.presentSubscriptionController(with: onboardingSubs, animated: false)
        case .app:
            subscription.presentSubscriptionController(with: appSubs, animated: true)
        }
    }

    // MARK: Remote config

    private func setupRemoteConfigDefaults() {
        let defaultValues = [
            "onBoardingSubscriptions": Constant.subsDefaultValue as NSObject,
            "settingsSubscriptions": Constant.subsDefaultValue as NSObject
        ]
        RemoteConfig.remoteConfig().setDefaults(defaultValues)
    }

    private func updateViewWithRCValues() {
        onboardingSubs = RemoteConfig
            .remoteConfig()
            .configValue(forKey: "onBoardingSubscriptions")
            .stringValue ?? Constant.subsDefaultValue
        appSubs = RemoteConfig
            .remoteConfig()
            .configValue(forKey: "settingsSubscriptions")
            .stringValue ?? Constant.subsDefaultValue

        print(appSubs)
    }
}
