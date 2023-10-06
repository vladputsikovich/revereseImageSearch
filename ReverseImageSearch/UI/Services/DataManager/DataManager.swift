//
//  DataManager.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 6.07.23.
//

import Foundation

class DataManager {

    //get document derictory

    static func getDocumentDirectory () -> URL {
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            return url
        } else {
            fatalError("Unable to access docement directory")
        }
    }

    //save any codable Object

    static func save<T: Encodable>(_ object: T, with fileName: String) {
        let url = getDocumentDirectory().appendingPathComponent(fileName, isDirectory: false)

        let encoder = JSONEncoder()


        do {
            let data = try encoder.encode(object)
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    // load any codable object

    static func load<T: Decodable>(_ filename: String, with type: T.Type) -> T {
        let url = getDocumentDirectory().appendingPathComponent(filename, isDirectory: false)
        if !FileManager.default.fileExists(atPath: url.path) {
            fatalError("file not found at path \(url.path)")
        }

        if let data = FileManager.default.contents(atPath: url.path) {
            do {
                let model = try JSONDecoder().decode(type, from: data)
                return model

            } catch {
                fatalError(error.localizedDescription)
            }
        } else {
            fatalError("Data unavailable at path \(url.path)")
        }
    }

    // load data from a file

    static func loadData(_ filename: String) -> Data? {
        let url = getDocumentDirectory().appendingPathComponent(filename, isDirectory: false)
        if !FileManager.default.fileExists(atPath: url.path) {
            fatalError("file not found at path \(url.path)")
        }
        if let data = FileManager.default.contents(atPath: url.path) {
            return data
        } else {
            fatalError("Data unavailable at path \(url.path)")
        }
    }

    // load files from derictiory

    static func loadAll<T: Decodable>(_ type: T.Type) -> [T] {
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: getDocumentDirectory().path)

            var modelObject = [T]()

            var findString = "\(T.self)" == "ImageSearch" ? "image": "word"
            
            files.forEach { fileName in
                print("file name \(fileName)")
                //delete(fileName)
                if !fileName.contains(".") && !fileName.contains("SavedFiles") && fileName.contains(findString) {
                    modelObject.append(load(fileName, with: type))
                }
            }

            return modelObject
        } catch {
            fatalError("Could not load any files")
        }
    }

    // delete a file

    static func delete(_ fileName: String) {
        let url = getDocumentDirectory().appendingPathComponent(fileName, isDirectory: false)

        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}
