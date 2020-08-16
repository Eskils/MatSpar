//
//  SceneDelegate.swift
//  MatSpar
//
//  Created by Eskil Sviggum on 03/08/2020.
//

import UIKit

var butikkManager: ButikkManager!

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let winScene = (scene as? UIWindowScene) else { return }
        
        butikkManager = ButikkManager()
        
        window = UIWindow(windowScene: winScene)
        
        let varer = VarerKontroller()
        let varerNav = UINavigationController(rootViewController: varer)
        varerNav.navigationBar.tintColor = .app
        
        let handleliste = HandlelisteKontroller()
        let handlelisteNav = UINavigationController(rootViewController: handleliste)
        handlelisteNav.navigationBar.tintColor = .app
        
        let tabBar = UITabBarController()
        tabBar.viewControllers = [varerNav, handlelisteNav]
        tabBar.tabBar.items?[0].image = varer.barItem.image
        tabBar.tabBar.items?[0].title = varer.barItem.title
        tabBar.tabBar.items?[1].image = handleliste.barItem.image
        tabBar.tabBar.items?[1].title = handleliste.barItem.title
        
        tabBar.tabBar.tintColor = .app
        
        window?.rootViewController = tabBar
        
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

