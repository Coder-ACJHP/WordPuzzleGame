//
//  AnimatableButton.swift
//  WordPuzzle
//
//  Created by Coder ACJHP on 25.11.2024.
//

import Foundation
import SpriteKit

class AnimatableButton: SKSpriteNode {
    
    public var touchUpInside: (() -> Void)?
    private var defaultTextureNode: SKSpriteNode?
    private var defaultIconTexture: SKTexture?
    private var selectedtIconTexture: SKTexture?
    private var selectedTextureNode: SKSpriteNode?
    private var titleNode: SKLabelNode?
    private var backgroundNode: SKShapeNode!
    private var innerContainerNode: SKShapeNode!
    private var isLabeled = false
    
    init(
        withText text: String,
        named: String,
        position: CGPoint,
        size: CGSize,
        backgroundColor bgColor: UIColor = UIColor(hexString: "#004352"),
        shadowColor swColor: UIColor = UIColor(hexString: "#007793"),
        cornerRadius: CGFloat = 15
    ) {
        isLabeled = true
        super.init(texture: nil, color: .clear, size: CGSize(width: size.width / 2, height: size.height / 2))
        self.position = position
        self.zPosition = 1
        self.name = named

        // Background with rounded corners
        backgroundNode = SKShapeNode(rectOf: size, cornerRadius: cornerRadius)
        backgroundNode.fillColor = swColor
        backgroundNode.strokeColor = .clear
        backgroundNode.zPosition = -1
        addChild(backgroundNode)

        // Creating inner shadow layer
        let shadowSize = CGSize(width: size.width, height: size.height - 2)
        innerContainerNode = SKShapeNode(rectOf: shadowSize, cornerRadius: cornerRadius)
        innerContainerNode.fillColor = bgColor
        innerContainerNode.strokeColor = .clear
        innerContainerNode.position = CGPoint(x: 0, y: 2)
        innerContainerNode.zPosition = 0
        innerContainerNode.glowWidth = 1.0
        innerContainerNode.zPosition = -1
        addChild(innerContainerNode)
        
        // Label
        titleNode = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        titleNode!.text = text
        titleNode!.fontSize = 20
        titleNode!.fontColor = .white
        titleNode!.position = CGPoint(x: 0, y: -8)
        titleNode!.zPosition = 1
        addChild(titleNode!)
        
        isUserInteractionEnabled = true
    }
    
    init(
        withIcon icon: ImageResource,
        named: String,
        position: CGPoint,
        size: CGSize,
        backgroundColor bgColor: UIColor = UIColor(hexString: "#004352"),
        shadowColor swColor: UIColor = UIColor(hexString: "#007793"),
        cornerRadius: CGFloat = 15
    ) {
        isLabeled = false
        super.init(texture: nil, color: .clear, size: size)
        self.position = position
        self.zPosition = 1
        self.name = named

        // Background with rounded corners
        backgroundNode = SKShapeNode(rectOf: size, cornerRadius: cornerRadius)
        backgroundNode.fillColor = swColor
        backgroundNode.strokeColor = .clear
        backgroundNode.zPosition = -1
        addChild(backgroundNode)

        // Creating inner shadow layer
        let shadowSize = CGSize(width: size.width, height: size.height - 2)
        innerContainerNode = SKShapeNode(rectOf: shadowSize, cornerRadius: cornerRadius)
        innerContainerNode.fillColor = bgColor
        innerContainerNode.strokeColor = .clear
        innerContainerNode.position = CGPoint(x: 0, y: 2)
        innerContainerNode.zPosition = 0
        innerContainerNode.glowWidth = 1.0
        innerContainerNode.zPosition = -1
        addChild(innerContainerNode)
        
        defaultIconTexture = SKTexture(image: UIImage(resource: icon))
        defaultTextureNode = SKSpriteNode(texture: defaultIconTexture)
        defaultTextureNode!.zPosition = 1
        let textureSize = CGSize(width: size.width / 2, height: size.height / 2)
        defaultTextureNode?.aspectFitToSize(fitSize: textureSize)
        defaultTextureNode?.position = CGPoint(x: 0, y: 2)
        addChild(defaultTextureNode!)
        
        isUserInteractionEnabled = true
    }
    
