//
//  SearchController.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 21.06.23.
//

import UIKit
import Firebase

fileprivate struct Constant {
    static let cellIdentifacatorWords = "cellIdWrd"
    static let cellIdentifacatorImages = "cellIdIm"
}

protocol SearchHistoryInterface: AnyObject {
    func getImageSearch(search: [ImageSearch])
    func getWordsSearch(search: [WordSearch])
}

class SearchHistoryController: UIViewController {

    // MARK: Properties

    typealias VoidClosure = (() -> ())

    var onFinish: VoidClosure?
    var subscription: VoidClosure?
    var wordSearchClosure: ((WordSearch) -> ())?
    var imageSearchClosure: ((ImageSearch) -> ())?

    private var wordSearchSorted: [(Date, [WordSearch])] = []
    private var imageSearchSorted: [(Date, [ImageSearch])] = []

    private var viewModel: SearchHistoryViewModel
    
    private var sender = 0
    private var freeSearch = 20

    private var wordSearch: [WordSearch] = []
    private var imageSearch: [ImageSearch] = []

    // MARK: UI elements

    private let screenTitle = UILabel()
    private let backButton = UIButton()
    private let trashButton = UIButton()
    private let typeSearch = UISegmentedControl(items: [L10n.History.byImages, L10n.History.byWord])
    private let byImageTable = UITableView()
    lazy var loading = LoadingScreen(frame: UIScreen.main.bounds)

