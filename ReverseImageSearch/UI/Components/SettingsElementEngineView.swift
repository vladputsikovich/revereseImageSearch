//
//  SettingsElementView.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 26.06.23.
//

import UIKit

extension Notification.Name {
    static let engineSelected = Notification.Name("engineSelected")
}

class SettingsElementEngineView: UIView {

    typealias VoidClosure = (() -> ())

    var onTapped: VoidClosure?
    var showSubscriptionScreen: VoidClosure?

    private var searcher: Searcher
    private var selected: Bool
    private var isFree: Bool

    private let engineImage = UIImageView()
    private let selectedMark = UIImageView()
    private let proImage = UIImageView()
    private let engineLabel = UILabel()

    init(searcher: Searcher, selected: Bool, isFree: Bool, tag: Int) {
        self.searcher = searcher
        self.selected = selected
        self.isFree = isFree
        super.init(frame: .zero)
        self.tag = tag
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }

    private func setup() {
        layer.cornerRadius = 12
        backgroundColor = selected ? Asset.Colors.cellGray.color: .white
        createImageView()
        if !DefaultsLayer().isSubscribted && !isFree {
            createProImage()
        }
        createSelectedMarkView()
        createNotifictionLabel()
        addTapView()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(selectDefaultSearch),
            name: .engineSelected,
            object: nil
        )
    }

    private func createImageView() {
        addSubview(engineImage)

        engineImage.image = searcher.image()

        engineImage.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.centerY.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(13)
            make.leading.equalTo(16)
        }
    }
    
    private func createProImage() {
        addSubview(proImage)

        proImage.image = Asset.Assets.proSearch.image

        proImage.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
        }
    }

    private func createSelectedMarkView() {
        addSubview(selectedMark)

        selectedMark.image = selected ? Asset.Assets.mark.image: UIImage()

        selectedMark.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
        }
    }

    private func createNotifictionLabel() {
        addSubview(engineLabel)

        engineLabel.text = searcher.name()
        engineLabel.textColor = .black

        engineLabel.font = FontFamily.SFProDisplay.regular.font(size: 17)

        engineLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(engineImage.snp.trailing).inset(-8)
            make.trailing.equalTo(selectedMark.snp.leading).inset(-8)
        }
    }

    private func addTapView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapAction))
        addGestureRecognizer(tap)
    }

    // MARK: Actions

    @objc func tapAction(_ sender: UIButton) {
        //onTapped?()
        if isFree || DefaultsLayer().isSubscribted {
            NotificationCenter.default.post(
                name: .engineSelected,
                object: nil,
                userInfo: ["view": self, "selectedDefaultSearch": searcher.rawValue]
            )
        } else {
            showSubscriptionScreen?()
        }
    }

    @objc func selectDefaultSearch(_ notification: NSNotification) {
        guard let view = notification.userInfo?["view"] as? UIView else { return }
        if view == self {
            UIView.animate(withDuration: 0.1, delay: 0) { [weak self] in
                guard let self else { return }
                backgroundColor = Asset.Colors.cellGray.color
                selectedMark.image = Asset.Assets.mark.image
            }
        } else {
            UIView.animate(withDuration: 0.1, delay: 0) { [weak self] in
                guard let self else { return }
                backgroundColor = .white
                selectedMark.image = UIImage()
            }
        }
    }
}
