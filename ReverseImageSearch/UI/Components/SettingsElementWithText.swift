//
//  SettingsElementWithText.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 27.06.23.
//

import UIKit

extension Notification.Name {
    static let shrinkSelected = Notification.Name("shrinkSelected")
}

class SettingsElementWithText: UIView {

    typealias VoidClosure = (() -> ())

    var onTapped: VoidClosure?

    private var text: String
    private var selected: Bool

    private let selectedMark = UIImageView()
    private let engineLabel = UILabel()

    init(text: String, selected: Bool) {
        self.text = text
        self.selected = selected
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
        layer.cornerRadius = 12
        backgroundColor = selected ? Asset.Colors.cellGray.color: .white
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

    private func createSelectedMarkView() {
        addSubview(selectedMark)

        selectedMark.image = selected ? Asset.Assets.mark.image: UIImage()

        selectedMark.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(13)
        }
    }

    private func createNotifictionLabel() {
        addSubview(engineLabel)

        engineLabel.text = text
        engineLabel.textColor = .black

        engineLabel.font = FontFamily.SFProDisplay.regular.font(size: 17)

        engineLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(8)
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
        NotificationCenter.default.post(
            name: .engineSelected,
            object: nil,
            userInfo: ["view": self, "selectedText": text]
        )

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
