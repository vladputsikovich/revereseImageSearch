//
//  GetPremiumView.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 22.06.23.
//

import UIKit

class GetPremiumView: UIView {

    // MARK: Properties

    var onTapped: (() -> ())?

    // MARK: UI elements

    private let crownImage = UIImageView()
    private let featuresStackView = UIStackView()
    private let title = UILabel()

    // MARK: Init

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: App lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    // MARK: Setup

    private func setup() {
        layer.cornerRadius = 16
        backgroundColor = Asset.Colors.cardBlue.color.withAlphaComponent(0.3)
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 0.33

        createCrownView()
        createTitle()
        createFeaturesStack()
        addTapView()
    }

    // MARK: Create UI elements

    private func createCrownView() {
        addSubview(crownImage)

        crownImage.image = Asset.Assets.crown.image

        crownImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(25)
            make.width.height.equalTo(100)
        }
    }

    private func createTitle() {
        addSubview(title)

        title.text = L10n.Subsciption.getPremium
        title.font = FontFamily.SFProDisplay.bold.font(size: 24)
        title.textColor = .black
        title.textAlignment = .left
        title.numberOfLines = 0

        title.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(16)
        }
    }

    private func createFeaturesStack() {
        var features = [
            L10n.Subscription.Feature.noAds,
            L10n.Subscription.Feature.searchHistory,
            L10n.Subscription.Feature.searchEngines,
            L10n.Subscription.Feature.imageSearch
        ]

        addSubview(featuresStackView)

        featuresStackView.axis = .vertical
        featuresStackView.spacing = 0
        featuresStackView.alpha = 0.6
        featuresStackView.alignment = .fill
        featuresStackView.distribution = .equalSpacing

        let fontSize: CGFloat = UIScreen.main.bounds.height < 700 ? 14: 16

        features.forEach { text in
            let featureText = UILabel()

            featuresStackView.addArrangedSubview(featureText)

            featureText.text = "  •  \(text)"
            featureText.font = FontFamily.SFProDisplay.regular.font(size: fontSize)
            featureText.textColor = .black
            featureText.textAlignment = .left
            featureText.numberOfLines = 0
        }

        featuresStackView.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).inset(-12)
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalTo(crownImage.snp.leading)
            make.bottom.equalToSuperview().inset(16)
        }
    }

    private func addTapView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapAction))
        addGestureRecognizer(tap)
    }

    // MARK: Actions

    @objc func tapAction(_ sender: UIButton) {
        onTapped?()
    }
}

