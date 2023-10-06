//
//  Search.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 6.07.23.
//

import Foundation

struct WordSearch: Codable, Equatable {
    var id: UUID
    var text: String
    var date: Date
    var searcher: Searcher

    func saveNote() {
        DataManager.save(self, with: "word-\(id.uuidString)")
    }

    func removeNote() {
        DataManager.delete("word-\(id.uuidString)")
    }

    mutating func updateRecord(search: WordSearch) {
        self.text = search.text
        self.date = search.date
        self.searcher = search.searcher
        DataManager.save(self, with: "word-\(id.uuidString)")
    }
}

struct ImageSearch: Codable {
    var id: UUID
    var name: String
    var fileUrl: URL
    var date: Date
    var searcher: Searcher

    func saveNote() {
        DataManager.save(self, with: "image-\(id.uuidString)")
    }

    func removeNote() {
        DataManager.delete("image-\(id.uuidString)")
        DataManager.delete(fileUrl.lastPathComponent)
    }

    mutating func updateRecord(search: ImageSearch) {
        self.name = search.name
        self.fileUrl = search.fileUrl
        self.date = search.date
        self.searcher = search.searcher

        DataManager.save(self, with: "image-\(id.uuidString)")
    }
}