    init(
        defaultStateIcon defaultIcon: ImageResource,
        selectedStateIcon selectedIcon: ImageResource,
        named: String,
        position: CGPoint,
        size: CGSize,
        backgroundColor bgColor: UIColor = UIColor(hexString: "#004352"),
        shadowColor swColor: UIColor = UIColor(hexString: "#007793"),
        cornerRadius: CGFloat = 15
    ) {
        isLabeled = false
        super.init(texture: nil, color: .clear, size: size)
        self.position = position
        self.zPosition = 1
        self.name = named

        // Background with rounded corners
        backgroundNode = SKShapeNode(rectOf: size, cornerRadius: cornerRadius)
        backgroundNode.fillColor = swColor
        backgroundNode.strokeColor = .clear
        backgroundNode.zPosition = -1
        addChild(backgroundNode)

        // Creating inner shadow layer
        let shadowSize = CGSize(width: size.width, height: size.height - 2)
        innerContainerNode = SKShapeNode(rectOf: shadowSize, cornerRadius: cornerRadius)
        innerContainerNode.fillColor = bgColor
        innerContainerNode.strokeColor = .clear
        innerContainerNode.position = CGPoint(x: 0, y: 2)
        innerContainerNode.zPosition = 0
        innerContainerNode.glowWidth = 1.0
        innerContainerNode.zPosition = -1
        addChild(innerContainerNode)
        
        let textureSize = CGSize(width: size.width / 2, height: size.height / 2)
        
        defaultIconTexture = SKTexture(image: UIImage(resource: defaultIcon))
        defaultTextureNode = SKSpriteNode(texture: defaultIconTexture)
        defaultTextureNode!.zPosition = 1
        defaultTextureNode?.aspectFitToSize(fitSize: textureSize)
        defaultTextureNode?.position = CGPoint(x: 0, y: 2)
        addChild(defaultTextureNode!)
        
        selectedtIconTexture = SKTexture(image: UIImage(resource: selectedIcon))
        selectedTextureNode = SKSpriteNode(texture: selectedtIconTexture)
        selectedTextureNode!.zPosition = 1
        selectedTextureNode?.aspectFitToSize(fitSize: textureSize)
        selectedTextureNode?.position = CGPoint(x: 0, y: 2)
        addChild(selectedTextureNode!)
        
        isUserInteractionEnabled = true
        UIView.performWithoutAnimation {
            updateIcon(isSelected: true)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateIcon(isSelected: Bool) {
        if isSelected {
            defaultTextureNode?.run(SKAction.fadeOut(withDuration: 0.1))
            selectedTextureNode?.run(SKAction.fadeIn(withDuration: 0.1))
        } else {
            selectedTextureNode?.run(SKAction.fadeOut(withDuration: 0.1))
            defaultTextureNode?.run(SKAction.fadeIn(withDuration: 0.1))
        }
    }
    
    // MARK: - Touch events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let moveDown = SKAction.move(to: CGPoint(x: 0, y: -2), duration: 0.2)
        innerContainerNode.run(moveDown)
        let hideLayer = SKAction.fadeOut(withDuration: 0.2)
        backgroundNode.run(hideLayer)
        if isLabeled {
            titleNode?.run(SKAction.move(to: CGPoint(x: 0, y: -10), duration: 0.2))
        } else {
            defaultTextureNode?.run(moveDown)
            selectedTextureNode?.run(moveDown)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let moveUp = SKAction.move(to: CGPoint(x: 0, y: 2), duration: 0.2)
        innerContainerNode.run(moveUp)
        let showLayer = SKAction.fadeIn(withDuration: 0.2)
        backgroundNode.run(showLayer) {
            self.touchUpInside?()
        }
        if isLabeled {
            titleNode?.run(SKAction.move(to: CGPoint(x: 0, y: -8), duration: 0.2))
        } else {
            defaultTextureNode?.run(moveUp)
            selectedTextureNode?.run(moveUp)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        let moveUp = SKAction.move(to: CGPoint(x: 0, y: 2), duration: 0.2)
        innerContainerNode.run(moveUp)
        let showLayer = SKAction.fadeIn(withDuration: 0.2)
        backgroundNode.run(showLayer)
        if isLabeled {
            titleNode?.run(SKAction.move(to: CGPoint(x: 0, y: -8), duration: 0.2))
        } else {
            defaultTextureNode?.run(moveUp)
            selectedTextureNode?.run(moveUp)
        }
    }
}
