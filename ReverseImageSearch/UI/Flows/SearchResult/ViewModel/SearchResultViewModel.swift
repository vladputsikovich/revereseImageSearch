//
//  SearchResultViewModel.swift
//  ReverseImageSearch
//
//  Created by Tomashchik Daniil on 12.07.23.
//

import Foundation

class SearchResultViewModel {
    
    var dataSourse: [SearchCellModel] = []
    private var selectedEngine = DefaultsLayer().defaultSearchEngine
    
    init() {
        setUpDataSourse()
    }
    
    private func setUpDataSourse() {
        Searcher.allCases.enumerated().forEach { index, element in
            dataSourse.append(.init(image:
                                        DefaultsLayer().isSubscribted ?  element.image() : element.isFree() ?  element.image() : Asset.Assets.pro.image,
                                    text: element.name(),
                                    isSelected: false))
        }
        
        dataSourse.swapAt(selectedEngine, 0)
        dataSourse[0].isSelected = true
    }
}