    // MARK: App lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        loading.removeFromSuperview()
    }

    // MARK: Init

    init(viewModel: SearchHistoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Setup

    private func setup() {
        setupRemoteConfigDefaults()
        updateViewWithRCValues()

        view.backgroundColor = .white
        viewModel.getImageSearch()
        viewModel.getWordsSearch()
        createScreenTitle()
        createBackButton()
        createTrashButton()
        createTypeSearchSegments()
        createTableStackView()

        wordSearchSorted = sortedWordSearchesByDate(wordSearches: wordSearch)
        imageSearchSorted = sortedImageSearchesByDate(imageSearches: imageSearch)
    }

    // MARK: Creating UI elements

    private func createScreenTitle() {
        view.addSubview(screenTitle)

        screenTitle.text = L10n.History.searchHistory
        screenTitle.font = FontFamily.SFProDisplay.bold.font(size: 20)
        screenTitle.textColor = .black

        screenTitle.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(10)
            make.centerX.equalToSuperview()
        }
    }

    private func createBackButton() {
        view.addSubview(backButton)

        backButton.setImage(Asset.Assets.back.image, for: .normal)

        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)

        backButton.snp.makeConstraints { make in
            make.centerY.equalTo(screenTitle.snp.centerY)
            make.leading.equalToSuperview().inset(view.frame.width / 15)
            make.width.height.equalTo(28)
        }
    }

    private func createTrashButton() {
        view.addSubview(trashButton)

        trashButton.setImage(Asset.Assets.trash.image, for: .normal)

        trashButton.addTarget(self, action: #selector(trashButtonPress), for: .touchUpInside)

        trashButton.snp.makeConstraints { make in
            make.centerY.equalTo(screenTitle.snp.centerY)
            make.trailing.equalToSuperview().inset(view.frame.width / 15)
            make.width.height.equalTo(28)
        }
    }

    private func createTypeSearchSegments() {
        view.addSubview(typeSearch)

        typeSearch.selectedSegmentIndex = 0

        typeSearch.addTarget(self, action: #selector(engineChanged), for: .valueChanged)

        typeSearch.snp.makeConstraints { make in
            make.top.equalTo(screenTitle.snp.bottom).inset(-15)
            make.height.equalTo(35)
            make.leading.equalTo(backButton.snp.leading)
            make.trailing.equalTo(trashButton.snp.trailing)
        }
    }

    private func createTableStackView() {
        view.addSubview(byImageTable)
        byImageTable.delegate = self
        byImageTable.dataSource = self

        byImageTable.showsVerticalScrollIndicator = false
        byImageTable.separatorStyle = .none

        byImageTable.register(SearchByImageCell.self, forCellReuseIdentifier: Constant.cellIdentifacatorImages)

        byImageTable.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(25)
            make.centerX.equalToSuperview()
            make.top.equalTo(typeSearch.snp.bottom).inset(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    @objc private func trashButtonPress() {
        if (sender == 1 && !wordSearchSorted.isEmpty) || (sender == 0 && !imageSearchSorted.isEmpty) {
            showAlert()
        }
    }
    
    private func showAlert() {
        let alert = UIAlertController(
            title: L10n.App.delete,
            message: "",
            preferredStyle: UIAlertController.Style.alert
        )
        
        alert.addAction(
            UIAlertAction(
                title: L10n.App.no,
                style: UIAlertAction.Style.default,
                handler: { _ in
                  
                    alert.dismiss(animated: true)
                }
            )
        )
        
        alert.addAction(
            UIAlertAction(
                title: L10n.App.yes,
                style: UIAlertAction.Style.default,
                handler: { action in
                    self.remove()
                }
            )
        )
        
        present(alert, animated: true, completion: nil)
    }

    @objc func back() {
        onFinish?()
    }

    func remove() {
        if sender == 1 {
            wordSearch.forEach { search in
                search.removeNote()
            }
            wordSearch = []
            wordSearchSorted = []
        } else {
            imageSearch.forEach { search in
                search.removeNote()
            }
            imageSearch = []
            imageSearchSorted = []
        }
        
        byImageTable.reloadData()
    }


    @objc func engineChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.sender = 0
        case 1:
            self.sender = 1
        default:
            print("default")
        }
        
        byImageTable.reloadData()
    }

    func sortedWordSearchesByDate(wordSearches: [WordSearch]) -> [(Date, [WordSearch])] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"

        var wordSearchesByDate = [(Date, [WordSearch])]()

        for wordSearch in wordSearches {
            let dateString = dateFormatter.string(from: wordSearch.date)
            if let date = dateFormatter.date(from: dateString) {
                if let index = wordSearchesByDate.firstIndex(where: { $0.0 == date }) {
                    wordSearchesByDate[index].1.append(wordSearch)
                } else {
                    wordSearchesByDate.append((date, [wordSearch]))
                }
            }
        }

        let sortedWordSearches = wordSearchesByDate.sorted { $0.0 > $1.0 }

        return sortedWordSearches
    }

    func sortedImageSearchesByDate(imageSearches: [ImageSearch]) -> [(Date, [ImageSearch])] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        var imageSearchesByDate = [(Date, [ImageSearch])]()

        for imageSearch in imageSearches {
            let dateString = dateFormatter.string(from: imageSearch.date)
            if let date = dateFormatter.date(from: dateString) {
                if let index = imageSearchesByDate.firstIndex(where: { $0.0 == date }) {
                    imageSearchesByDate[index].1.append(imageSearch)
                } else {
                    imageSearchesByDate.append((date, [imageSearch]))
                }
            }
        }

        let sortedimageSearches = imageSearchesByDate.sorted { $0.0 > $1.0 }

        return sortedimageSearches
    }

    private func attempToAssembleGroupedImages() -> [[ImageSearch]] {
        var images: [[ImageSearch]] = []
        let groupedSearchs = Dictionary(grouping: imageSearch) { (element) -> Date in
            return element.date
        }

        let sorted = groupedSearchs.keys.sorted(by: > )

        sorted.forEach { key in
            guard let dates = groupedSearchs[key] else { return }
            images.append(dates)
        }

        return images
    }

    // MARK: Remote config

    private func setupRemoteConfigDefaults() {
        let defaultValues = [
            "countFreeSearch": 20 as NSValue
        ]
        RemoteConfig.remoteConfig().setDefaults(defaultValues)
    }

    private func updateViewWithRCValues() {
        freeSearch = RemoteConfig.remoteConfig().configValue(forKey: "countFreeSearch").numberValue.intValue
    }
}

