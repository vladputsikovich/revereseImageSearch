//
//  MainScreenCoordinator.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 19.06.23.
//

import UIKit
import AVFoundation
import CropViewController
import FirebaseStorage

class MainScreenCoordinator: NSObject, Coordinator {
    var childCoordinators: [Coordinator] = []

    private let uploadService = UploadService()

    typealias VoidClosure = (() -> ())

    var onFinish: VoidClosure?
    var camera: VoidClosure?
    var gallery: VoidClosure?
    var subscription: VoidClosure?
    var textSearch: ((String) -> ())?

    private var showLoading: VoidClosure?
    private var hideLoading: VoidClosure?
    private var error: ((String) -> ())?
    private var urlError: ((String) -> ())?

    unowned let navigationController: UINavigationController

    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let main = MainScreenController()

        main.onFinish = { [weak self] in
            guard let self else { return }
            self.onFinish?()
        }
        main.textSearch = { [weak self] text in
            guard let self else { return }
            self.saveWordSearch(text: text)
            self.search(refs: createTextSearchRequest(text: text))
        }
        main.camera = { [weak self] in
            guard let self else { return }
            self.openCamera()
        }

        main.gallery = { [weak self] in
            guard let self else { return }
            self.openGallery()
        }

        main.history = { [weak self] in
            guard let self else { return }
            self.openHistory()
        }

        main.settings = { [weak self] in
            guard let self else { return }
            self.openSettings()
        }

        main.clipboard = { [weak self] in
            guard let self else { return }
            self.getImageFromPasteboard(completion: { result in
                switch result {
                case .success(let success):
                    self.workWithImage(image: success)
                case .failure(let failure):
                    main.showNotification(with: L10n.App.pasteboardDoesContainImage)
                }
            })
        }

        main.urlPaste = { [weak self] in
            guard let self else { return }
            if let url = UIPasteboard.general.url {
                downloadImageFromURL(url)
            } else {
                main.showNotification(with: L10n.App.pasteboardDoesContainUrl)
            }
        }

        main.subscription = { [weak self] in
            guard let self else { return }
            self.subscription?()
        }

        showLoading = {
            main.showLoader()
        }

        hideLoading = {
            main.hideLoading()
        }

        error = { text in
            if !NetworkMonitorObserver.shared.isConnected {
                main.hideLoading()
                main.present(
                    AlertShower.showAlert(
                        title: L10n.App.sorry,
                        message: L10n.App.connectionTryAgain),
                    animated: true
                )
            }
        }

        urlError = { text in
            main.showNotification(with: text)
        }

