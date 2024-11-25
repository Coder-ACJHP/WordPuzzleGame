//
//  MenuScene.swift
//  GithubProjects
//
//  Created by Coder ACJHP on 20.11.2024.
//

import Foundation
import SpriteKit

class MenuScene: SKScene {
    
    private var isMuted: Bool = false
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupTitle()
        setupButtons()
    }
    
    private func setupBackground() {
        let gradientTexture = SKTexture(
            vectorNoiseWithSmoothness: 1.0,
            size: CGSize(
                width: frame.width / 4,
                height: frame.height / 4
            )
        )
        let background = SKSpriteNode(texture: gradientTexture)
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.size = frame.size
        background.zPosition = -1
        background.name = "backgroundNode"
        addChild(background)
        
        // Add floating letter particles
        createAlphabetParticleEmitter()
    }
    
    private func setupTitle() {
        let title = "Word Puzzle"
        let range = NSRange(location: 0, length: title.count)
        let attributedString = NSMutableAttributedString(string: title)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.black
        shadow.shadowOffset = CGSize(width: 1, height: 1)
        
        let attrs: [NSAttributedString.Key: Any] = [
            .font : UIFont(name: "AvenirNext-Bold", size: 39) ?? .boldSystemFont(ofSize: 39),
            .foregroundColor : UIColor.white,
            .paragraphStyle : paragraphStyle,
            .shadow : shadow
        ]
        attributedString.addAttributes(attrs, range: range)
        
        let titleLabel = SKLabelNode(attributedText: attributedString)
        titleLabel.preferredMaxLayoutWidth = size.width * 0.8
        titleLabel.alpha = 0
        titleLabel.setScale(0.5)
        titleLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        titleLabel.name = "titleLabel"
        
        addChild(titleLabel)
        
        // Animate the title
        let fadeIn = SKAction.fadeIn(withDuration: 1.5)
        let scaleUp = SKAction.scale(to: 1.0, duration: 1.5)
        let group = SKAction.group([fadeIn, scaleUp])
        titleLabel.run(group)
    }
    
    private func setupButtons() {
        
        let padding = CGFloat(45)
        
        // Button 1: Settings
        let settingsButton = AnimatableButton(
            withIcon: .settings,
            named: "settingsButton",
            position: CGPoint(x: padding, y: size.height - 65),
            size: CGSize(width: 50, height: 50)
        )
        settingsButton.zPosition = 1000
        addChild(settingsButton)
        settingsButton.touchUpInside = {
            print("Settings button pressed")
        }
        
        // Button 2: Mute
        let muteButton = AnimatableButton(
            defaultStateIcon: .mute,
            selectedStateIcon: .unMute,
            named: "muteButton",
            position: CGPoint(x: size.width - padding, y: size.height - 65),
            size: CGSize(width: 50, height: 50)
        )
        muteButton.zPosition = 1000
        addChild(muteButton)
        muteButton.touchUpInside = { [weak self] in
            guard let self else { return }
            muteButton.updateIcon(isSelected: isMuted)
            isMuted.toggle()
        }
        
        // Button 3: Swipe to Suggest Word
        let swipeButton = AnimatableButton(
            withText: "Swipe to Suggest Word",
            named: "SwipeGame",
            position: CGPoint(x: frame.midX, y: 150),
            size: CGSize(width: size.width - padding, height: 55)
        )
        swipeButton.zPosition = 1000
        addChild(swipeButton)
        swipeButton.touchUpInside = {
            NavigationManager.shared.navigateToSwipeGameScene()
        }
        
        // Button 4: Fill in the Blank
        let fillBlankButton = AnimatableButton(
            withText: "Fill in the Blank",
            named: "FillGame",
            position: CGPoint(x: frame.midX, y: 70),
            size: CGSize(width: size.width - padding, height: 55)
        )
        fillBlankButton.zPosition = 1000
        addChild(fillBlankButton)
        fillBlankButton.touchUpInside = {
            NavigationManager.shared.navigateToFillGameScene()
        }
    }
}
