//
//  SelectImageSourceView.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 20.06.23.
//

import UIKit

class SelectImageSourceView: UIView {

    typealias VoidClosure = (() -> ())

    var library: VoidClosure?
    var camera: VoidClosure?
    var close: VoidClosure?

    private let mainLabel = UILabel()
    private let closeButton = UIButton()
    private let border = UIView()
    private let buttonStackView = UIStackView()
    private let useCameraButton = UIButton()
    private let useLibraryButton = UIButton()

    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }

    private func setup() {
        layer.cornerRadius = 16
        backgroundColor = .white
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        createMainLabel()
        createCloseButton()
        createLine()
        createButtonStack()
    }

    private func createMainLabel() {
        addSubview(mainLabel)

        mainLabel.text = L10n.Main.selectImageSource
        mainLabel.font = FontFamily.SFProDisplay.bold.font(size: 24)
        mainLabel.textColor = .black

        mainLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(18)
            make.leading.equalToSuperview().inset(24)
        }
    }

    private func createCloseButton() {
        addSubview(closeButton)

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
        addSubview(border)

        border.backgroundColor = Asset.Colors.appGray.color

        border.snp.makeConstraints { make in
            make.top.equalTo(mainLabel.snp.bottom).inset(-18)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
    }

    private func createButtonStack() {

        let backView = UIView()

        addSubview(backView)

        backView.addSubview(buttonStackView)

        buttonStackView.axis = .vertical
        buttonStackView.alignment = .fill
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 24

        buttonStackView.addArrangedSubview(useCameraButton)

        useCameraButton.backgroundColor = Asset.Colors.mainBlue.color
        useCameraButton.setImage(Asset.Assets.camera.image, for: .normal)
        useCameraButton.setTitle(L10n.Main.useCamera, for: .normal)
        useCameraButton.setTitleColor(.gray, for: .highlighted)
        useCameraButton.titleLabel?.font = FontFamily.SFProDisplay.bold.font(size: 20)
        useCameraButton.layer.cornerRadius = 8
        useCameraButton.titleEdgeInsets = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 0)

        useCameraButton.addTarget(self, action: #selector(openCamera), for: .touchUpInside)


        buttonStackView.addArrangedSubview(useLibraryButton)

        useLibraryButton.backgroundColor = .white
        useLibraryButton.setImage(Asset.Assets.library.image, for: .normal)
        useLibraryButton.setTitle(L10n.Main.useLibrary, for: .normal)
        useLibraryButton.setTitleColor(Asset.Colors.mainBlue.color, for: .normal)
        useLibraryButton.setTitleColor(.black, for: .highlighted)
        useLibraryButton.titleLabel?.font = FontFamily.SFProDisplay.bold.font(size: 20)
        useLibraryButton.layer.cornerRadius = 8
        useLibraryButton.layer.borderWidth = 2
        useLibraryButton.layer.borderColor = Asset.Colors.mainBlue.color.cgColor
        useLibraryButton.titleEdgeInsets = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 0)

        useLibraryButton.addTarget(self, action: #selector(openLibrary), for: .touchUpInside)


        backView.snp.makeConstraints { make in
            make.top.equalTo(border.snp.bottom)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }

        buttonStackView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.75)
            make.height.equalTo(140)
        }
    }

    func animate() {
        if isHidden {
            isHidden = false
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self else { return }
                self.frame.origin.y = safeAreaInsets.bottom + 10
            }
        } else {
            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let self else { return }
                self.frame.origin.y = UIScreen.main.bounds.height + 10
            } completion: { isFinish in
                if isFinish {
                    self.isHidden = true
                }
            }
        }
    }

    @objc func closeView() {
        close?()
    }

    @objc func openCamera() {
        useCameraButton.animate(closure: camera)
    }

    @objc func openLibrary() {
        useLibraryButton.animate(closure: library)
    }
}

extension UIButton {
    func animate(closure: (() -> ())?) {
        UIView.animate(withDuration: 0.1) { [weak self] in
            guard let self else { return }
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        } completion: { [weak self] isFinish in
            guard let self else { return }
            UIView.animate(withDuration: 0.05) { [weak self] in
                guard let self else { return }
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
            } completion: { isFinish in
                closure?()
            }
        }
    }
}
