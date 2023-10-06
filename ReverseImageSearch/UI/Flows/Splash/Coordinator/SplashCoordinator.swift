//
//  SplashCoordinator.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 31.05.23.
//

import UIKit

class SplashCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    var onFinish: (() -> ())?

    unowned let navigationController: UINavigationController

    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let splash = SplashController()
        splash.onFinish = { [weak self] in
            guard let self else { return }
            self.onFinish?()

        }
        navigationController.setViewControllers([splash], animated: true)
    }
}
