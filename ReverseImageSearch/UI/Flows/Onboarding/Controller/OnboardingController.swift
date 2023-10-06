//
//  OnboardingController.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 31.05.23.
//

import UIKit
import AppTrackingTransparency

class OnboardingController: UIViewController {

    // MARK: Properties

    typealias VoidClosure = (() -> ())

    var onFinish: VoidClosure?

    // MARK: UI elements
    private let onboardingStackView = UIStackView()
    private let continueButton = ContinueButton(buttonText: L10n.Onboarding.continueText)

    // MARK: App lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: Setup

    private func setup() {
        view.backgroundColor = Asset.Colors.background.color
        createContinueButton()
        createStackView()
        trackingRequest()
    }

    // MARK: Creating UI elements

    private func createStackView() {
        view.addSubview(onboardingStackView)

        let onboardingView1 = OnboardingView(
            image: Asset.Assets.onboarding1.image,
            mainText: L10n.Onboarding.mainTitle1,
            secondText: L10n.Onboarding.secondTitle1
        )

        let onboardingView2 = OnboardingView(
            image: Asset.Assets.onboarding2.image,
            mainText: L10n.Onboarding.mainTitle2,
            secondText: L10n.Onboarding.secondTitle2
        )

        onboardingStackView.spacing = 0
        onboardingStackView.axis = .horizontal
        onboardingStackView.alignment = .fill
        onboardingStackView.distribution = .fillEqually

        onboardingStackView.addArrangedSubview(onboardingView1)
        onboardingStackView.addArrangedSubview(onboardingView2)

        onboardingStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(view.frame.height / 15)
            make.leading.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.7)
            make.width.equalToSuperview().multipliedBy(2)
        }
    }

    private func createContinueButton() {
        view.addSubview(continueButton)

        continueButton.onTapped = { [weak self] in
            guard let self else { return }
            if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
                if self.onboardingStackView.frame.origin.x == 0 {
                    self.onFinish?()
                } else {
                    self.animateScroll()
                }
            } else {
                if self.onboardingStackView.frame.origin.x == -self.view.frame.width {
                    self.onFinish?()
                } else {
                    self.animateScroll()
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

    private func trackingRequest() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .notDetermined:
                    print("notDetermined")
                case .restricted:
                    print("restricted")
                case .denied:
                    print("denied")
                case .authorized:
                    print("authorized")
                }
            }
        }
    }

    // MARK: Animation

    private func animateScroll() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self else { return }
            if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
                self.onboardingStackView.frame.origin.x = 0
            } else {
                self.onboardingStackView.frame.origin.x -= self.view.frame.width
            }
        }
    }
}
