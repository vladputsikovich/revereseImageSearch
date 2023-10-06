//
//  SettingsElement.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 22.06.23.
//

import UIKit

enum SettingsElementType {
    case withText
    case withSwitch
    case empty
}

protocol SettingsElementProtocol {
    func text() -> String
    func type() -> SettingsElementType
}

enum BasicSettingsElement: CaseIterable, SettingsElementProtocol {
    case defaultSearch
    case imageShrinkSize
    case imageQuality
    case imageEditor

    func text() -> String {
        switch self {
        case .defaultSearch:
            return L10n.Settings.defaultSearch
        case .imageShrinkSize:
            return L10n.Settings.imageShrinkSize
        case .imageQuality:
            return L10n.Settings.imageQuality
        case .imageEditor:
            return L10n.Settings.imageEditor
        }
    }

    func type() -> SettingsElementType {
        switch self {
        case .defaultSearch:
            return .withText
        case .imageShrinkSize:
            return .withText
        case .imageQuality:
            return .withText
        case .imageEditor:
            return .withSwitch
        }
    }

    func value() -> Int {
        switch self {
        case .defaultSearch:
            return DefaultsLayer().defaultSearchEngine
        case .imageShrinkSize:
            return DefaultsLayer().defaultSearchEngine
        case .imageQuality:
            return DefaultsLayer().defaultSearchEngine
        case .imageEditor:
            return DefaultsLayer().defaultSearchEngine
        }
    }
}

enum OtherSettingsElement: CaseIterable, SettingsElementProtocol {
    case rateUs
    case support
    case share
    case privacy
    case terms

    func text() -> String {
        switch self {
        case .rateUs:
            return L10n.Settings.rateUs
        case .support:
            return L10n.Settings.support
        case .share:
            return L10n.Settings.share
        case .privacy:
            return L10n.Settings.privacy
        case .terms:
            return L10n.Settings.terms
        }
    }

    func type() -> SettingsElementType {
        switch self {
        case .rateUs:
            return .empty
        case .support:
            return .empty
        case .share:
            return .empty
        case .privacy:
            return .empty
        case .terms:
            return .empty
        }
    }
}

class SettingsElement: UIView {

    // MARK: Properties

    var onTapped: (() -> Void)?

    var imageEditorChaged: ((Bool) -> ())?

    private var element: SettingsElementProtocol

    private let mainLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let imageView = UIImageView()
    private let imageEditorSwitch = UISwitch()

    init(element: SettingsElementProtocol) {
        self.element = element
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
        backgroundColor = Asset.Colors.cellGray.color
        createMainLabel()
        //createDescriptionLabel()

        if element as? OtherSettingsElement != OtherSettingsElement.terms && element as? BasicSettingsElement != BasicSettingsElement.imageEditor {
            createLine()
        }
        if element.type() != .withSwitch {
            createImageView()
        } else {
            createSwitch()
        }
        if element.type() == .withText {
            createDescription()
        }
        if element.type() != .withSwitch {
            addTapView()
        }

    }

    private func createMainLabel() {
        addSubview(mainLabel)

        mainLabel.text = element.text()
        mainLabel.font = FontFamily.SFProDisplay.regular.font(size: 17)
        mainLabel.textColor = .black

        mainLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(16)
        }

    }

    private func createDescriptionLabel() {
        addSubview(descriptionLabel)

        //descriptionLabel.text = cardDescription
        descriptionLabel.font = FontFamily.SFProDisplay.regular.font(size: 16)
        descriptionLabel.textColor = .black

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(mainLabel.snp.bottom).inset(-4)
            make.leading.equalToSuperview().inset(16)
        }
    }

    private func createImageView() {
        addSubview(imageView)

        imageView.image = Asset.Assets.arrow.image

        imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
        }
    }

    private func createLine() {
        let view = UIView()
        view.backgroundColor = .systemGray

        addSubview(view)

        view.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(0.5)
            make.centerX.equalToSuperview()
        }
    }

    private func createDescription() {
        addSubview(descriptionLabel)
        guard let elem = element as? BasicSettingsElement else { return }
        switch elem {
        case .defaultSearch:
            descriptionLabel.text = Searcher.allCases.first(where: { engine in
                engine.rawValue == DefaultsLayer().defaultSearchEngine
            })?.name()
        case .imageShrinkSize:
            descriptionLabel.text = Shrink.allCases.first(where: { shrink in
                shrink.rawValue == DefaultsLayer().imageShrinkSize
            })?.text()
        case .imageQuality:
            descriptionLabel.text = Quality.allCases.first(where: { quality in
                quality.rawValue == DefaultsLayer().imageQuality
            })?.text()
        case .imageEditor:
            descriptionLabel.text = ""
        }

        descriptionLabel.font = FontFamily.SFProDisplay.regular.font(size: 17)
        descriptionLabel.textColor = .black.withAlphaComponent(0.4)

        descriptionLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(imageView.snp.leading).inset(-8)
        }
    }

    private func createSwitch() {
        addSubview(imageEditorSwitch)

        imageEditorSwitch.onTintColor = Asset.Colors.mainBlue.color
        imageEditorSwitch.setOn(DefaultsLayer().imageEditor, animated: false)

        imageEditorSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)

        imageEditorSwitch.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
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

    @objc func switchChanged(_ sender: UISwitch) {
        imageEditorChaged?(sender.isOn)
    }
}
