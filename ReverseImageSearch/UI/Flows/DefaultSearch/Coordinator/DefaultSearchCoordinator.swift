//
//  DefaultSearchCoordinator.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 26.06.23.
//

import UIKit

class DefaultSearchCoordinator: NSObject, Coordinator {
    var childCoordinators: [Coordinator] = []
    
    let subsDefaultValue = "weekTrial:monthTrial:yearTrial"
    
    var onFinish: (() -> ())?
    var subscription: (() -> ())?

    private var newNavigation = UINavigationController()
    unowned let navigationController: UINavigationController

    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {}

    func openDefaultSearch(delegate: DefaultSearchDelegate, search: Searcher) {
        let defaultSearch = DefaultSearchController(delegate: delegate, search: search)
        newNavigation = UINavigationController(rootViewController: defaultSearch)
        newNavigation.isNavigationBarHidden = true
        defaultSearch.modalPresentationStyle = .formSheet

        defaultSearch.onFinish = { [weak self] in
            guard let self else { return }
            self.navigationController.dismiss(animated: true)
            self.backToSettings()
        }
        
        defaultSearch.subscription = { [weak self] in
            guard let self else { return }
            self.navigateToSubs()
        }
        
        newNavigation.isModalInPresentation = true
        navigationController.present(newNavigation, animated: true)
    }
    
    private func backToSettings() {
        guard let controller = navigationController.viewControllers.last as? SettingsContoller else { return }
        controller.viewDidAppear(true)
    }
    
    private func navigateToSubs() {
        let subscription = SubscriptionCoordinator(navigationController: newNavigation)
        childCoordinators.append(subscription)
        subscription.onFinish = { [weak self] in
            guard let self else { return }
            self.newNavigation.dismiss(animated: true)
        }

        subscription.presentSubscriptionController(with: subsDefaultValue, animated: true)
    }
}

