//
//  SubscriptionController.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 31.05.23.
//

import UIKit
import Firebase

class SubscriptionController: UIViewController {

    var onBackTapped: (() -> ())?

    var subscribe: ((AppStoreProducts) -> ())?

    private var selectedSubscription: AppStoreProducts?

    private var viewModel: SubscriptionViewModel

    private var notificationShowed = false

    private var crossDelay = 0
    private var isReview = true

    private let closeButton = UIButton()
    private let restoreButton = UIButton()
    private let unlimTitle = UILabel()

    private let planRenewsLabel = UILabel()

    private let featuresStackView = UIStackView()

    private let subscription1 = SubscriptionInfoView()
    private let subscription2 = SubscriptionInfoView()
    private let subscription3 = SubscriptionInfoView()

    private var continueButton = ContinueButton(buttonText: L10n.Onboadring.continueText)

    private let notificationView = NotificationView()


    init(viewModel: SubscriptionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let subs = viewModel.getSubscriptionInfo()

        subscription2.configOf(selected: true, subscriptionInfo: subs[1])
        subscription1.configOf(selected: false, subscriptionInfo: subs[0])
        subscription3.configOf(selected: false, subscriptionInfo: subs[2])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !NetworkMonitorObserver.shared.isConnected {
            showNotiicationView()
        }
    }

    private func setup() {
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = Asset.Colors.background.color

        NotificationCenter.default.addObserver(self, selector: #selector(changeSelectedSubscription), name: .viewSelected, object: nil)

        setupRemoteConfigDefaults()
        updateViewWithRCValues()

        createCloseButton()
        createRemoteButton()
        createUnlimTitle()
        createFeaturesStack()
        createSubscriptionStack()
        createContinueButton()
        createNotificationView()

        if isReview {
            createPlanRenewsLabel()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(crossDelay)) { [weak self] in
            guard let self = self else { return }
            self.closeButton.isHidden = false
        }
    }

    private func createCloseButton() {
        view.addSubview(closeButton)

        closeButton.isHidden = true

        closeButton.setImage(Asset.Assets.close.image, for: .normal)
        closeButton.addTarget(self, action: #selector(closeContoller), for: .touchUpInside)

        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(view.frame.height / 50)
            make.trailing.equalToSuperview().inset(view.frame.width / 20)
            make.width.height.equalTo(40)
        }
    }

    private func createRemoteButton() {
        view.addSubview(restoreButton)

        restoreButton.setTitle(L10n.Subscription.restore, for: .normal)
        restoreButton.setTitleColor(.black, for: .normal)
        restoreButton.titleLabel?.font = FontFamily.SFProDisplay.medium.font(size: 14)
        restoreButton.addTarget(self, action: #selector(restore), for: .touchUpInside)

        restoreButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(view.frame.height / 50)
            make.leading.equalToSuperview().inset(view.frame.width / 20)
        }
    }

    private func createUnlimTitle() {
        view.addSubview(unlimTitle)

        unlimTitle.text = L10n.Subscription.unlimited
        unlimTitle.font = FontFamily.SFProDisplay.medium.font(size: 32)
        unlimTitle.textColor = .black
        unlimTitle.numberOfLines = 0
        unlimTitle.textAlignment = .left

        unlimTitle.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(view.frame.height / 15)
            make.leading.trailing.equalToSuperview().inset(view.frame.width / 10)
        }
    }

