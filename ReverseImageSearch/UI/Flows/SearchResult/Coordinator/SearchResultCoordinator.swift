//
//  SearchResultCoordinator.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 20.06.23.
//

import UIKit

class SearchResultCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    var onFinish: (() -> ())?

    var subscription: (() -> ())?

    unowned let navigationController: UINavigationController

    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {

    }

    func openSearchResults(with refs: [URL]) {
        let search = SearchResultController(refs: refs)
        search.onFinish = { [weak self] in
            guard let self else { return }
            self.onFinish?()
        }

        search.subscription = { [weak self] in
            guard let self else { return }
            self.subscription?()
        }

        search.noInternetNotification = { [weak self] in
            guard let self else { return }
            let alert = AlertShower.showAlert(title: L10n.App.sorry, message: L10n.App.connectionTryAgain)
            navigationController.present(alert, animated: true)
        }

        navigationController.pushViewController(search, animated: true)
    }
}
