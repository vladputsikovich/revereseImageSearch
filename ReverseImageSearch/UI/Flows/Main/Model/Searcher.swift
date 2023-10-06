//
//  Searcher.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 6.07.23.
//

import UIKit

enum Searcher: Int, CaseIterable, Codable {
    case google
    case yandex
    case bing
    case tinyeye
    case baidu
    case sogou

    func hostWords() -> String {
        switch self {
        case .google:
            return "www.google.com"
        case .yandex:
            return "yandex.ru"
        case .bing:
            return "www.bing.com"
        case .tinyeye:
            return "www.tineye.com"
        case .baidu:
            return "image.baidu.com"
        case .sogou:
            return "pic.sogou.com"
        }
    }

    func hostImage() -> String {
        switch self {
        case .google:
            return "lens.google.com"
        case .yandex:
            return "yandex.ru"
        case .bing:
            return "www.bing.com"
        case .tinyeye:
            return "www.tineye.com"
        case .baidu:
            return "image.baidu.com"
        case .sogou:
            return "pic.sogou.com"
        }
    }

    func pathImage() -> String {
        switch self {
        case .google:
            return "/uploadbyurl"
        case .yandex:
            return "/images/touch/search"
        case .bing:
            return "/images/search"
        case .tinyeye:
            return "/search"
        case .baidu:
            return "/pcdutu"
        case .sogou:
            return "/ris"
        }
    }

    func pathWords() -> String {
        switch self {
        case .google:
            return "/search"
        case .yandex:
            return "/images/search"
        case .bing:
            return "/images/search"
        case .tinyeye:
            return "/search/"
        case .baidu:
            return "/search/index"
        case .sogou:
            return "/pics"
        }
    }

    func queryItemsImage(imageUrl: String) -> [URLQueryItem] {
        switch self {
        case .google:
            return [
                URLQueryItem(name: "url", value: imageUrl)
            ]
        case .yandex:
            return [
                URLQueryItem(name: "rpt", value: "imageview"),
                URLQueryItem(name: "url", value: imageUrl)
            ]
        case .bing:
            return [
                URLQueryItem(name: "view", value: "detailv2"),
                URLQueryItem(name: "iss", value: "sbi"),
                URLQueryItem(name: "form", value: "SBIVSP"),
                URLQueryItem(name: "sbisrc", value: "UrlPaste"),
                URLQueryItem(name: "q", value: "imgurl:\(imageUrl)")
            ]
        case .tinyeye:
            return [
                URLQueryItem(name: "url", value: imageUrl)
            ]
        case .baidu:
            return [
                URLQueryItem(name: "queryImageUrl", value: imageUrl)
            ]
        case .sogou:
            return [
                URLQueryItem(name: "query", value: "https://img03.sogoucdn.com/v2/thumb/retype_exclude_gif/ext/auto"),
                URLQueryItem(name: "appid", value: "122"),
                URLQueryItem(name: "url", value: imageUrl),
                URLQueryItem(name: "flag", value: "1")
            ]
        }
    }

    func queryItemsWords(text: String) -> [URLQueryItem] {
        switch self {
        case .google:
            return [
                URLQueryItem(name: "q", value: text),
                URLQueryItem(name: "tbm", value: "isch")
            ]
        case .yandex:
            return [
                URLQueryItem(name: "text", value: text)
            ]
        case .bing:
            return [
                URLQueryItem(name: "q", value: text)
            ]
        case .tinyeye:
            return [
                URLQueryItem(name: "q", value: text)
            ]
        case .baidu:
            return [
                URLQueryItem(name: "tn", value: "baiduimage"),
                URLQueryItem(name: "word", value: text)
            ]
        case .sogou:
            return [
                URLQueryItem(name: "query", value: text)
            ]
        }
    }

    func name() -> String {
        switch self {
        case .google:
            return "Google"
        case .yandex:
            return "Yandex"
        case .bing:
            return "Bing"
        case .tinyeye:
            return "Tineye"
        case .baidu:
            return "Baidu"
        case .sogou:
            return "Sogou"
        }
    }
    
    func isFree() -> Bool {
        switch self {
        case .google:
            return true
        case .yandex:
            return true
        case .bing:
            return false
        case .tinyeye:
            return false
        case .baidu:
            return false
        case .sogou:
            return false
        }
    }

    func image() -> UIImage {
        switch self {
        case .google:
            return Asset.Assets.google.image
        case .yandex:
            return Asset.Assets.yandex.image
        case .bing:
            return Asset.Assets.bing.image
        case .tinyeye:
            return Asset.Assets.tinyeye.image
        case .baidu:
            return Asset.Assets.baidu.image
        case .sogou:
            return Asset.Assets.sogou.image
        }
    }

    func searcherUrl(imageUrl: String) -> String {
        switch self {
        case .google:
            return "https://lens.google.com/uploadbyurl?url=\(imageUrl)"
        case .yandex:
            return "https://yandex.ru/images/touch/search?rpt=imageview&url=\(imageUrl)"
        case .bing:
            return "https://www.bing.com/images/search?view=detailv2&iss=sbi&form=SBIVSP&sbisrc=UrlPaste&q=imgurl:\(imageUrl)"
        case .tinyeye:
            return "https://www.tineye.com/search/?url=\(imageUrl)"
        case .baidu:
            return "https://image.baidu.com/pcdutu?queryImageUrl=\(imageUrl)"
        case .sogou:
            return "https://pic.sogou.com/pics?query=\(imageUrl)"
        }
    }
}
