//
//  SearchResultController.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 20.06.23.
//
import GoogleMobileAds
import UIKit
import WebKit

class SearchResultController: UIViewController {

    // MARK: Properties

    typealias VoidClosure = (() -> ())

    var onFinish: VoidClosure?
    var subscription: VoidClosure?
    var textSearch: ((String) -> ())?
    var noInternetNotification: (() -> ())?

    private var refs: [URL]
    private var viewModel = SearchResultViewModel()
    private var dataSourse: [SearchCellModel] = []

    // MARK: UI elements

    private let screenTitle = UILabel()
    private let backButton = UIButton()
    private let refreshButton = UIButton()
    private var enginesCollectionView: UICollectionView?
    private let webViewsStack = UIStackView()
    private var interstitial: GADInterstitialAd?

    private var isAdLoaded = false {
        didSet {
            if isAdLoaded && !adIsShowed {
                showInterstitialAd()
                adIsShowed = true
            }
        }
    }

    private var adIsShowed = false

    // MARK: App lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !DefaultsLayer().isSubscribted {
            createInterstitialAd()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !NetworkMonitorObserver.shared.isConnected {
            noInternetNotification?()
        }
    }

    // MARK: Init

    init(refs: [URL]) {
        self.refs = refs
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Setup

    private func setup() {
        view.backgroundColor = .white
        dataSourse = viewModel.dataSourse
        createScreenTitle()
        createHistoryButton()
        createSettingsButton()
        createEngineSegments()
        createWebView()

        let indexPath = IndexPath(item: DefaultsLayer().defaultSearchEngine, section: 0)
        enginesCollectionView?.selectItem(
            at: indexPath,
            animated: true,
            scrollPosition: .centeredHorizontally
        )

        let count = DefaultsLayer().countFreeSearch
        DefaultsLayer().set(.countFreeSearch(count + 1))
    }

    // MARK: Creating UI elements

    private func createScreenTitle() {
        view.addSubview(screenTitle)

        screenTitle.text = L10n.App.searchResults
        screenTitle.font = FontFamily.SFProDisplay.bold.font(size: 20)
        screenTitle.textColor = .black

        screenTitle.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.centerX.equalToSuperview()
        }
    }

    private func createHistoryButton() {
        view.addSubview(backButton)

        backButton.setImage(Asset.Assets.back.image, for: .normal)

        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)

        backButton.snp.makeConstraints { make in
            make.centerY.equalTo(screenTitle.snp.centerY)
            make.leading.equalToSuperview().inset(view.frame.width / 15)
            make.width.height.equalTo(28)
        }
    }

    private func createSettingsButton() {
        view.addSubview(refreshButton)

        refreshButton.setImage(Asset.Assets.refresh.image, for: .normal)

        refreshButton.addTarget(self, action: #selector(reload), for: .touchUpInside)

        refreshButton.snp.makeConstraints { make in
            make.centerY.equalTo(screenTitle.snp.centerY)
            make.trailing.equalToSuperview().inset(view.frame.width / 15)
            make.width.height.equalTo(28)
        }
    }

    private func createEngineSegments() {
            
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.scrollDirection = .horizontal
        collectionViewFlowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        collectionViewFlowLayout.sectionInset = .zero
        
        enginesCollectionView = .init(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        guard let enginesCollectionView else { return }
        enginesCollectionView.contentOffset.x = 100
        enginesCollectionView.showsHorizontalScrollIndicator = false
        enginesCollectionView.backgroundColor = Asset.Colors.cellGray.color
        enginesCollectionView.layer.cornerRadius = 9
        enginesCollectionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        enginesCollectionView.isScrollEnabled = true
        enginesCollectionView.register(SearchEngineViewCell.self, forCellWithReuseIdentifier: SearchEngineViewCell.id)
        enginesCollectionView.dataSource = self
        enginesCollectionView.delegate = self
        
        view.addSubview(enginesCollectionView)
        
        enginesCollectionView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.height.equalTo(50)
            make.top.equalTo(screenTitle.snp.bottom).offset(15)
            make.trailing.equalToSuperview()
        }
    }

    private func createWebView() {
        view.addSubview(webViewsStack)

        webViewsStack.axis = .horizontal
        webViewsStack.spacing = 0
        webViewsStack.alignment = .fill
        webViewsStack.distribution = .fillEqually

        Searcher.allCases.forEach { searcher in
            let webView = WKWebView()
            webView.navigationDelegate = self
            webView.load(URLRequest(url: refs[searcher.rawValue]))
            webViewsStack.addArrangedSubview(webView)
        }

        webViewsStack.snp.makeConstraints { make in
            make.top.equalTo(enginesCollectionView?.snp.bottom ?? 50).offset(15)
            make.leading.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(Searcher.allCases.count)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }

    @objc func back() {
        webViewsStack.frame.origin.x = 0
        onFinish?()
    }

    @objc func reload() {
        if !NetworkMonitorObserver.shared.isConnected {
            noInternetNotification?()
        } else {
            webViewsStack.subviews.enumerated().forEach { index, subview in
                if let webView = subview as? WKWebView {
                    webView.load(URLRequest(url: refs[index]))
                }
            }
        }
    }

    func engineChanged(index: Int) {
        webViewsStack.frame.origin.x = -(view.frame.width * CGFloat(index))
        enginesCollectionView?.reloadData()
    }
    
    private func createInterstitialAd() {
        let request = GADRequest()
        var unitID = String()
        switch AppConfiguration.environment {
        case .debug, .testFlight:
            unitID = "ca-app-pub-3940256099942544/4411468910"
        case .appStore:
            unitID = "ca-app-pub-3863763835356682/1725173577"
        }
        
        GADInterstitialAd.load(withAdUnitID: unitID,
                               request: request,
                               completionHandler: { [self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            self.interstitial = ad
            self.interstitial?.fullScreenContentDelegate = self
            self.isAdLoaded = true
        })
    }

    private func showInterstitialAd() {
        if isAdLoaded && !DefaultsLayer().isSubscribted {
            interstitial?.present(fromRootViewController: self)
        } else {
            print("Interstitial ad is not loaded yet")
        }
    }
}

extension SearchResultController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSourse.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell?
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchEngineViewCell.id, for: indexPath) as? SearchEngineViewCell
        let cell1 = cell as? SearchEngineViewCell
        cell1?.config(model: dataSourse[indexPath.row])
        cell = cell1
        
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for  (index, _) in dataSourse.enumerated() {
            dataSourse[index].isSelected = false
        }

        print("indexPath \(indexPath)")
        
        dataSourse[indexPath.row].isSelected = true
        if DefaultsLayer().isSubscribted {
            engineChanged(index: indexPath.row)
        } else if Searcher.allCases[indexPath.row].isFree() {
            engineChanged(index: indexPath.row)
        } else {
            subscription?()
        }
    }
}

extension SearchResultController: GADFullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        interstitial = nil
        isAdLoaded = false
    }
}

extension SearchResultController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if !DefaultsLayer().successSearch {
            DefaultsLayer().set(.successSearch(true))
        }
    }
}

struct AlertShower {
    static func showAlert(title: String, message: String) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: L10n.App.ok, style: .default, handler: nil)
        alertController.addAction(okAction)
        return alertController
    }

    static func showAlert(title: String, message: String, actions: [UIAlertAction]) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { action in
            alertController.addAction(action)
        }
        return alertController
    }
}
