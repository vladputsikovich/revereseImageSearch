//
//  ContinueButton.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 31.05.23.
//

import UIKit

class ContinueButton: UIButton {

    // MARK: Properties

    private var buttonText: String

    public var onTapped: (() -> ())?

    // MARK: Init

    init(buttonText: String) {
        self.buttonText = buttonText
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
        backgroundColor = Asset.Colors.mainBlue.color
        layer.cornerRadius = frame.height / 2
        setTitle(buttonText, for: .normal)
        titleLabel?.font = FontFamily.SFProDisplay.bold.font(size: 20)
        titleLabel?.textColor = .white
        titleLabel?.textAlignment = .center
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        addTarget(self, action: #selector(tapOnButton), for: .touchUpInside)
    }

    private func animateButton() {
        UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        } completion: { [weak self] _ in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: { [weak self] _ in
                guard let self = self else { return }
                self.onTapped?()
            })
        }
    }

    // MARK: Actions

    @objc func tapOnButton() {
        animateButton()
    }
}
