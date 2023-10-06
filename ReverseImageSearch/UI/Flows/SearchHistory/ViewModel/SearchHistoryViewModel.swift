//
//  SearchHistoryViewModel.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 6.07.23.
//

import Foundation

class SearchHistoryViewModel {
    weak var view: SearchHistoryInterface?

    func getImageSearch() {
        let search = DataManager.loadAll(ImageSearch.self).sorted {
            $0.date > $1.date
        }
        view?.getImageSearch(search: search)
    }

    func getWordsSearch() {
        let search = DataManager.loadAll(WordSearch.self).sorted {
            $0.date > $1.date
        }
        view?.getWordsSearch(search: search)
    }
}
