//
//  DefaultSearchController.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 26.06.23.
//

import UIKit

protocol DefaultSearchDelegate: AnyObject {
    func searchSelected(engine: Searcher)
}

class DefaultSearchController: UIViewController {

    // MARK: Properties

    typealias VoidClosure = (() -> ())

    var onFinish: VoidClosure?
    var subscription: VoidClosure?

    private var delegate: DefaultSearchDelegate
    private var search: Searcher

    private var selectedEngine = DefaultsLayer().defaultSearchEngine

    // MARK: UI elements

    private let mainLabel = UILabel()
    private let border = UIView()
    private let closeButton = UIButton()
    private let engineStackView = UIStackView()
    private let saveButton = ContinueButton(buttonText: L10n.App.save)

    // MARK: App lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: Init

    init(delegate: DefaultSearchDelegate, search: Searcher) {
        self.delegate = delegate
        self.search = search
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

        mainLabel.text = L10n.Settings.defaultSearch
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
            delegate.searchSelected(engine: Searcher.allCases[selectedEngine])
        }

        saveButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(view.frame.height / 20)
            make.height.equalTo(view.frame.height / 15)
            make.width.greaterThanOrEqualTo(view.frame.width / 3)
        }
    }

    private func createEnginesStackView() {
        view.addSubview(engineStackView)

        engineStackView.axis = .vertical
        engineStackView.alignment = .fill
        engineStackView.distribution = .fillEqually
        engineStackView.spacing = 5

        Searcher.allCases.enumerated().forEach { index, searcher in
            let selected = searcher.rawValue == DefaultsLayer().defaultSearchEngine
            let settigsElementView = SettingsElementEngineView(searcher: searcher, selected: selected, isFree: DefaultsLayer().isSubscribted ? true : searcher.isFree(), tag: index)
            engineStackView.addArrangedSubview(settigsElementView)
            settigsElementView.showSubscriptionScreen = {
                self.subscription?()
            }
        }        

        engineStackView.snp.makeConstraints { make in
            make.top.equalTo(border).inset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }

    @objc func selectDefaultSearch(_ notification: NSNotification) {
        guard let selectedEngineNumber = notification.userInfo?["selectedDefaultSearch"] as? Int else { return }
        selectedEngine = selectedEngineNumber
    }

    @objc func closeView() {
        onFinish?()
    }


    // MARK: Animation
}
