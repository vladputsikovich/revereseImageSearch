//
//  NotificationView.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 31.05.23.
//

import UIKit

class NotificationView: UIView {

    private let notificationLabel = UILabel()

    private static var isShowed = false

    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }

    private func setup() {
        layer.cornerRadius = 20
        backgroundColor = .black.withAlphaComponent(0.8)
        createNotifictionLabel()
    }

    private func createNotifictionLabel() {
        addSubview(notificationLabel)

        notificationLabel.textColor = .white
        notificationLabel.font = FontFamily.SFProDisplay.regular.font(size: 18)
        notificationLabel.numberOfLines = 0
        notificationLabel.textAlignment = .center

        notificationLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }

    func animateView(text: String) {
        if !NotificationView.isShowed {
            notificationLabel.text = text
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                guard let self = self else { return }
                self.frame.origin.y = safeAreaInsets.top + 10
                self.isHidden = false
                NotificationView.isShowed = true
            }) { [weak self] _ in
                guard let self = self else { return }
                UIView.animate(withDuration: 0.15, delay: 1, animations: {
                    self.frame.origin.y = -100
                }) { _ in
                    self.isHidden = true
                    NotificationView.isShowed = false
                }
            }
        }
    }
}

