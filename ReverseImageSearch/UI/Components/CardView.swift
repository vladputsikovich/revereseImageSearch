//
//  CardView.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 20.06.23.
//

import UIKit

class CardView: UIView {

    // MARK: Properties

    var onTapped: (() -> Void)?

    private var text: String
    private var cardDescription: String
    private var image: UIImage
    private var backColor: UIColor
    private var isFree: Bool

    private let mainLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let imageView = UIImageView()
    private let proImageView = UIImageView()

    init(text: String, cardDescription: String, image: UIImage, backColor: UIColor, isFree: Bool) {
        self.text = text
        self.cardDescription = cardDescription
        self.image = image
        self.backColor = backColor
        self.isFree = isFree
        super.init(frame: .zero)
        checkPro()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    
    private func checkPro() {
        if DefaultsLayer().isSubscribted {
            isFree = true
        }
    }

    private func setup() {
        layer.cornerRadius = 16
        backgroundColor = backColor.withAlphaComponent(isFree ? 0.3 : 0.2)
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 0.33
        createMainLabel()
        createDescriptionLabel()
        createImageView()
        createProImageView()
        addTapView()
    }

    private func createMainLabel() {
        addSubview(mainLabel)

        mainLabel.text = text
        mainLabel.font = FontFamily.SFProDisplay.bold.font(size: 20)
        mainLabel.textColor = .black
        mainLabel.alpha = isFree ? 1 : 0.3

        mainLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.equalToSuperview().inset(16)
        }

    }

    private func createDescriptionLabel() {
        addSubview(descriptionLabel)

        descriptionLabel.text = cardDescription
        descriptionLabel.font = FontFamily.SFProDisplay.regular.font(size: 16)
        descriptionLabel.textColor = .black
        descriptionLabel.alpha = isFree ? 0.6 : 0.3

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(mainLabel.snp.bottom).inset(-4)
            make.leading.equalToSuperview().inset(16)
        }
    }

    private func createImageView() {

        addSubview(imageView)

        imageView.image = image

        imageView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }

    private func createProImageView() {
        addSubview(proImageView)
        
        proImageView.image = Asset.Assets.proMain.image
        proImageView.layer.maskedCorners = [.layerMaxXMaxYCorner]
        proImageView.layer.cornerRadius = 16
        proImageView.clipsToBounds = true
        proImageView.isHidden = isFree
        
        proImageView.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(110)
        }
    }
    
    private func addTapView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapAction))
        addGestureRecognizer(tap)
    }

    // MARK: Actions

    @objc func tapAction(_ sender: UIButton) {
        onTapped?()
    }
}