extension SearchHistoryController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sender == 1 {
            return wordSearchSorted[section].1.count
        } else {
            return imageSearchSorted[section].1.count
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if sender == 1 {
            if wordSearchSorted.count == 0 {
                tableView.setEmptyView(title: L10n.App.searchStoryEmpty)
            } else {
                tableView.setEmptyView(title: "")
            }
            return wordSearchSorted.count
        } else {
            if imageSearchSorted.count == 0 {
                tableView.setEmptyView(title: L10n.App.searchStoryEmpty)
            } else {
                tableView.setEmptyView(title: "")
            }
            return imageSearchSorted.count
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let dateLabel = UILabel()
        view.addSubview(dateLabel)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM"
        var date = Date()
        if sender == 1 {
            date = wordSearchSorted[section].0
        } else {
            date = imageSearchSorted[section].0
        }
        let dateString = dateFormatter.string(from: date)

        dateLabel.text = dateString

        dateLabel.font = FontFamily.SFProDisplay.regular.font(size: 15)
        dateLabel.textColor = .black.withAlphaComponent(0.6)

        dateLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
        }
        return view
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if sender == 1 {
            if DefaultsLayer().countFreeSearch < freeSearch || DefaultsLayer().isSubscribted {
                view.addSubview(loading)
                wordSearchClosure?(wordSearchSorted[indexPath.section].1[indexPath.row])
            } else {
                subscription?()
            }

        } else {
            if DefaultsLayer().countFreeSearch < freeSearch || DefaultsLayer().isSubscribted {
                view.addSubview(loading)
                imageSearchClosure?(imageSearchSorted[indexPath.section].1[indexPath.row])
            } else {
                subscription?()
            }
        }
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if sender == 1 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: Constant.cellIdentifacatorImages,
                for: indexPath
            ) as? SearchByImageCell else { return UITableViewCell() }

            cell.remove = { [weak self] in
                guard let self else { return }
                let search = self.wordSearchSorted[indexPath.section].1[indexPath.row]
                search.removeNote()
                wordSearch.removeAll(where: {$0.id == self.wordSearchSorted[indexPath.section].1[indexPath.row].id })
                self.wordSearchSorted[indexPath.section].1.remove(at: indexPath.row)
                if self.wordSearchSorted[indexPath.section].1.isEmpty {
                    self.wordSearchSorted.remove(at: indexPath.section)
                }
                print(wordSearch)
                byImageTable.reloadData()
            }

            guard let result = wordSearch.first(where: { word in
                wordSearchSorted[indexPath.section].1[indexPath.row].id == word.id
            }) else { return UITableViewCell() }

            cell.configOf(search: nil, sender: sender, wordSearch: result)

            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: Constant.cellIdentifacatorImages,
                for: indexPath
            ) as? SearchByImageCell else { return UITableViewCell() }

            cell.remove = { [weak self] in
                guard let self else { return }
                let search = self.imageSearchSorted[indexPath.section].1[indexPath.row]
                search.removeNote()
                imageSearch.removeAll(where: {$0.id == self.imageSearchSorted[indexPath.section].1[indexPath.row].id })
                self.imageSearchSorted[indexPath.section].1.remove(at: indexPath.row)
                if self.imageSearchSorted[indexPath.section].1.isEmpty {
                    self.imageSearchSorted.remove(at: indexPath.section)
                }
                byImageTable.reloadData()
            }
            guard let result = imageSearch.first(where: { imageSearch in
                imageSearchSorted[indexPath.section].1[indexPath.row].id == imageSearch.id
            }) else { return UITableViewCell() }
            cell.configOf(search: result, sender: sender, wordSearch: nil)

            return cell
        }
    }
}

// MARK: SearchHistoryInterface

extension SearchHistoryController: SearchHistoryInterface {
    func getImageSearch(search: [ImageSearch]) {
        imageSearch = search
    }

    func getWordsSearch(search: [WordSearch]) {
        wordSearch = search
    }
}

extension UITableView {
    func setEmptyView(title: String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.black
        titleLabel.font = FontFamily.SFProDisplay.regular.font(size: 18)
        emptyView.addSubview(titleLabel)
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        titleLabel.text = title
        // The only tricky part is here:
        self.backgroundView = emptyView
        self.separatorStyle = .none
    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
