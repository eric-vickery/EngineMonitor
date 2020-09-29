//
//  AppDelegate.swift
//  EngineMonitor
//
//  Created by Eric Vickery on 2/26/20.
//  Copyright © 2020 Eric Vickery. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // This chunk is in here to get local network access working. It seems that CocoaAsyncSocket doesn't work correctly with local network access
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.waitsForConnectivity = true
        sessionConfig.timeoutIntervalForResource = 60
        let url: URL = URL(string: "https://localhost")!
        print(url)
        URLSession(configuration: sessionConfig)
            .dataTask(with: URLRequest(url: url)) { data, response, error in
            
            if let response = response as? HTTPURLResponse {
                print("Response code: \(response.statusCode)")
            }
            
            if let error = error {
                print(error.localizedDescription)
            }
            
        }.resume()
        
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
