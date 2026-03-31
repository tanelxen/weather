//
//  SceneDelegate.swift
//  Weather
//
//  Created by Fedor Artemenkov on 30.03.26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = makeViewController()
        window.makeKeyAndVisible()
        
        self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}

private func makeViewController() -> UIViewController {
    
    let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String ?? ""
    
    let weatherClient = WeatherClientImpl(apiKey: apiKey)
    let locationService = LocationServiceMock()
    let presenter = WeatherPresenterImpl(weatherClient: weatherClient, locationService: locationService)
    
    return WeatherViewController(presenter: presenter)
}
