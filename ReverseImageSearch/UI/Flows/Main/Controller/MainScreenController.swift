//
//  MainScreenController.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 19.06.23.
//
import GoogleMobileAds
import UIKit
import StoreKit
import Firebase

class MainScreenController: UIViewController {

    // MARK: Properties

    typealias VoidClosure = (() -> ())

    var onFinish: VoidClosure?
    var camera: VoidClosure?
    var library: VoidClosure?
    var history: VoidClosure?
    var settings: VoidClosure?
    var gallery: VoidClosure?
    var clipboard: VoidClosure?
    var urlPaste: VoidClosure?
    var subscription: VoidClosure?
    var textSearch: ((String) -> ())?

    private var showRateUsAlertValue = false
    private var isFirstShow = false
    private var freeSearch = 20

    // MARK: UI elements

    private let screenTitle = UILabel()
    private let historyButton = UIButton()
    private let settingsButton = UIButton()
    private let searchbar = UITextField()
    private let cardStackView = UIStackView()
    private var bannerView = GADBannerView()
    private let selectSource = SelectImageSourceView()
    private let backView = UIView()
    private var notification = NotificationView()
    lazy var loading = LoadingScreen(frame: UIScreen.main.bounds)

    // MARK: App lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if DefaultsLayer().successSearch && !DefaultsLayer().rateUsShowed && showRateUsAlertValue && isFirstShow {
            let number = DefaultsLayer().countNoRateUs + 1
            DefaultsLayer().set(.countNoRateUs(number))
            switch DefaultsLayer().countNoRateUs {
            case 1, 3, 6, 9:
                showRateUsAlert()
            default:
                Analytics.logEvent("rate_us_apple", parameters: nil)
                SKStoreReviewController.requestReview()
            }
        }
        
        isFirstShow.toggle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchbar.text = ""
        bannerView.isHidden = DefaultsLayer().isSubscribted
        updateStackView()
    }

    // MARK: Setup

    private func setup() {
        setupRemoteConfigDefaults()
        updateViewWithRCValues()

        view.backgroundColor = .white
        createScreenTitle()
        createHistoryButton()
        createSettingsButton()
        createSearchBar()
        createAdView()
        createCardStackView()
        createSelectSource()
        createNotification()

        guard let wasOpen = DefaultsLayer().wasOpened else { return }
        if !wasOpen {
            DefaultsLayer().set(.defaultSearchEngine(Searcher.google.rawValue))
            DefaultsLayer().set(.imageEditor(true))
        }
        
        DefaultsLayer().set(.wasOpened(true))
    }

    // MARK: Creating UI elements

    private func createScreenTitle() {
        view.addSubview(screenTitle)

        screenTitle.text = L10n.App.imageSeach
        screenTitle.font = FontFamily.SFProDisplay.bold.font(size: 20)
        screenTitle.textColor = .black

        screenTitle.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(10)
            make.centerX.equalToSuperview()
        }
    }

    private func createHistoryButton() {
        view.addSubview(historyButton)

        historyButton.setImage(Asset.Assets.circlepath.image, for: .normal)

        historyButton.addTarget(self, action: #selector(openHistory), for: .touchUpInside)

        historyButton.snp.makeConstraints { make in
            make.centerY.equalTo(screenTitle.snp.centerY)
            make.leading.equalToSuperview().inset(view.frame.width / 15)
            make.width.height.equalTo(28)
        }
    }

    private func createSettingsButton() {
        view.addSubview(settingsButton)

        settingsButton.setImage(Asset.Assets.settings.image, for: .normal)

        settingsButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)

        settingsButton.snp.makeConstraints { make in
            make.centerY.equalTo(screenTitle.snp.centerY)
            make.trailing.equalToSuperview().inset(view.frame.width / 15)
            make.width.height.equalTo(28)
        }
    }

    private func createSearchBar() {
        view.addSubview(searchbar)

        searchbar.delegate = self

        searchbar.layer.cornerRadius = 10
        searchbar.layer.borderColor = UIColor.black.withAlphaComponent(0.33).cgColor
        searchbar.layer.borderWidth = 1
        searchbar.leftViewMode = .always
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: searchbar.frame.height))
        searchbar.rightView = paddingView
        searchbar.rightViewMode = .always
        searchbar.placeholder = L10n.App.search
        searchbar.returnKeyType = .search

        searchbar.addPaddingAndIcon(Asset.Assets.search.image, padding: 16, isLeftView: true)

        searchbar.snp.makeConstraints { make in
            make.top.equalTo(screenTitle.snp.bottom).inset(-15)
            make.leading.trailing.equalToSuperview().inset(view.frame.width / 15)
            make.height.equalTo(view.frame.height / (UIScreen.main.bounds.height / 36))
        }
    }

    private func createAdView() {
        switch AppConfiguration.environment {
        case .debug, .testFlight:
            bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        case .appStore:
            bannerView.adUnitID = "ca-app-pub-3863763835356682/6236361702"
        }
        
        bannerView.load(GADRequest())
        bannerView.rootViewController = self
        view.addSubview(bannerView)
        bannerView.isHidden = DefaultsLayer().isSubscribted

        bannerView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
    }
    
    private func updateStackView () {
        cardStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        CardInfo.allCases.forEach { cardInfo in
            let card = CardView(
                text: cardInfo.mainText,
                cardDescription: cardInfo.description,
                image: cardInfo.image,
                backColor: cardInfo.color,
                isFree: cardInfo.isFree
            )

            card.onTapped = { [weak self] in
                guard let self else { return }
                self.searchbar.resignFirstResponder()
                if DefaultsLayer().isSubscribted {
                    switch cardInfo {
                    case .gallery:
                        self.gallery?()
                    case .photos:
                        self.camera?()
                    case .face:
                        self.showSelectSource()
                    case .clipboard:
                        self.clipboard?()
                    case .url:
                        self.urlPaste?()
                    }
                } else if !DefaultsLayer().isSubscribted && DefaultsLayer().countFreeSearch < freeSearch {
                    switch cardInfo {
                    case .gallery:
                        self.gallery?()
                    case .photos:
                        self.camera?()
                    case .face:
                        self.showSelectSource()
                    case .clipboard:
                        cardInfo.isFree ? self.clipboard?() : subscription?()
                    case .url:
                        cardInfo.isFree ? self.urlPaste?() : subscription?()
                    }
                } else {
                    subscription?()
                    isFirstShow = false
                }
            }

            cardStackView.addArrangedSubview(card)
        }
    }

    private func createCardStackView() {
        view.addSubview(cardStackView)
        cardStackView.axis = .vertical
        cardStackView.alignment = .fill
        cardStackView.distribution = .fillEqually
        cardStackView.spacing = 16
        updateStackView()

        cardStackView.snp.makeConstraints { make in
            make.top.equalTo(searchbar.snp.bottom).inset(-15)
            make.leading.equalTo(searchbar.snp.leading)
            make.trailing.equalTo(searchbar.snp.trailing)
            make.bottom.equalTo(bannerView.snp.top).inset(-15)
        }
    }

    private func createSelectSource() {
        backView.backgroundColor = .black.withAlphaComponent(0.4)

        view.addSubview(backView)

        backView.isHidden = true

        backView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }

        view.addSubview(selectSource)

        selectSource.isHidden = true

        selectSource.close = { [weak self] in
            guard let self else { return }
            self.selectSource.animate()
            self.backView.isHidden = true
        }

        selectSource.camera = { [weak self] in
            guard let self else { return }
            self.camera?()
            self.selectSource.animate()
            self.backView.isHidden = true
        }

        selectSource.library = { [weak self] in
            guard let self else { return }
            self.gallery?()
            self.selectSource.animate()
            self.backView.isHidden = true
        }

        selectSource.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().dividedBy(2.5)
        }
    }

    private func createNotification() {
        notification.isHidden = true
        view.addSubview(notification)
        notification.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.trailing.leading.equalToSuperview().inset(10)
            make.height.equalTo(80)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(10)
        }
    }

    private func showSelectSource() {
        backView.isHidden = false
        selectSource.animate()
    }

    // MARK: Rate Us alert

    private func showRateUsAlert() {
        let alert = UIAlertController(
            title: L10n.Settings.rateUs,
            message: L10n.App.rateUsInfo,
            preferredStyle: UIAlertController.Style.alert
        )
        alert.addAction(
            UIAlertAction(
                title: L10n.App.no,
                style: UIAlertAction.Style.default,
                handler: { _ in
                    Analytics.logEvent("rate_us_general", parameters: ["answer": "NO"])
                    alert.dismiss(animated: true)
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: L10n.App.yes,
                style: UIAlertAction.Style.default,
                handler: { action in
                    DefaultsLayer().set(.rateUsShowed(true))
                    Analytics.logEvent("rate_us_general", parameters: ["answer": "YES"])
                    Analytics.logEvent("rate_us_apple", parameters: nil)
                    SKStoreReviewController.requestReview()
                }
            )
        )
        present(alert, animated: true, completion: nil)
    }

    // MARK: Remote config

    private func setupRemoteConfigDefaults() {
        let defaultValues = [
            "showRateUsAlert": false as NSValue,
            "countFreeSearch": 20 as NSValue
        ]
        RemoteConfig.remoteConfig().setDefaults(defaultValues)
    }

    private func updateViewWithRCValues() {
        showRateUsAlertValue = RemoteConfig.remoteConfig().configValue(forKey: "showRateUsAlert").boolValue
        freeSearch = RemoteConfig.remoteConfig().configValue(forKey: "countFreeSearch").numberValue.intValue
    }

    // MARK: Showing notifications

    func showNotification(with text: String) {
        notification.animateView(text: text)
    }

    func showLoader() {
        isFirstShow = false
        view.addSubview(loading)
    }

    func hideLoading() {
        loading.removeFromSuperview()
    }

    // MARK: OBJC func 

    @objc func openHistory() {
        history?()
        isFirstShow = false
    }

    @objc func openSettings() {
        settings?()
        isFirstShow = false
    }
}

extension MainScreenController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else { return true }
        searchbar.resignFirstResponder()
        if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if DefaultsLayer().countFreeSearch < freeSearch || DefaultsLayer().isSubscribted {
                textSearch?(text)
                isFirstShow = true
            } else {
                subscription?()
            }

        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Проверить, что первый символ не является пробелом
        guard let text = textField.text else { return false }
        guard let textIsEmpty = textField.text?.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        if string == " " && textIsEmpty {
            return false
        }

        // Разбить текст на отдельные слова и получить их количество
        let words = (text as NSString).replacingCharacters(in: range, with: string).components(separatedBy: .whitespacesAndNewlines)
        let newWordCount = words.count

        // Проверить, не превышает ли новый текст максимальное количество слов
        if newWordCount > 32 {
            // Обрезать количество слов при вводе текста
            let wordsToKeep = 32
            let trimmedWords = words.prefix(wordsToKeep)
            let trimmedString = trimmedWords.joined(separator: " ")
            textField.text = trimmedString

            // Установить конечную позицию выделения в конец текста
            DispatchQueue.main.async {
                let newPosition = textField.endOfDocument
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }

            return true
        }

        return true
    }
}