    private func createFeaturesStack() {
        var features = [
            L10n.Subscription.Feature.noAds,
            L10n.Subscription.Feature.searchHistory,
            L10n.Subscription.Feature.searchEngines,
            L10n.Subscription.Feature.imageSearch
        ]

        view.addSubview(featuresStackView)

        featuresStackView.axis = .vertical
        featuresStackView.spacing = 8
        featuresStackView.alignment = .fill
        featuresStackView.distribution = .equalSpacing

        let fontSize: CGFloat = UIScreen.main.bounds.height < 700 ? 18: 20

        features.forEach { text in
            let featureView = UIView()
            let acceptImage = UIImageView()
            let featureText = UILabel()

            featuresStackView.addArrangedSubview(featureView)

            featureView.addSubview(acceptImage)

            acceptImage.image = Asset.Assets.star.image

            acceptImage.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.width.height.equalTo(24)
                make.leading.equalToSuperview()
            }

            featureView.addSubview(featureText)

            featureText.text = text
            featureText.textColor = .black
            featureText.textAlignment = .left
            featureText.numberOfLines = 0
            featureText.alpha = 0.6


            featureText.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.leading.equalTo(acceptImage.snp.trailing).inset(-10)
                make.trailing.lessThanOrEqualToSuperview().inset(10)
            }
        }

        featuresStackView.snp.makeConstraints { make in
            make.top.equalTo(unlimTitle.snp.bottom).inset(-(view.frame.height / 20))
            make.leading.trailing.equalToSuperview().inset(view.frame.width / 10)
            make.height.equalToSuperview().multipliedBy(0.16)
        }
    }

    private func createSubscriptionStack() {
        view.addSubview(subscription2)

        subscription2.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(0.22)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.32)
            make.bottom.equalToSuperview().inset(view.frame.height / 4)
        }

        view.addSubview(subscription1)

        subscription1.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(0.22)
            make.centerY.equalTo(subscription2.snp.centerY)
            make.width.equalToSuperview().multipliedBy(0.32)
            make.leading.equalToSuperview().inset(view.frame.width / 40)
        }

        view.addSubview(subscription3)


        subscription3.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(0.22)
            make.centerY.equalTo(subscription2.snp.centerY)
            make.width.equalToSuperview().multipliedBy(0.32)
            make.trailing.equalToSuperview().inset(view.frame.width / 40)
        }
    }

    private func createPlanRenewsLabel() {
        view.addSubview(planRenewsLabel)

        planRenewsLabel.text = L10n.Subscription.planRenews
        planRenewsLabel.textColor = .black
        planRenewsLabel.font = FontFamily.SFProDisplay.regular.font(size: 12)
        planRenewsLabel.textAlignment = .center
        planRenewsLabel.alpha = 0.6

        planRenewsLabel.isHidden = !isReview

        planRenewsLabel.snp.makeConstraints { make in
            make.top.equalTo(subscription2.snp.bottom).inset(-(view.frame.height / 50))
            make.centerX.equalToSuperview()
        }
    }

    private func createContinueButton() {
        if isReview {
            continueButton = ContinueButton(buttonText: L10n.Subscription.subscribe)
        }

        view.addSubview(continueButton)

        continueButton.onTapped = { [weak self] in
            guard let self else { return }
            guard let subscription = self.selectedSubscription else { return }

            if !NetworkMonitorObserver.shared.isConnected {
                self.showNotiicationView()
            } else {
                let loadingView = LoadingScreen(frame: UIScreen.main.bounds)
                self.view.addSubview(loadingView)

                InAppService.shared.subscribe(product: subscription) {
                    loadingView.removeFromSuperview()
                } onSubscription: {
                    self.onBackTapped?()
                } onError: { error in
                    print(error)
                }
            }
        }

        continueButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(view.frame.height / 20)
            make.height.equalTo(view.frame.height / 15)
            make.width.equalTo(view.frame.width / 2)
        }
    }

    private func createNotificationView() {
        view.addSubview(notificationView)

        notificationView.isHidden = true

        notificationView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(-100)
            make.trailing.leading.equalToSuperview().inset(10)
            make.height.equalTo(80)
        }
    }

    private func showNotiicationView() {
        if !notificationShowed {
            notificationView.animateView(text: L10n.App.connection)
        }
    }

    private func createAlert(titleText: String, messageTitle: String,closure: (() -> ())?) {
        let alert = UIAlertController(title: titleText, message: messageTitle, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.App.ok, style: .default, handler: { action in
            closure?()
        }))
        present(alert, animated: true, completion: nil)
    }

    // MARK: Remote config

    private func setupRemoteConfigDefaults() {
        let defaultValues = [
            "isReview": true as NSObject,
            "crossDelay": 0 as NSObject
        ]
        RemoteConfig.remoteConfig().setDefaults(defaultValues)
    }

    private func updateViewWithRCValues() {
        isReview = RemoteConfig.remoteConfig().configValue(forKey: "isReview").boolValue
        crossDelay = RemoteConfig.remoteConfig().configValue(forKey: "crossDelay").numberValue.intValue
    }

    @objc func restore() {
        if NetworkMonitorObserver.shared.isConnected {
            let loadingView = LoadingScreen(frame: UIScreen.main.bounds)
            view.addSubview(loadingView)
            InAppService.shared.restorePurchases {
                print("OnDis")
            } onSubscription: { [weak self] in
                guard let self else { return }
                self.createAlert(titleText: L10n.App.done, messageTitle: L10n.Subscription.successRestore) {
                    self.onBackTapped?()
                }
            } onError: { [weak self] error in
                guard let self else { return }
                self.createAlert(titleText: L10n.App.sorry, messageTitle: L10n.Subscription.nothingRestore) {
                    loadingView.removeFromSuperview()
                }
            }
        } else {
            showNotiicationView()
        }
    }

    @objc func closeContoller() {
        onBackTapped?()
    }

    @objc func changeSelectedSubscription(_ notification: NSNotification) {
        guard let subscription = notification.userInfo?["subscription"] as? AppStoreProducts else { return }
        selectedSubscription = subscription
    }
}

