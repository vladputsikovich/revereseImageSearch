//
//  OnboardingView.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 31.05.23.
//

import UIKit

class OnboardingView: UIView {

    private var image: UIImage
    private var mainText: String
    private var secondText: String

    private let imageView = UIImageView()
    private let mainLabel = UILabel()
    private let secondLabel = UILabel()

    init(image: UIImage, mainText: String, secondText: String) {
        self.image = image
        self.mainText = mainText
        self.secondText = secondText
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }

    private func setup() {
        createMainLabel()
        createSecondLabel()
        createImageView()
    }

    private func createMainLabel() {
        addSubview(mainLabel)

        mainLabel.text = mainText
        mainLabel.font = FontFamily.SFProDisplay.bold.font(size: 32)
        mainLabel.textColor = .black
        mainLabel.numberOfLines = 0
        mainLabel.textAlignment = .left

        mainLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(frame.width / 10)
        }
    }

    private func createSecondLabel() {
        addSubview(secondLabel)

        secondLabel.text = secondText
        secondLabel.font = FontFamily.SFProDisplay.regular.font(size: 17)
        secondLabel.textColor = .black
        secondLabel.alpha = 0.8
        secondLabel.numberOfLines = 0
        secondLabel.textAlignment = .left

        let attributedString = NSMutableAttributedString(string: secondLabel.text ?? "")
        attributedString.addAttribute(
            NSAttributedString.Key.kern,
            value: 1.0,
            range: NSRange(location: 0, length: attributedString.length)
        )

        secondLabel.attributedText = attributedString

        secondLabel.snp.makeConstraints { make in
            make.top.equalTo(mainLabel.snp.bottom).inset(-24)
            make.leading.trailing.equalToSuperview().inset(frame.width / 10)
        }
    }

    private func createImageView() {
        addSubview(imageView)

        imageView.image = image
        imageView.contentMode = .scaleAspectFit

        imageView.snp.makeConstraints { make in
            make.top.equalTo(secondLabel.snp.bottom).inset(-(frame.height / 12))
            make.bottom.equalToSuperview().inset(frame.height / 16)
            make.leading.equalTo(secondLabel.snp.leading)
            make.trailing.equalTo(secondLabel.snp.trailing)
            make.centerX.equalToSuperview()
        }
    }
}
