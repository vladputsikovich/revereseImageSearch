//
//  SubscriptionCoordinator.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 31.05.23.
//

import UIKit

class SubscriptionCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    var onFinish: (() -> ())?

    unowned let navigationController: UINavigationController

    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {

    }

    func openSubscriptionController(with subscritpions: String) {
        let viewModel = SubscriptionViewModel.init(subscriptions: subscritpions.components(separatedBy: ":"))
        let subscription = SubscriptionController(viewModel: viewModel)

        subscription.onBackTapped = { [weak self] in
            guard let self else { return }
            self.onFinish?()
        }

        navigationController.pushViewController(subscription, animated: false)
    }

    func presentSubscriptionController(with subscritpions: String, animated: Bool) {
        let viewModel = SubscriptionViewModel.init(subscriptions: subscritpions.components(separatedBy: ":"))
        let subscription = SubscriptionController(viewModel: viewModel)

        subscription.onBackTapped = { [weak self] in
            guard let self else { return }
            self.onFinish?()
        }

        subscription.modalPresentationStyle = .fullScreen

        navigationController.present(subscription, animated: animated)
    }

//    private func navigateToLibrary() {
//        let library = LibraryCoordinator(navigationController: navigationController)
//        childCoordinators.append(library)
//        library.start()
//    }
}

