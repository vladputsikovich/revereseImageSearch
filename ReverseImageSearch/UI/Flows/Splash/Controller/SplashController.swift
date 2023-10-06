//
//  ViewController.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 31.05.23.
//

import UIKit
import SnapKit

class SplashController: UIViewController {

    // MARK: Properties

    typealias VoidClosure = (() -> ())

    var onFinish: VoidClosure?

    // MARK: UI elements

    private let imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Asset.Colors.background.color
        createImageView()
        checkSubscription()
    }

    private func checkSubscription() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.onFinish?()
        }
        InAppService.shared.validate { [weak self] state in
            guard let self = self else { return }
            print(state)
        }
    }

    private func createImageView() {
        view.addSubview(imageView)

        imageView.image = Asset.Assets.splashIcon.image
        imageView.contentMode = .scaleAspectFit

        imageView.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
            make.height.width.equalTo(120)
        }
    }
}


