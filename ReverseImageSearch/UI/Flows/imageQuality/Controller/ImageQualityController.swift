//
//  ImageQualityController.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 27.06.23.
//

import UIKit

protocol ImageQualityDelegate: AnyObject {
    func qualitySelected(quality: Quality)
}

enum Quality: Int, CaseIterable {
    case defaultQuality
    case high
    case medium
    case low


    func text() -> String {
        switch self {
        case .defaultQuality:
            return L10n.Settings.default
        case .high:
            return L10n.Settings.high
        case .medium:
            return L10n.Settings.medium
        case .low:
            return L10n.Settings.low

        }
    }

    func compressorValue() -> CGFloat {
        switch self {
        case .defaultQuality:
            return 1
        case .high:
            return 0.8
        case .medium:
            return 0.5
        case .low:
            return 0.3
        }
    }
}

class ImageQualityController: UIViewController {

    // MARK: Properties

    typealias VoidClosure = (() -> ())

    var onFinish: VoidClosure?

    private var delegate: ImageQualityDelegate
    private var quality: Quality

    private var selectedQuality = DefaultsLayer().imageQuality

    // MARK: UI elements

    private let mainLabel = UILabel()
    private let border = UIView()
    private let closeButton = UIButton()
    private let qualityStackView = UIStackView()
    private let saveButton = ContinueButton(buttonText: L10n.App.save)

    // MARK: App lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: Init

    init(delegate: ImageQualityDelegate, quality: Quality) {
        self.delegate = delegate
        self.quality = quality
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
        createQualityStackView()
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

        mainLabel.text = L10n.Settings.imageQuality
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
            delegate.qualitySelected(quality: Quality.allCases[selectedQuality])
        }

        saveButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(view.frame.height / 20)
            make.height.equalTo(view.frame.height / 15)
            make.width.greaterThanOrEqualTo(view.frame.width / 3)
        }
    }

    private func createQualityStackView() {
        view.addSubview(qualityStackView)

        qualityStackView.axis = .vertical
        qualityStackView.alignment = .fill
        qualityStackView.distribution = .fillEqually
        qualityStackView.spacing = 5

        Quality.allCases.forEach { value in
            let selected = value.rawValue == DefaultsLayer().imageQuality
            qualityStackView.addArrangedSubview(SettingsElementWithText(text: value.text(), selected: selected))
        }

        qualityStackView.snp.makeConstraints { make in
            make.top.equalTo(border).inset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }

    @objc func selectDefaultSearch(_ notification: NSNotification) {
        guard let selectedQualityText = notification.userInfo?["selectedText"] as? String else { return }
        selectedQuality = Quality.allCases.first(where: { quality in
            quality.text() == selectedQualityText
        })?.rawValue ?? 0
    }

    @objc func closeView() {
        onFinish?()
    }


    // MARK: Animation
}

