//
//  MenuScene.swift
//  GithubProjects
//
//  Created by Coder ACJHP on 20.11.2024.
//

import Foundation
import SpriteKit

class MenuScene: SKScene {
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupTitle()
        setupButtons()
    }
    
    private func setupBackground() {
        // Add a gradient background
        let tx = SKTexture(image: UIImage(resource: .menuBackground))
        let background = SKSpriteNode(texture: tx)
        background.aspectFillToSize(fillSize: frame.size)
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = -1
        background.name = "backgroundNode"
        addChild(background)
        
        // Add floating particles
        let particleEmitter = SKEmitterNode(fileNamed: "BokehParticle.sks")
        particleEmitter?.position = CGPoint(x: frame.midX, y: frame.midY)
        particleEmitter?.zPosition = 0
        particleEmitter?.advanceSimulationTime(10) // Makes the particles look pre-populated
        particleEmitter?.isUserInteractionEnabled = false
        particleEmitter?.name = "particleEmitter"
        if let emitter = particleEmitter {
            addChild(emitter)
        }
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
        // Button 1: Swipe to Suggest Word
        let swipeButton = createButton(
            withText: "Swipe to Suggest Word",
            position: CGPoint(
                x: frame.midX,
                y: 150
            )
        )
        swipeButton.name = "SwipeGame"
        swipeButton.zPosition = 1000
        addChild(swipeButton)
        
        // Button 2: Fill in the Blank
        let fillBlankButton = createButton(
            withText: "Fill in the Blank",
            position: CGPoint(
                x: frame.midX,
                y: 70
            )
        )
        fillBlankButton.name = "FillGame"
        swipeButton.zPosition = 1000
        addChild(fillBlankButton)
    }
    
    private func createButton(withText text: String, position: CGPoint) -> SKSpriteNode {
        let button = SKSpriteNode(color: .clear, size: CGSize(width: 300, height: 60))
        button.position = position
        button.name = text
        button.zPosition = 1
        
        // Background with rounded corners
        let bg = SKShapeNode(rectOf: CGSize(width: 300, height: 60), cornerRadius: 15)
        bg.fillColor = #colorLiteral(red: 0, green: 0.2626195336, blue: 0.3218821875, alpha: 1)
        bg.strokeColor = .clear
        bg.zPosition = -1
        button.addChild(bg)
        
        // Label
        let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        label.text = text
        label.fontSize = 20
        label.fontColor = .white
        label.position = CGPoint(x: 0, y: -8)
        label.zPosition = 2
        button.addChild(label)
        
        // Add hover animation
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.6)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.6)
        let hoverSequence = SKAction.sequence([scaleUp, scaleDown])
        let action = SKAction.repeat(hoverSequence, count: 5)
        action.timingMode = .easeInEaseOut
        button.run(action, withKey: "hover")
        
        return button
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        let name = touchedNode.name ?? touchedNode.parent?.name ?? ""
        if name == "SwipeGame" {
            NavigationManager.shared.navigateToSwipeGameScene()
        } else if name == "FillGame" {
            NavigationManager.shared.navigateToFillGameScene()
        }
    }
}
