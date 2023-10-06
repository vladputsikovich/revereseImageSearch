//
//  SearchByWordCell.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 21.06.23.
//

import UIKit

class SearchByWordCell: UITableViewCell {

    var remove: (() -> ())?

    // MARK: Ui elements

    private let backView = UIView()
    private let mainText = UILabel()
    private let searchEngine = UILabel()
    private let engineImage = UIImageView()
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
        //contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0))
    }

    // MARK: Setup

    private func setup() {
        selectionStyle = .none
        sendSubviewToBack(contentView)
        backView.backgroundColor = Asset.Colors.cellGray.color

        backView.layer.cornerRadius = 16
        
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
        backView.addSubview(engineImage)

        engineImage.layer.cornerRadius = 26
        engineImage.backgroundColor = .white

        engineImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(16)
            make.height.width.equalTo(52)
        }
    }

    private func createRemoveButton() {
        backView.addSubview(removeButton)

        removeButton.setImage(Asset.Assets.closeRound.image, for: .normal)
        removeButton.setImage(Asset.Assets.closeRound.image.withRenderingMode(.alwaysTemplate).withTintColor(.black), for: .selected)
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
            make.leading.equalTo(engineImage.snp.trailing).inset(-12)
            make.trailing.equalTo(removeButton.snp.leading).inset(-12)
            make.top.bottom.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }

    }

    // MARK: Config

    func configOf(search: WordSearch) {
        mainText.text = search.text
        searchEngine.text = search.searcher.name()
        engineImage.image = search.searcher.image()
    }

    @objc func removeCell() {
        remove?()
    }
}
