//
//  CardInfo.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 14.07.23.
//

import UIKit

enum CardInfo: CaseIterable {
    case photos
    case gallery
    case face
    case clipboard
    case url

    var mainText: String {
        switch self {
        case .photos:
            return L10n.Main.photos
        case .gallery:
            return L10n.Main.gallery
        case .face:
            return L10n.Main.faceFinder
        case .clipboard:
            return L10n.Main.clipboard
        case .url:
            return L10n.Main.url
        }
    }

    var description: String {
        switch self {
        case .photos:
            return L10n.Main.photosDescription
        case .gallery:
            return L10n.Main.galleryDescription
        case .face:
            return L10n.Main.faceFinderDescription
        case .clipboard:
            return L10n.Main.clipboardDescription
        case .url:
            return L10n.Main.urlDescription
        }
    }

    var image: UIImage {
        switch self {
        case .photos:
            return Asset.Assets.photos.image
        case .gallery:
            return Asset.Assets.gallery.image
        case .face:
            return Asset.Assets.face.image
        case .clipboard:
            return Asset.Assets.clipboard.image
        case .url:
            return Asset.Assets.url.image
        }
    }

    var color: UIColor {
        switch self {
        case .photos:
            return Asset.Colors.cardYellow.color
        case .gallery:
            return Asset.Colors.cardGreen.color
        case .face:
            return Asset.Colors.cardBlue.color
        case .clipboard:
            return Asset.Colors.cardOrange.color
        case .url:
            return Asset.Colors.cardPink.color
        }
    }
    
    var isFree: Bool {
        switch self {
        case .photos:
            return true
        case .gallery:
            return true
        case .face:
            return true
        case .clipboard:
            return false
        case .url:
            return false
        }
    }
}
