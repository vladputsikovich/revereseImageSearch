//
//  ImageShrinkSizeController.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 27.06.23.
//

import UIKit

protocol ImageShrinkSizeDelegate: AnyObject {
    func searchSelected(shrink: Shrink)
}

enum Shrink: Int, CaseIterable {
    case dont
    case tiny
    case small
    case medium
    case large

    func size() -> Int {
        switch self {
        case .dont:
            return 0
        case .tiny:
            return 60
        case .small:
            return 150
        case .medium:
            return 480
        case .large:
            return 640
        }
    }

    func text() -> String {
        switch self {
        case .dont:
            return L10n.Settings.dontShrink
        case .tiny:
            return L10n.Settings.tiny("\(size())px")
        case .small:
            return L10n.Settings.small("\(size())px")
        case .medium:
            return L10n.Settings.mediumShrink("\(size())px")
        case .large:
            return L10n.Settings.large("\(size())px")
        }
    }
}

class ImageShrinkSizeController: UIViewController {

    // MARK: Properties

    typealias VoidClosure = (() -> ())

    var onFinish: VoidClosure?

    private var delegate: ImageShrinkSizeDelegate
    private var shrink: Shrink

    private var selectedShrink = DefaultsLayer().imageShrinkSize

    // MARK: UI elements

    private let mainLabel = UILabel()
    private let border = UIView()
    private let closeButton = UIButton()
    private let shrinkStackView = UIStackView()
    private let saveButton = ContinueButton(buttonText: L10n.App.save)

    // MARK: App lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: Init

    init(delegate: ImageShrinkSizeDelegate, shrink: Shrink) {
        self.delegate = delegate
        self.shrink = shrink
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Setup

    private func setup() {
        view.backgroundColor = .white
        createMainLabel()
        createCloseButton()
        createLine()
        createEnginesStackView()
        createSaveButton()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(selectDefaultSearch),
            name: .engineSelected,
            object: nil
        )
    }

    // MARK: Creating UI elements

    private func createMainLabel() {
        view.addSubview(mainLabel)

        mainLabel.text = L10n.Settings.imageShrinkSize
        mainLabel.font = FontFamily.SFProDisplay.bold.font(size: 24)
        mainLabel.textColor = .black

        mainLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(18)
            make.leading.equalToSuperview().inset(24)
        }
    }

    private func createCloseButton() {
        view.addSubview(closeButton)

        closeButton.backgroundColor = Asset.Colors.appGray.color
        closeButton.setImage(
            Asset.Assets.close.image
                .withRenderingMode(.alwaysOriginal)
                .withTintColor(Asset.Colors.crossButtonGray.color),
            for: .normal
        )

        closeButton.addTarget(self, action: #selector(closeView), for: .touchUpInside)

        closeButton.layer.cornerRadius = 15

        closeButton.snp.makeConstraints { make in
            make.centerY.equalTo(mainLabel.snp.centerY)
            make.trailing.equalToSuperview().inset(18)
        }
    }

    private func createLine() {
        view.addSubview(border)

        border.backgroundColor = Asset.Colors.appGray.color

        border.snp.makeConstraints { make in
            make.top.equalTo(mainLabel.snp.bottom).inset(-18)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
    }

    private func createSaveButton() {
        view.addSubview(saveButton)

        saveButton.onTapped = { [weak self] in
            guard let self else { return }
            self.onFinish?()
            delegate.searchSelected(shrink: Shrink.allCases[selectedShrink])
        }

        saveButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(view.frame.height / 20)
            make.height.equalTo(view.frame.height / 15)
            make.width.greaterThanOrEqualTo(view.frame.width / 3)
        }
    }

    private func createEnginesStackView() {
        view.addSubview(shrinkStackView)

        shrinkStackView.axis = .vertical
        shrinkStackView.alignment = .fill
        shrinkStackView.distribution = .fillEqually
        shrinkStackView.spacing = 5

        Shrink.allCases.forEach { value in
            let selected = value.rawValue == DefaultsLayer().imageShrinkSize
            shrinkStackView.addArrangedSubview(SettingsElementWithText(text: value.text(), selected: selected))
        }

        shrinkStackView.snp.makeConstraints { make in
            make.top.equalTo(border).inset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }

    @objc func selectDefaultSearch(_ notification: NSNotification) {
        guard let selectedShrinkText = notification.userInfo?["selectedText"] as? String else { return }
        selectedShrink = Shrink.allCases.first(where: { shrink in
            shrink.text() == selectedShrinkText
        })?.rawValue ?? 0
    }

    @objc func closeView() {
        onFinish?()
    }


    // MARK: Animation
}

