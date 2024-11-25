//
//  SKNode+Extension.swift
//  GithubProjects
//
//  Created by Coder ACJHP on 21.11.2024.
//

import SpriteKit

extension SKNode {
    public var center: CGPoint {
        // Get the label's frame
        let nodeFrame = self.frame
        // Calculate the center point
        let centerX = nodeFrame.origin.x + (nodeFrame.size.width / 2)
        let centerY = nodeFrame.origin.y + (nodeFrame.size.height / 2)
        // Create a CGPoint for the center
        return CGPoint(x: centerX, y: centerY)
    }
}

extension SKSpriteNode {
    func aspectFillToSize(fillSize: CGSize) {
        if texture != nil {
            self.size = texture!.size()
            let verticalRatio = fillSize.height / self.texture!.size().height
            let horizontalRatio = fillSize.width /  self.texture!.size().width
            let scaleRatio = horizontalRatio > verticalRatio ? horizontalRatio : verticalRatio
            self.setScale(scaleRatio)
        }
    }
    
    func aspectFitToSize(fitSize: CGSize) {
        if texture != nil {
            self.size = texture!.size() 
            let verticalRatio = fitSize.height / self.texture!.size().height
            let horizontalRatio = fitSize.width / self.texture!.size().width
            let scaleRatio = horizontalRatio < verticalRatio ? horizontalRatio : verticalRatio 
            self.setScale(scaleRatio)
        }
    }
}

extension SKScene {
    func createAlphabetParticleEmitter() {
        let particleEmitter = SKEmitterNode()
        particleEmitter.position = CGPoint(x: frame.midX, y: frame.midY)
        particleEmitter.zPosition = -1
        particleEmitter.isUserInteractionEnabled = false
        particleEmitter.name = "particleEmitter"
        
        particleEmitter.particleBirthRate = 3
        particleEmitter.particleLifetime = 5
        particleEmitter.particleSpeed = 0
        particleEmitter.particleSpeedRange = 10
        particleEmitter.emissionAngle = 90 * (.pi / 180)
        particleEmitter.emissionAngleRange = 360 * (.pi / 180)
        particleEmitter.particlePositionRange = CGVector(dx: size.width, dy: size.height)
        particleEmitter.particleScale = 0.1
        particleEmitter.particleScaleRange = 0.8
        particleEmitter.particleScaleSpeed = 0.15
        particleEmitter.particleAlpha = 0.1
        particleEmitter.particleAlphaRange = 0.5
        particleEmitter.particleColor = .white
        addChild(particleEmitter)
        
        var textures: [SKTexture] = []
        
        for (index, char) in "abcdefghjklmnopqrstuvwxyzABCDEFGHIJKLMNOPRSTUVWXYZ".enumerated() {
            let title = "\(char)"
            let range = NSRange(location: 0, length: title.count)
            let attributedString = NSMutableAttributedString(string: title)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let attrs: [NSAttributedString.Key: Any] = [
                .font : UIFont.systemFont(ofSize: 50, weight: .semibold),
                .foregroundColor : UIColor.white,
                .paragraphStyle : paragraphStyle
            ]
            attributedString.addAttributes(attrs, range: range)
            let cellNode = SKLabelNode(attributedText: attributedString)
            if let texture = SKView().texture(from: cellNode) {
                textures.append(texture)
            }
        }
        
        // Function to cycle through textures
        let changeTextureAction = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run { particleEmitter.particleTexture = textures.randomElement() },
                SKAction.wait(forDuration: 3.0)
            ])
        )
        // Start cycling textures
        particleEmitter.run(changeTextureAction)
    }
}
