// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum App {
    /// Cancel
    internal static let cancel = L10n.tr("Localizable", "app.cancel", fallback: "Cancel")
    /// No Internet Connection
    internal static let connection = L10n.tr("Localizable", "app.connection", fallback: "No Internet Connection")
    /// No internet connection, try again later please
    internal static let connectionTryAgain = L10n.tr("Localizable", "app.connectionTryAgain", fallback: "No internet connection, try again later please")
    /// Do you really want to delete all history?
    internal static let delete = L10n.tr("Localizable", "app.delete", fallback: "Do you really want to delete all history?")
    /// Done
    internal static let done = L10n.tr("Localizable", "app.done", fallback: "Done")
    /// Failed to convert data to image
    internal static let failedConvert = L10n.tr("Localizable", "app.failedConvert", fallback: "Failed to convert data to image")
    /// Failed to load the image
    internal static let failedLoad = L10n.tr("Localizable", "app.failedLoad", fallback: "Failed to load the image")
    /// Sorry, you have not granted access to the camera. Allow access in the settings.
    internal static let imageAccess = L10n.tr("Localizable", "app.imageAccess", fallback: "Sorry, you have not granted access to the camera. Allow access in the settings.")
    /// Image Search
    internal static let imageSeach = L10n.tr("Localizable", "app.imageSeach", fallback: "Image Search")
    /// No
    internal static let no = L10n.tr("Localizable", "app.no", fallback: "No")
    /// Ok
    internal static let ok = L10n.tr("Localizable", "app.ok", fallback: "Ok")
    /// Pasteboard does not contain a image
    internal static let pasteboardDoesContainImage = L10n.tr("Localizable", "app.pasteboardDoesContainImage", fallback: "Pasteboard does not contain a image")
    /// Pasteboard does not contain a URL
    internal static let pasteboardDoesContainUrl = L10n.tr("Localizable", "app.pasteboardDoesContainUrl", fallback: "Pasteboard does not contain a URL")
    /// Do you like this app?
    internal static let rateUsInfo = L10n.tr("Localizable", "app.rateUsInfo", fallback: "Do you like this app?")
    /// Save
    internal static let save = L10n.tr("Localizable", "app.save", fallback: "Save")
    /// Search
    internal static let search = L10n.tr("Localizable", "app.search", fallback: "Search")
    /// Search Results
    internal static let searchResults = L10n.tr("Localizable", "app.searchResults", fallback: "Search Results")
    /// Sorry, but your story is still empty
    internal static let searchStoryEmpty = L10n.tr("Localizable", "app.searchStoryEmpty", fallback: "Sorry, but your story is still empty")
    /// Sorry
    internal static let sorry = L10n.tr("Localizable", "app.sorry", fallback: "Sorry")
    /// Yes
    internal static let yes = L10n.tr("Localizable", "app.yes", fallback: "Yes")
  }
  internal enum History {
    /// By Images
    internal static let byImages = L10n.tr("Localizable", "history.byImages", fallback: "By Images")
    /// By Words
    internal static let byWord = L10n.tr("Localizable", "history.byWord", fallback: "By Words")
    /// Search History
    internal static let searchHistory = L10n.tr("Localizable", "history.searchHistory", fallback: "Search History")
  }
  internal enum Main {
    /// Clipboard
    internal static let clipboard = L10n.tr("Localizable", "main.clipboard", fallback: "Clipboard")
    /// Paste Image & Search
    internal static let clipboardDescription = L10n.tr("Localizable", "main.clipboardDescription", fallback: "Paste Image & Search")
    /// Face Finder
    internal static let faceFinder = L10n.tr("Localizable", "main.faceFinder", fallback: "Face Finder")
    /// Search Similar Faces
    internal static let faceFinderDescription = L10n.tr("Localizable", "main.faceFinderDescription", fallback: "Search Similar Faces")
    /// Gallery
    internal static let gallery = L10n.tr("Localizable", "main.gallery", fallback: "Gallery")
    /// Search From Gallery
    internal static let galleryDescription = L10n.tr("Localizable", "main.galleryDescription", fallback: "Search From Gallery")
    /// Photos
    internal static let photos = L10n.tr("Localizable", "main.photos", fallback: "Photos")
    /// Search From Photos
    internal static let photosDescription = L10n.tr("Localizable", "main.photosDescription", fallback: "Search From Photos")
    /// Select Image Source
    internal static let selectImageSource = L10n.tr("Localizable", "main.selectImageSource", fallback: "Select Image Source")
    /// URL
    internal static let url = L10n.tr("Localizable", "main.URL", fallback: "URL")
    /// Paste Image URL & Search
    internal static let urlDescription = L10n.tr("Localizable", "main.URLDescription", fallback: "Paste Image URL & Search")
    /// Use Camera
    internal static let useCamera = L10n.tr("Localizable", "main.useCamera", fallback: "Use Camera")
    /// Use Library
    internal static let useLibrary = L10n.tr("Localizable", "main.useLibrary", fallback: "Use Library")
  }
  internal enum Onboadring {
    /// Continue
    internal static let continueText = L10n.tr("Localizable", "onboadring.continueText", fallback: "Continue")
  }
  internal enum Onboarding {
    /// Continue
    internal static let continueText = L10n.tr("Localizable", "onboarding.continueText", fallback: "Continue")
    /// Easy and Fast 
    /// Search by Photo
    internal static let mainTitle1 = L10n.tr("Localizable", "onboarding.mainTitle1", fallback: "Easy and Fast \nSearch by Photo")
    /// Combination 
    /// Reverse Search
    internal static let mainTitle2 = L10n.tr("Localizable", "onboarding.mainTitle2", fallback: "Combination \nReverse Search")
    /// Find all product information or similar faces in one click
    internal static let secondTitle1 = L10n.tr("Localizable", "onboarding.secondTitle1", fallback: "Find all product information or similar faces in one click")
    /// Google, Yandex, Sogou, Bing, Baidu, Tineye - in one place
    internal static let secondTitle2 = L10n.tr("Localizable", "onboarding.secondTitle2", fallback: "Google, Yandex, Sogou, Bing, Baidu, Tineye - in one place")
  }
  internal enum Settings {
    /// BASIC
    internal static let basic = L10n.tr("Localizable", "settings.basic", fallback: "BASIC")
    /// Default
    internal static let `default` = L10n.tr("Localizable", "settings.default", fallback: "Default")
    /// Default Search
    internal static let defaultSearch = L10n.tr("Localizable", "settings.defaultSearch", fallback: "Default Search")
    /// Don’t Shrink
    internal static let dontShrink = L10n.tr("Localizable", "settings.dontShrink", fallback: "Don’t Shrink")
    /// High
    internal static let high = L10n.tr("Localizable", "settings.high", fallback: "High")
    /// Image Editor
    internal static let imageEditor = L10n.tr("Localizable", "settings.imageEditor", fallback: "Image Editor")
    /// Image Quality
    internal static let imageQuality = L10n.tr("Localizable", "settings.imageQuality", fallback: "Image Quality")
    /// Image Shrink Size
    internal static let imageShrinkSize = L10n.tr("Localizable", "settings.imageShrinkSize", fallback: "Image Shrink Size")
    /// Large: %@
    internal static func large(_ p1: Any) -> String {
      return L10n.tr("Localizable", "settings.large", String(describing: p1), fallback: "Large: %@")
    }
    /// Low
    internal static let low = L10n.tr("Localizable", "settings.low", fallback: "Low")
    /// Medium
    internal static let medium = L10n.tr("Localizable", "settings.medium", fallback: "Medium")
    /// Medium: %@
    internal static func mediumShrink(_ p1: Any) -> String {
      return L10n.tr("Localizable", "settings.mediumShrink", String(describing: p1), fallback: "Medium: %@")
    }
    /// Not Set
    internal static let notSet = L10n.tr("Localizable", "settings.notSet", fallback: "Not Set")
    /// OTHER
    internal static let other = L10n.tr("Localizable", "settings.other", fallback: "OTHER")
    /// Privacy Policy
    internal static let privacy = L10n.tr("Localizable", "settings.privacy", fallback: "Privacy Policy")
    /// Rate Us
    internal static let rateUs = L10n.tr("Localizable", "settings.rateUs", fallback: "Rate Us")
    /// Settings
    internal static let settings = L10n.tr("Localizable", "settings.settings", fallback: "Settings")
    /// Share App
    internal static let share = L10n.tr("Localizable", "settings.share", fallback: "Share App")
    /// Small: %@
    internal static func small(_ p1: Any) -> String {
      return L10n.tr("Localizable", "settings.small", String(describing: p1), fallback: "Small: %@")
    }
    /// Support
    internal static let support = L10n.tr("Localizable", "settings.support", fallback: "Support")
    /// Terms of Use
    internal static let terms = L10n.tr("Localizable", "settings.terms", fallback: "Terms of Use")
    /// Tiny: %@
    internal static func tiny(_ p1: Any) -> String {
      return L10n.tr("Localizable", "settings.tiny", String(describing: p1), fallback: "Tiny: %@")
    }
  }
  internal enum Subsciption {
    /// Get Premium
    internal static let getPremium = L10n.tr("Localizable", "subsciption.getPremium", fallback: "Get Premium")
  }
  internal enum Subscription {
    /// Best Price
    internal static let bestPrice = L10n.tr("Localizable", "subscription.bestPrice", fallback: "Best Price")
    /// %u days
    internal static func days(_ p1: Int) -> String {
      return L10n.tr("Localizable", "subscription.days", p1, fallback: "%u days")
    }
    /// %@ 
    /// Free Trial
    internal static func freeTrial(_ p1: Any) -> String {
      return L10n.tr("Localizable", "subscription.freeTrial", String(describing: p1), fallback: "%@ \nFree Trial")
    }
    /// %@ 
    /// Free Trial, then
    internal static func freeTrialReview(_ p1: Any) -> String {
      return L10n.tr("Localizable", "subscription.freeTrialReview", String(describing: p1), fallback: "%@ \nFree Trial, then")
    }
    /// Month
    internal static let month = L10n.tr("Localizable", "subscription.month", fallback: "Month")
    /// %u months
    internal static func months(_ p1: Int) -> String {
      return L10n.tr("Localizable", "subscription.months", p1, fallback: "%u months")
    }
    /// Nothing to Restore
    internal static let nothingRestore = L10n.tr("Localizable", "subscription.nothingRestore", fallback: "Nothing to Restore")
    /// Optimal
    internal static let optimal = L10n.tr("Localizable", "subscription.optimal", fallback: "Optimal")
    /// Plan automatically renews. Cancel anytime.
    internal static let planRenews = L10n.tr("Localizable", "subscription.planRenews", fallback: "Plan automatically renews. Cancel anytime.")
    /// Popular
    internal static let popular = L10n.tr("Localizable", "subscription.popular", fallback: "Popular")
    /// Pro
    internal static let pro = L10n.tr("Localizable", "subscription.pro", fallback: "Pro")
    /// Restore
    internal static let restore = L10n.tr("Localizable", "subscription.restore", fallback: "Restore")
    /// Subscribe
    internal static let subscribe = L10n.tr("Localizable", "subscription.subscribe", fallback: "Subscribe")
    /// Subscription Restored
    internal static let successRestore = L10n.tr("Localizable", "subscription.successRestore", fallback: "Subscription Restored")
    /// Unlimited Access 
    /// To All Features
    internal static let unlimited = L10n.tr("Localizable", "subscription.unlimited", fallback: "Unlimited Access \nTo All Features")
    /// Week
    internal static let week = L10n.tr("Localizable", "subscription.week", fallback: "Week")
    /// %u weeks
    internal static func weeks(_ p1: Int) -> String {
      return L10n.tr("Localizable", "subscription.weeks", p1, fallback: "%u weeks")
    }
    /// Year
    internal static let year = L10n.tr("Localizable", "subscription.year", fallback: "Year")
    /// %u years
    internal static func years(_ p1: Int) -> String {
      return L10n.tr("Localizable", "subscription.years", p1, fallback: "%u years")
    }
    internal enum Feature {
      /// Unlimited Image Search
      internal static let imageSearch = L10n.tr("Localizable", "subscription.feature.imageSearch", fallback: "Unlimited Image Search")
      /// No Ads
      internal static let noAds = L10n.tr("Localizable", "subscription.feature.noAds", fallback: "No Ads")
      /// Multiple Search Engines
      internal static let searchEngines = L10n.tr("Localizable", "subscription.feature.searchEngines", fallback: "Multiple Search Engines")
      /// Full Search History
      internal static let searchHistory = L10n.tr("Localizable", "subscription.feature.searchHistory", fallback: "Full Search History")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
