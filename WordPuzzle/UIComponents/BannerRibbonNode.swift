//
//  BannerRibbonNode.swift
//  WordPuzzle
//
//  Created by Coder ACJHP on 22.11.2024.
//

import Foundation
import SpriteKit

class BannerRibbonNode: SKSpriteNode {
    
    private var labelNode: SKLabelNode!
    private var textureNode: SKTexture!
    
    public var title: String = "GOOD!" {
        didSet {
            labelNode.text = title
        }
    }
    
    init(title: String) {
        let texture = SKTexture(image: UIImage(resource: .bannerRibbon))
        let screenSize = UIScreen.main.bounds.size
        super.init(texture: texture, color: .clear, size: CGSize(width: screenSize.width * 0.8, height: 70))
        
        labelNode = SKLabelNode(text: title)
        labelNode.fontName = "AvenirNext-Bold"
        labelNode.fontSize = 32
        labelNode.color = .white
        labelNode.horizontalAlignmentMode = .center
        labelNode.verticalAlignmentMode = .center
        labelNode.position = CGPoint(x: 0, y: 8)
        addChild(labelNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implementted")
    }
}
