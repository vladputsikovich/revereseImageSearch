//
//  Coordinator.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 31.05.23.
//

import UIKit

protocol Coordinator {
    var onFinish: (() -> ())? { get set }
    init(navigationController: UINavigationController)
    var childCoordinators: [Coordinator] { get set }
    func start()
}
