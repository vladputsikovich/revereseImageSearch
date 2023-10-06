//
//  SearchHistoryCoordinator.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 21.06.23.
//

import UIKit

class SearchHistoryCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    typealias VoidClosure = (() -> ())

    var onFinish: VoidClosure?
    var subscription: VoidClosure?
    var imageSearch: ((ImageSearch) -> ())?
    var wordSearch: ((WordSearch) -> ())?

    unowned let navigationController: UINavigationController

    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewModel = SearchHistoryViewModel.init()
        let history = SearchHistoryController(viewModel: viewModel)
        viewModel.view = history
        history.onFinish = { [weak self] in
            guard let self else { return }
            self.onFinish?()
        }

        history.imageSearchClosure = { [weak self] image in
            guard let self else { return }
            self.imageSearch?(image)
        }

        history.wordSearchClosure = { [weak self] word in
            guard let self else { return }
            self.wordSearch?(word)
        }

        history.subscription = { [weak self] in
            guard let self else { return }
            self.subscription?()
        }

        navigationController.pushViewController(history, animated: true)
    }

}
