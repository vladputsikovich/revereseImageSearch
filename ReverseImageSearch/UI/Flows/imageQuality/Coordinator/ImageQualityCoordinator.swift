//
//  ImageQualityCoordinator.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 27.06.23.
//

import UIKit

class ImageQualityCoordinator: NSObject, Coordinator {
    var childCoordinators: [Coordinator] = []

    var onFinish: (() -> ())?

    unowned let navigationController: UINavigationController

    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {}

    func openImageQuality(delegate: ImageQualityDelegate, quality: Quality) {
        let imageQuality = ImageQualityController(delegate: delegate, quality: quality)
        imageQuality.modalPresentationStyle = .formSheet
        imageQuality.isModalInPresentation = true
        
        imageQuality.onFinish = { [weak self] in
            guard let self else { return }
            self.navigationController.dismiss(animated: true)
        }

        navigationController.present(imageQuality, animated: true)
    }
}
