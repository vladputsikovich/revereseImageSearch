//
//  ImageShrinkSizeCoordinator.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 27.06.23.
//

import UIKit

class ImageShrinkSizeCoordinator: NSObject, Coordinator {
    var childCoordinators: [Coordinator] = []

    var onFinish: (() -> ())?

    unowned let navigationController: UINavigationController

    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {}

    func openImageShrink(delegate: ImageShrinkSizeDelegate, shrink: Shrink) {
        let imageShrink = ImageShrinkSizeController(delegate: delegate, shrink: shrink)
        imageShrink.modalPresentationStyle = .formSheet
        imageShrink.isModalInPresentation = true
        
        imageShrink.onFinish = { [weak self] in
            guard let self else { return }
            self.navigationController.dismiss(animated: true)
        }

        navigationController.present(imageShrink, animated: true)
    }
}
