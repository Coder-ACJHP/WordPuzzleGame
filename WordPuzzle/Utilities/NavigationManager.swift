//
//  NavigationManager.swift
//  GithubProjects
//
//  Created by Coder ACJHP on 20.11.2024.
//

import UIKit
import SpriteKit

class NavigationManager {
    static let shared = NavigationManager()
    public var skView: SKView?
    
    private init() {}
    
    func navigateToSwipeGameScene() {
        let sceneSize = UIScreen.main.bounds.size
        let scene = SwipeToSuggestWordScene(size: sceneSize)
        scene.scaleMode = .aspectFit
        let transition = SKTransition.doorsOpenHorizontal(withDuration: 1.0)
        DispatchQueue.main.async {
            self.skView?.presentScene(scene, transition: transition)
        }
    }
    
    func navigateToFillGameScene() {
        let sceneSize = UIScreen.main.bounds.size
        let scene = FillInTheBlankScene(size: sceneSize)
        scene.scaleMode = .aspectFit
        let transition = SKTransition.doorsOpenHorizontal(withDuration: 1.0)
        DispatchQueue.main.async {
            self.skView?.presentScene(scene, transition: transition)
        }
    }
    
    func navigateToMenuScene() {
        let sceneSize = UIScreen.main.bounds.size
        let scene = MenuScene(size: sceneSize)
        scene.scaleMode = .aspectFit
        self.skView?.presentScene(scene)
    }
    
    func returnToMenuScene() {
        let sceneSize = UIScreen.main.bounds.size
        let scene = MenuScene(size: sceneSize)
        scene.scaleMode = .aspectFit
        let transition = SKTransition.doorsCloseHorizontal(withDuration: 1.0)
        DispatchQueue.main.async {
            self.skView?.presentScene(scene, transition: transition)
        }
    }
}
