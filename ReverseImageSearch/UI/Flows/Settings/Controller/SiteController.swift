//
//  SiteController.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 23.06.23.
//

import UIKit
import WebKit
import SnapKit

class SiteController: UIViewController, WKNavigationDelegate {

    // MARK: Properties

    var onBackTapped: (() -> ())?
    private let urlString: String
    private let webView = WKWebView()
    private let cancelCrossButton = UIButton()

    // MARK: Init

    init(urlString: String) {
        self.urlString = urlString
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View lifecycle

    override func loadView() {
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: Setup

    private func setup() {
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        webView.load(request)
        webView.allowsBackForwardNavigationGestures = true
        createCrossImageView()
        definesPresentationContext = true
    }

    private func createCrossImageView() {
        webView.addSubview(cancelCrossButton)

        cancelCrossButton.setImage(Asset.Assets.close.image, for: .normal)
        cancelCrossButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)

        cancelCrossButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(20)
            make.trailing.equalToSuperview().inset(20)
        }
    }

    @objc func cancel() {
        onBackTapped?()
    }
}

// MARK: WKWebView

extension WKWebView {
    func load(_ urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            load(request)
        }
    }
}

