//
//  UploadService.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 23.06.23.
//

import Foundation
import Uploadcare

class UploadService {

    var urlStringClosure: ((String) -> ())?

    func upload(imageURL: URL) {
        UploadCareImage().uploadFileFromURL(imageURL) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let success):
                urlStringClosure?("\(UploadCareImage().baseUrl)\(success.uuid)/")
            case .failure(let failure):
                print(failure)
            }
        }
    }
}

final class UploadCareImage: ObservableObject {
    @Published var progressValue: Double = 0.0 // this is for progress if needed
    @Published var currentTask: UploadTaskResumable? // this is for (like the name said) Resume and Stop de upload
    final var baseUrl: String = "https://ucarecdn.com/"

    func uploadFileFromURL(_ url: URL, completionHandler: @escaping (Result<UploadedFile, UploadError>) -> Void) {
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch let error {
            print(error)
            return
        }

        self.progressValue = 0
        let filename = url.lastPathComponent

        let onProgress: (Double) -> Void = { (progress) in
            DispatchQueue.main.async { [weak self] in
                self?.progressValue = progress
            }
        }

        self.currentTask = UploadCareAPIStore.shared.uploadFile(data, withName: "image-\(Date())", store: .doNotStore, onProgress, { result in
            completionHandler(result)
        }) as? UploadTaskResumable
    }
}

public class UploadCareAPIStore {
    public static let shared = Uploadcare(
        withPublicKey: "e8a63ff6edf6809fee85"
    )
}
