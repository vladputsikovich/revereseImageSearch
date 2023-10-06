//
//  SubscriptionInfoView.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 31.05.23.
//

import UIKit
import Firebase

extension Notification.Name {
    static let viewSelected = Notification.Name("viewSelected")
}

struct SubscriptionInfo {
    let title: String
    let price: String
    let period: String
    let subscription: AppStoreProducts
}

class SubscriptionInfoView: UIView {

    // MARK: Properties

    private var isReview: Bool = true
    private var priceBlockDelay: Int = 0

    private var title: String = ""
    private var period: String = ""
    private var price: String = ""

    private var subscription: AppStoreProducts?

    private var textColor: UIColor = .black

    private var isSelected = false

    // MARK: UI elements

    private let halfLine = UIView()
    private let backView = UIView()
    private let titleLabel = UILabel()
    private let periodLabel = UILabel()
    private let priceLabel = UILabel()
    private let loading = UIActivityIndicatorView()

    init() {
        super.init(frame: .zero)
        setupRemoteConfigDefaults()
        updateViewWithRCValues()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        setup()
    }

    private func setup() {
        layer.cornerRadius = frame.height / 10

        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1

        NotificationCenter.default.addObserver(self, selector: #selector(reloadView), name: .viewSelected, object: nil)

        if NetworkMonitorObserver.shared.isConnected {
            createHalfLine()
            createBackTitle()
            createTitleLabel()
            createPeriodPriceLabel()
            addTapGesture()
            DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(priceBlockDelay)) { [weak self] in
                guard let self = self else { return }
                self.priceLabel.isHidden = false
            }
        } else {
            createLoadingView()
        }
    }

    private func createHalfLine() {
        addSubview(halfLine)

        halfLine.backgroundColor = .black
        halfLine.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
    }

    private func createBackTitle() {
        addSubview(backView)

        backView.layer.cornerRadius = frame.height / 10

        backView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        backView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalTo(halfLine.snp.top)
            make.leading.trailing.equalToSuperview()
        }
    }

    private func createTitleLabel() {
        backView.addSubview(titleLabel)

        titleLabel.font = FontFamily.SFProDisplay.bold.font(size: 12)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center

        titleLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalToSuperview()
        }
    }

    private func createPeriodPriceLabel() {
        periodLabel.font = FontFamily.SFProDisplay.regular.font(size: 12)
        periodLabel.numberOfLines = 0
        periodLabel.textAlignment = .center
        periodLabel.textColor = Asset.Colors.mainBlue.color

        priceLabel.isHidden = true
        priceLabel.textColor = .black
        priceLabel.numberOfLines = 0
        priceLabel.textAlignment = .center

        let priceFontSize: CGFloat = isReview ? 19: 12
        priceLabel.font = FontFamily.SFProDisplay.bold.font(size: priceFontSize)


        let pricePerionStackView = UIStackView()

        addSubview(pricePerionStackView)

        pricePerionStackView.spacing = 4
        pricePerionStackView.distribution = .fillProportionally
        pricePerionStackView.axis = .vertical
        pricePerionStackView.alignment = .fill

        pricePerionStackView.addArrangedSubview(periodLabel)
        pricePerionStackView.addArrangedSubview(priceLabel)

        pricePerionStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(1.5)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview().dividedBy(4)
        }
    }

    private func createLoadingView() {
        addSubview(loading)

        loading.startAnimating()

        loading.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
        }
    }

    func configOf(selected: Bool, subscriptionInfo: SubscriptionInfo) {
        subscription = subscriptionInfo.subscription
        if selected {
            selectView()
            backgroundColor = isReview ? Asset.Colors.mainBlue.color.withAlphaComponent(0.3) : .white
            backView.backgroundColor = isReview ? .clear: Asset.Colors.mainBlue.color
            titleLabel.textColor = textColor
            isSelected = selected
        } else {
            transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            backgroundColor = .white
            titleLabel.textColor = textColor
            backView.backgroundColor = isReview ? .clear: Asset.Colors.mainBlue.color.withAlphaComponent(0.4)
            titleLabel.alpha = isReview ? 0.5 : 1
            priceLabel.alpha = isReview ? 1 : 0.5
        }

        titleLabel.text = subscriptionInfo.title
        periodLabel.text = subscriptionInfo.period
        priceLabel.text = subscriptionInfo.price
    }

    private func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectView))
        addGestureRecognizer(tap)
    }

    // MARK: Remote config

    private func setupRemoteConfigDefaults() {
        let defaultValues = [
            "isReview": true as NSObject,
            "priceDelayBlock": 0 as NSObject
        ]
        RemoteConfig.remoteConfig().setDefaults(defaultValues)
    }

    private func updateViewWithRCValues() {
        isReview = RemoteConfig.remoteConfig().configValue(forKey: "isReview").boolValue
        priceBlockDelay = RemoteConfig.remoteConfig().configValue(forKey: "priceBlockDelay").numberValue.intValue
        textColor = isReview ? .black: .white
        priceLabel.font = isReview ? FontFamily.SFProDisplay.bold.font(size: 19): FontFamily.SFProDisplay.bold.font(size: 14)
    }

    @objc func selectView() {
        NotificationCenter.default.post(
            name: .viewSelected,
            object: nil,
            userInfo: ["view": self, "subscription": subscription]
        )
    }

    @objc func reloadView(_ notification: NSNotification) {
        guard let view = notification.userInfo?["view"] as? UIView else { return }
        if view == self {
            UIView.animate(withDuration: 0.2, delay: 0) { [weak self] in
                guard let self else { return }
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.backView.backgroundColor = isReview ? .clear: Asset.Colors.mainBlue.color
                self.titleLabel.alpha = 1
                self.backView.alpha = 1
                self.priceLabel.alpha = 1
                backgroundColor = isReview ? Asset.Colors.mainBlue.color.withAlphaComponent(0.3) : .white
                if self.titleLabel.textColor == .black.withAlphaComponent(0.5) {
                    self.titleLabel.textColor = .black
                }
            }
        } else {
            UIView.animate(withDuration: 0.15, delay: 0) { [weak self] in
                guard let self else { return }
                self.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
                self.backView.backgroundColor = isReview ? .clear: Asset.Colors.mainBlue.color.withAlphaComponent(0.4)
                self.titleLabel.alpha = 0.7
                self.priceLabel.alpha = isReview ? 1: 0.5
                self.layer.shadowColor = UIColor.clear.cgColor
                backgroundColor = .white
                if self.titleLabel.textColor == .black {
                    self.titleLabel.textColor = .black.withAlphaComponent(0.5)
                }
            }
        }
    }
}
