//
//  SearchEngineViewCell.swift
//  ReverseImageSearch
//
//  Created by Tomashchik Daniil on 12.07.23.
//

import UIKit

final class SearchEngineViewCell: UICollectionViewCell {
    static let id = "SearchEngineViewCell"
    
    private let titleLabel = UILabel()
    private let imageV = UIImageView()
    private let backView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        contentView.layer.cornerRadius = 7
        contentView.backgroundColor = .clear
        
        createBackView()
        createImageView()
        createTitleLabel()
    }
     
    private func createBackView() {
        contentView.addSubview(backView)
        backView.layer.cornerRadius = 7
        backView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(2)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-2)
        }
    }
    
    private func createTitleLabel() {
        backView.addSubview(titleLabel)
        titleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageV.snp.trailing).offset(5)
            make.centerY.equalTo(backView)
            make.trailing.equalTo(backView).offset(-10)
        }
    }
    
    private func createImageView() {
        backView.addSubview(imageV)
        
        imageV.snp.makeConstraints { make in
            make.leading.equalTo(backView).offset(5)
            make.centerY.equalTo(backView)
            make.height.width.equalTo(30)
        }
    }
    
    func config(model: SearchCellModel) {
        backView.backgroundColor = model.isSelected ? .white : .clear
        titleLabel.text = model.text
        imageV.image = model.image
    }
}

struct SearchCellModel {
    let image: UIImage
    let text: String
    var isSelected: Bool
}
