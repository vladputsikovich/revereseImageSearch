//
//  LoadingScreen.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 5.07.23.
//

import UIKit
import SnapKit

class LoadingScreen: UIView {

    // MARK: Propeties

    private let activityIndicator = UIActivityIndicatorView()

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Setup

    private func setup() {
        createBlur()
        createLoadingIndicator()
    }

    // MARK: Create UI elements

    private func createBlur() {
        let blurEffect = UIBlurEffect(style: .systemMaterialDark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.backgroundColor = Asset.Colors.mainBlue.color.withAlphaComponent(0.5)
        blurEffectView.alpha = 0.5
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
    }

    private func createLoadingIndicator() {
        addSubview(activityIndicator)

        activityIndicator.startAnimating()

        activityIndicator.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(80)
        }
    }

}

