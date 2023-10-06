//
//  SearchByImageCell.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 30.06.23.
//

import UIKit

class SearchByImageCell: UITableViewCell {

    var remove: (() -> ())?

    // MARK: Ui elements

    private let backView = UIView()
    private let mainText = UILabel()
    private let searchEngine = UILabel()
    private let image = UIImageView()
    private let removeButton = UIButton()

    // MARK: Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    override func prepareForReuse() {
//        super.prepareForReuse()
//        mainText.text = nil
//        searchEngine.text = nil
//    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    // MARK: Setup

    private func setup() {
        selectionStyle = .none
        backView.backgroundColor = Asset.Colors.cellGray.color

        backView.layer.cornerRadius = 16

        sendSubviewToBack(contentView)

        createBackgroundView()
        createEngineImage()
        createRemoveButton()
        createLabels()
    }

    // MARK: Create UI elements


    private func createBackgroundView() {
        addSubview(backView)

        backView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.leading.trailing.equalToSuperview()
        }
    }

    private func createEngineImage() {
        backView.addSubview(image)

        image.layer.masksToBounds = true

        image.layer.cornerRadius = 6
        image.backgroundColor = .white

        image.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(16)
            make.height.width.equalTo(64)
        }
    }

    private func createRemoveButton() {
        backView.addSubview(removeButton)

        removeButton.setImage(Asset.Assets.closeRound.image, for: .normal)
        removeButton.addTarget(self, action: #selector(removeCell), for: .touchUpInside)

        removeButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
            make.height.width.equalTo(30)
        }
    }

    private func createLabels() {
        let labelStack = UIStackView()
        backView.addSubview(labelStack)

        labelStack.axis = .vertical
        labelStack.alignment = .fill
        labelStack.spacing = 4
        labelStack.distribution = .equalSpacing

        labelStack.addArrangedSubview(mainText)

        mainText.font = FontFamily.SFProDisplay.medium.font(size: 16)
        mainText.textColor = .black

        labelStack.addArrangedSubview(searchEngine)

        searchEngine.font = FontFamily.SFProDisplay.regular.font(size: 14)
        searchEngine.textColor = .black.withAlphaComponent(0.6)

        labelStack.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(image.snp.trailing).inset(-12)
            make.trailing.equalTo(removeButton.snp.leading).inset(-12)
            make.top.bottom.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
    }

    // MARK: Config

    func configOf(search: ImageSearch?, sender: Int, wordSearch: WordSearch?) {
        if sender == 1 {
            mainText.text = wordSearch?.text
            searchEngine.text = wordSearch?.searcher.name()
            image.image = wordSearch?.searcher.image()
            image.layer.cornerRadius = 26
        } else {
            image.layer.cornerRadius = 6
            guard let search else {return}
            mainText.text = search.name
            searchEngine.text = search.searcher.name()
            print(search.fileUrl)
            if let imageData = NSData(contentsOf: search.fileUrl) {
                let searchImage = UIImage(data: imageData as Data)
                image.image = searchImage
            }
        }
    }

    @objc func removeCell() {
        removeButton.setImage(Asset.Assets.closeRound.image.withTintColor(.black), for: .disabled)
        remove?()
    }
}
