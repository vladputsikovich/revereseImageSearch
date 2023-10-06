//
//  AppDelegate.swift
//  ReverseImageSearch
//
//  Created by Владислав Пуцыкович on 31.05.23.
//
import GoogleMobileAds
import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mainCoordinator: MainCoordinator?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        //GADMobileAds.sharedInstance().start(completionHandler: nil)
        RemoteConfig.remoteConfig().fetch(withExpirationDuration: 0) { (status, error) in
            guard error == nil else {
                print("Problem with fetch remote congig values \(String(describing: error))")
                return
            }
            print("Yeah fetch values from cloud")
            RemoteConfig.remoteConfig().activate() { data, error in
                print("Remote Config \(data)")
            }
        }
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        NetworkMonitorObserver.shared.start()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print(url)
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        let navigationController = UINavigationController()
        navigationController.navigationBar.isHidden = true
        mainCoordinator = MainCoordinator(navigationController: navigationController)

        mainCoordinator?.start()

        window?.rootViewController = navigationController
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