        navigationController.dismiss(animated: false)
        navigationController.setViewControllers([main], animated: false)
    }

    // MARK: Navigation

    private func openHistory() {
        let history = SearchHistoryCoordinator(navigationController: navigationController)
        childCoordinators.append(history)

        history.onFinish = { [weak self] in
            guard let self else { return }
            self.navigationController.popViewController(animated: true)
        }

        history.subscription = { [weak self] in
            guard let self else { return }
            self.subscription?()
        }

        history.imageSearch = { [weak self] image in
            guard let self else { return }
            var storageImage = UIImage()
            getImageFromURL(image.fileUrl) { result in
                switch result {
                case .success(let success):
                    self.uploadImageToFirebaseStorage(success, withPath: "\(UUID.init()).jpeg") { [weak self] result in
                        guard let self else { return }
                        switch result {
                        case .success(let success):
                            DispatchQueue.main.async {
                                self.search(refs: self.createImageSearchRequest(imageUrl: success.absoluteString))
                            }
                        case .failure(let failure):
                            self.error?(failure.localizedDescription)
                        }
                    }
                case .failure(let failure):
                    print(failure)
                }
            }

            var newDateImage = image
            newDateImage.updateRecord(
                search: ImageSearch(
                    id: image.id,
                    name: image.name,
                    fileUrl: image.fileUrl,
                    date: Date(),
                    searcher: image.searcher
                )
            )
        }

        history.wordSearch = { [weak self] word in
            guard let self else { return }
            self.search(refs: createTextSearchRequest(text: word.text))

            var newWordSearch = word
            newWordSearch.updateRecord(
                search: WordSearch(
                    id: word.id,
                    text: word.text,
                    date: Date(),
                    searcher: word.searcher
                )
            )
        }

        history.start()
    }

    private func openSettings() {
        let settings = SettingsCoordinator(navigationController: navigationController)
        childCoordinators.append(settings)

        settings.onFinish = { [weak self] in
            guard let self else { return }
            self.navigationController.popViewController(animated: true)
        }

        settings.subscription = { [weak self] in
            guard let self else { return }
            self.subscription?()
        }

        settings.start()
    }

    // MARK: Getting image from pasteboard and URL

    private func getImageFromPasteboard(completion: @escaping (Result<UIImage, Error>) -> Void) {
        // Проверяем, содержит ли буфер обмена изображение
        guard let image = UIPasteboard.general.image else {
            // Если нет, то вызываем completion handler с ошибкой
            let error = NSError(
                domain: "Ошибка",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Изображение не найдено в буфере обмена"]
            )
            completion(.failure(error))
            return
        }

        // Если да, то вызываем completion handler с полученным изображением
        completion(.success(image))
    }

    private func downloadImageFromURL(_ url: URL) {
        getImageFromURL(url) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self.workWithImage(image: image)
                }
            case .failure(let error):
                // Произошла ошибка при загрузке изображения, выводим сообщение об ошибке
                urlError?(error.localizedDescription)
            }
        }
    }

    private func getImageFromURL(_ url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                // Если произошла ошибка при загрузке данных, вызываем completion handler с ошибкой
                let error = error ?? NSError(domain: "Ошибка", code: -1, userInfo: [NSLocalizedDescriptionKey: L10n.App.failedLoad])
                completion(.failure(error))
                return
            }

            guard let image = UIImage(data: data) else {
                // Если данные не удалось преобразовать в изображение, вызываем completion handler с ошибкой
                let error = NSError(domain: "Ошибка", code: -1, userInfo: [NSLocalizedDescriptionKey: L10n.App.failedConvert])
                completion(.failure(error))
                return
            }

            // Если загрузка и преобразование данных прошли успешно, вызываем completion handler с полученным изображением
            completion(.success(image))
        }

        task.resume()
    }

    // MARK: Creating search request URL

    private func createTextSearchRequest(text: String) -> [URL] {
        var urls: [URL] = []
        Searcher.allCases.forEach { searcher in
            var component = URLComponents()
            component.scheme = "https"
            component.host = searcher.hostWords()
            component.path = searcher.pathWords()

            component.queryItems = searcher.queryItemsWords(text: text)

            guard let componentUrl = component.url else { return }
            urls.append(componentUrl)
        }
        
        urls.swapAt(DefaultsLayer().defaultSearchEngine, 0)
        return urls
    }

    private func createImageSearchRequest(imageUrl: String) -> [URL] {
        var urls: [URL] = []
        Searcher.allCases.forEach { searcher in
            var component = URLComponents()
            component.scheme = "https"
            component.host = searcher.hostImage()
            component.path = searcher.pathImage()

            component.queryItems = searcher.queryItemsImage(imageUrl: imageUrl)

            guard let componentUrl = component.url else { return }
            urls.append(componentUrl)
        }
        
        urls.swapAt(DefaultsLayer().defaultSearchEngine, 0)
        return urls
    }

    // MARK: Upload on firebase

    private func uploadImageToFirebaseStorage(_ image: UIImage, withPath path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 1) else {
            let error = NSError(domain: "Error converting image to JPEG data", code: -1, userInfo: nil)
            completion(.failure(error))
            return
        }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        let storageRef = Storage.storage().reference(withPath: path)
        let uploadTask = storageRef.putData(imageData, metadata: metadata) { (metadata, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                storageRef.downloadURL { (url, error) in
                    if let error = error {
                        completion(.failure(error))
                    } else if let url = url {
                        completion(.success(url))
                    } else {
                        let error = NSError(domain: "Error getting download URL after image upload", code: -1, userInfo: nil)
                        completion(.failure(error))
                    }
                }
            }
        }

        uploadTask.observe(.progress) { snapshot in
            let percentComplete = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount) * 100.0
            print("Upload progress: \(percentComplete)%")
        }
    }

    // MARK: Open camera and gallery

    private func openCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = false
        vc.delegate = self
        checkCameraAccess()
        navigationController.present(vc, animated: true)
    }

    private func openGallery() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.allowsEditing = false
        vc.delegate = self
        navigationController.present(vc, animated: true)
    }

    private func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
    }

    private func showNoCameraAccessAlert() {
        // Camera access is denied by the user
        let settings = UIAlertAction(title: L10n.Settings.settings, style: .default) {[weak self] _ in
            guard let self else { return }
            self.openAppSettings()
        }

        let cancel = UIAlertAction(title: L10n.App.cancel, style: .cancel)

        let alert = AlertShower.showAlert(
            title: L10n.App.sorry,
            message: L10n.App.imageAccess,
            actions: [cancel, settings]
        )
        navigationController.present(alert, animated: true)
    }

    // MARK: Check camera access

    private func checkCameraAccess() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .authorized:
            print("Camera access authorized")
        case .denied:
            showNoCameraAccessAlert()
        case .restricted:
            // Camera access is restricted (e.g., due to parental controls)
            print("Camera access restricted")
        case .notDetermined:
            // Camera access authorization status has not been determined yet
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let self else { return }
                if granted {
                    // Camera access is authorized
                    print("Camera access authorized")
                } else {
                    // Camera access is denied
                    self.showNoCameraAccessAlert()
                }
            }
        @unknown default:
            // Handle future cases if necessary
            break
        }
    }

    // MARK: Save image on temp memory

    private func saveImage(image: UIImage) -> URL? {
        let directoryPath =  NSHomeDirectory().appending("/Documents/")
        if !FileManager.default.fileExists(atPath: directoryPath) {
            do {
                try FileManager.default.createDirectory(at: NSURL.fileURL(withPath: directoryPath), withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
            }
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddhhmmss"

        let filename = dateFormatter.string(from: Date()).appending(".jpeg")
        let filepath = directoryPath.appending(filename)
        let url = NSURL.fileURL(withPath: filepath)
        do {
            // QUALITY
            try image.jpegData(compressionQuality: Quality.allCases[DefaultsLayer().imageQuality].compressorValue())?.write(to: url, options: .atomic)
            return url

        } catch {
            print(error)
            print("file cant not be save at path \(filepath), with error : \(error)");
            return nil
        }
    }

    // MARK: SAVE AND SEARCH

    private func workWithImage(image: UIImage) {
        if DefaultsLayer().imageEditor {
            showCrop(image: image)
        } else {
            changeImage(image: image)
        }
    }

    private func changeImage(image: UIImage) {
        showLoading?()

        var changedImage = image
        if DefaultsLayer().imageShrinkSize != 0 {
            guard let resizedImage = resizeImageByLargerSide(
                image: image,
                maxSize: CGFloat(Shrink.allCases[DefaultsLayer().imageShrinkSize].size()) / 2
            ) else { return }
            changedImage = resizedImage
        }

        guard let imageUrl = saveImage(image: changedImage) as? URL else { return }

        uploadImageToFirebaseStorage(changedImage, withPath: "\(UUID.init()).jpeg") { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let success):
                DispatchQueue.main.async {
                    self.search(refs: self.createImageSearchRequest(imageUrl: success.absoluteString))
                }
            case .failure(let failure):
                self.error?(failure.localizedDescription)
            }
        }

        saveImageSearch(url: imageUrl)
    }

    private func saveImageSearch(url: URL) {
        let imageSearch = ImageSearch(
            id: UUID.init(),
            name: url.lastPathComponent,
            fileUrl: url,
            date: Date(),
            searcher: Searcher.allCases[DefaultsLayer().defaultSearchEngine]
        )

        imageSearch.saveNote()
    }

    private func saveWordSearch(text: String) {
        let wordSearch = WordSearch(
            id: UUID.init(),
            text: text,
            date: Date(),
            searcher: Searcher.allCases[DefaultsLayer().defaultSearchEngine]
        )
        wordSearch.saveNote()
    }

    private func search(refs: [URL]) {
        let results = SearchResultCoordinator(navigationController: navigationController)
        childCoordinators.append(results)

        results.onFinish = { [weak self] in
            guard let self else { return }
            self.navigationController.popViewController(animated: true)
        }

        results.subscription = {  [weak self] in
            guard let self else { return }
            self.subscription?()
        }

        hideLoading?()

        results.openSearchResults(with: refs)
    }

    // MARK: Resizing

    private func resizeImageByLargerSide(image: UIImage, maxSize: CGFloat) -> UIImage? {
        let size = image.size
        let aspectRatio = size.width / size.height

        var newSize: CGSize
        if size.width > size.height {
            newSize = CGSize(width: maxSize, height: maxSize / aspectRatio)
        } else {
            newSize = CGSize(width: maxSize * aspectRatio, height: maxSize)
        }

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}

// MARK: UINavigationControllerDelegate, UIImagePickerControllerDelegate, CropViewControllerDelegate

extension MainScreenCoordinator: UINavigationControllerDelegate, UIImagePickerControllerDelegate, CropViewControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        guard let image = info[.originalImage] as? UIImage  else {
            print("NO IMAGE")
            return
        }

        picker.dismiss(animated: true)
        workWithImage(image: image)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func showCrop(image: UIImage) {
        let cropController = CropViewController(croppingStyle: .default, image: image)
        cropController.aspectRatioPreset = .presetSquare
        cropController.toolbarPosition = .bottom
        cropController.doneButtonColor = .white
        cropController.cancelButtonColor = .white
        cropController.doneButtonTitle = L10n.App.search
        cropController.cancelButtonTitle = L10n.App.cancel

        cropController.delegate = self

        cropController.modalTransitionStyle = .crossDissolve

        navigationController.present(cropController, animated: true)
    }

    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true)
    }

    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true)
        changeImage(image: image)
    }
}
