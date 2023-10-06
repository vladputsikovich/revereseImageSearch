//
//  SettingsContoller.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 22.06.23.
//

import UIKit

class SettingsContoller: UIViewController {

    // MARK: Properties

    typealias VoidClosure = (() -> ())

    var onFinish: VoidClosure?
    var subscription: VoidClosure?

    var settingElementAction: ((SettingsElementProtocol) -> ())?

    private let defaults = DefaultsLayer()
    private var isSubscribe = false

    // MARK: UI elements

    private let screenTitle = UILabel()
    private let backButton = UIButton()
    private let getPremiumButton = GetPremiumView()
    private let basicLabel = UILabel()
    private let basicSettingsElementStack = UIStackView()
    private let otherLabel = UILabel()
    private let otherSettingsElementStack = UIStackView()

    // MARK: App lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        reloadStackViews()

        isSubscribe = defaults.isSubscribted

        if isSubscribe {
            view.subviews.forEach { sub in
                sub.removeFromSuperview()
            }
            setup()
        }

        createBasicLabel()
        createBasicSettingsElementStack()
        createOtherLabel()
        createOtherSettingsElementStack()
    }

    // MARK: Setup

    private func setup() {
        isSubscribe = defaults.isSubscribted

        view.backgroundColor = .white
        createScreenTitle()
        createBackButton()
        if !isSubscribe {
            createGetPremiumButton()
        }
    }

    // MARK: Creating UI elements

    private func createScreenTitle() {
        view.addSubview(screenTitle)

        screenTitle.text = L10n.Settings.settings
        screenTitle.font = FontFamily.SFProDisplay.bold.font(size: 20)
        screenTitle.textColor = .black

        screenTitle.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(10)
            make.centerX.equalToSuperview()
        }
    }

    private func createBackButton() {
        view.addSubview(backButton)

        backButton.setImage(Asset.Assets.back.image, for: .normal)

        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)

        backButton.snp.makeConstraints { make in
            make.centerY.equalTo(screenTitle.snp.centerY)
            make.leading.equalToSuperview().inset(view.frame.width / 15)
            make.width.height.equalTo(28)
        }
    }

    private func createGetPremiumButton() {
        view.addSubview(getPremiumButton)

        getPremiumButton.onTapped = { [weak self] in
            guard let self else { return }
            self.subscription?()
        }

        getPremiumButton.snp.makeConstraints { make in
            make.top.equalTo(screenTitle.snp.bottom).inset(-15)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }

    private func createBasicLabel() {
        view.addSubview(basicLabel)

        basicLabel.text = L10n.Settings.basic
        basicLabel.font = FontFamily.SFProDisplay.regular.font(size: 12)
        basicLabel.alpha = 0.5
//        basicLabel.textColor = .black.withAlphaComponent(0.5)

        if isSubscribe {
            basicLabel.snp.makeConstraints { make in
                make.top.equalTo(screenTitle.snp.bottom).inset(-20)
                make.leading.equalToSuperview().inset(32)
            }
        } else {
            basicLabel.snp.makeConstraints { make in
                make.top.equalTo(getPremiumButton.snp.bottom).inset(-20)
                make.leading.equalToSuperview().inset(32)
            }
        }
    }

    private func createBasicSettingsElementStack() {
        let backView = UIView()
        backView.addSubview(basicSettingsElementStack)
        view.addSubview(backView)

        basicSettingsElementStack.axis = .vertical
        basicSettingsElementStack.alignment = .fill
        basicSettingsElementStack.spacing = 0
        basicSettingsElementStack.distribution = .fillEqually

        backView.layer.cornerRadius = 12
        backView.layer.masksToBounds = true

        BasicSettingsElement.allCases.forEach { element in
            let settingsElement = SettingsElement(element: element)
            basicSettingsElementStack.addArrangedSubview(settingsElement)
            settingsElement.onTapped = { [weak self] in
                guard let self else { return }
                self.settingElementAction?(element)
            }

            settingsElement.imageEditorChaged = { value in
                DefaultsLayer().set(.imageEditor(value))
            }
        }

        backView.snp.makeConstraints { make in
            make.top.equalTo(basicLabel.snp.bottom).inset(-8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalToSuperview().multipliedBy(0.22)
        }

        basicSettingsElementStack.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
    }

    private func createOtherLabel() {
        view.addSubview(otherLabel)

        otherLabel.text = L10n.Settings.other
        otherLabel.font = FontFamily.SFProDisplay.regular.font(size: 12)
        otherLabel.textColor = .black.withAlphaComponent(0.5)

        otherLabel.snp.makeConstraints { make in
            make.top.equalTo(basicSettingsElementStack.snp.bottom).inset(-20)
            make.leading.equalTo(basicSettingsElementStack.snp.leading).inset(16)
        }
    }

    private func createOtherSettingsElementStack() {
        let backView = UIView()
        backView.addSubview(otherSettingsElementStack)
        view.addSubview(backView)

        otherSettingsElementStack.axis = .vertical
        otherSettingsElementStack.alignment = .fill
        otherSettingsElementStack.spacing = 0
        otherSettingsElementStack.distribution = .fillEqually

        backView.layer.cornerRadius = 12
        backView.layer.masksToBounds = true

        OtherSettingsElement.allCases.forEach { element in
            let settingsElement = SettingsElement(element: element)
            otherSettingsElementStack.addArrangedSubview(settingsElement)
            settingsElement.onTapped = { [weak self] in
                guard let self else { return }
                self.settingElementAction?(element)
            }
        }

        backView.snp.makeConstraints { make in
            make.top.equalTo(otherLabel.snp.bottom).inset(-8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalToSuperview().multipliedBy(0.275)
        }

        otherSettingsElementStack.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
    }

    private func reloadStackViews() {
        basicSettingsElementStack.arrangedSubviews.forEach { arr in
            basicSettingsElementStack.removeArrangedSubview(arr)
        }

        otherSettingsElementStack.arrangedSubviews.forEach { arr in
            otherSettingsElementStack.removeArrangedSubview(arr)
        }
    }

    @objc func back() {
        onFinish?()
    }
}

extension SettingsContoller: DefaultSearchDelegate {
    func searchSelected(engine: Searcher) {
        DefaultsLayer().set(.defaultSearchEngine(engine.rawValue))
        viewWillAppear(true)
    }
}

extension SettingsContoller: ImageShrinkSizeDelegate {
    func searchSelected(shrink: Shrink) {
        DefaultsLayer().set(.imageShrinkSize(shrink.rawValue))
        viewWillAppear(true)
    }
}

extension SettingsContoller: ImageQualityDelegate {
    func qualitySelected(quality: Quality) {
        DefaultsLayer().set(.imageQuality(quality.rawValue))
        viewWillAppear(true)
    }
}
