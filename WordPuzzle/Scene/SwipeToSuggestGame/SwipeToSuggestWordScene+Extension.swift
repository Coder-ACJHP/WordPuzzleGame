//
//  SwipeToSuggestWordScene+Extension.swift
//  WordPuzzle
//
//  Created by Coder ACJHP on 22.11.2024.
//

import Foundation
import UIKit
import SpriteKit

extension SwipeToSuggestWordScene {
    
    // MARK: - Helper functions
    
    internal func showShortMessage(text: String) {
        // Create the label for the message
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 1.5
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.black
        shadow.shadowBlurRadius = 10
        shadow.shadowOffset = .zero
        let attrs: [NSAttributedString.Key : Any] = [
            .foregroundColor : UIColor.white,
            .font : UIFont(name: "AvenirNext-Regular", size: 18) ?? .systemFont(ofSize: 18),
            .paragraphStyle : paragraphStyle,
            .shadow : shadow
        ]
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttributes(attrs, range: NSRange(location: 0, length: text.count))
        let messageLabel = SKLabelNode(attributedText: attributedString)
        messageLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        messageLabel.horizontalAlignmentMode = .center
        messageLabel.verticalAlignmentMode = .center
        messageLabel.numberOfLines = 0
        messageLabel.preferredMaxLayoutWidth = self.size.width * 0.7
        messageLabel.alpha = 0
        addChild(messageLabel)
        
        // Animate the message label to fade in and then out
        let fadeIn = SKAction.fadeIn(withDuration: 0.2)
        let wait = SKAction.wait(forDuration: 0.6)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        
        let sequence = SKAction.sequence([fadeIn, wait, fadeOut])
        
        // Run the sequence and then remove the message label
        messageLabel.run(sequence) {
            messageLabel.removeFromParent() // Remove the label after the animation
        }
    }
    
    internal func shakeHintButtonForever() {
        // Define keyframes for the rotation angles
        let keyframeRotations: [CGFloat] = [-0.15, 0.15, -0.07, 0.07, -0.05, 0.05, 0] // Rotation angles in radians
        let keyframeDurations: [TimeInterval] = [0.15, 0.15, 0.1, 0.1, 0.1, 0.1, 0.2] // Durations for each keyframe
        
        // Ensure keyframeRotations and keyframeDurations are of the same length
        guard keyframeRotations.count == keyframeDurations.count else {
            print("Keyframes mismatch: Check rotations and durations arrays")
            return
        }
        
        // Build the keyframe actions
        var actions: [SKAction] = []
        for (index, rotation) in keyframeRotations.enumerated() {
            let duration = keyframeDurations[index]
            let action = SKAction.rotate(toAngle: rotation, duration: duration, shortestUnitArc: true)
            actions.append(action)
        }
        
        // Create the keyframe animation
        let waitAction = SKAction.wait(forDuration: 1.0)
        actions.append(waitAction)
        let keyframeSequence = SKAction.sequence(actions)
        let repeatForever = SKAction.repeatForever(keyframeSequence)
        hintButton.run(repeatForever)
    }
    
    internal func showDictionary(for word: String) {
        let userInfo = ["word": word]
        NotificationCenter.default.post(name: .needsToShowDictionary, object: nil, userInfo: userInfo)
    }
    
    internal func showDictionaryPopup() {
        let popup = CustomDictionaryPopupNode(
            title: "Guessed Words",
            message: "Tap on word to see meainings in the dictionary",
            guessedWords: guessedWords
        ) { [weak self] didTapOnWord in
            guard let self else { return }
            showDictionary(for: didTapOnWord)
        }
        popup.zPosition = 100
        addChild(popup)
        popup.alpha = .zero
        // Animate
        popup.run(SKAction.fadeIn(withDuration: 0.3))
    }
    
    internal func showExtraWordsListPopup() {
        let popup = CustomDictionaryPopupNode(
            title: "Extra Words",
            message: "These are real words you guessed, but they’re not part of this level.",
            guessedWords: guessedExtraWords
        ) { [weak self] didTapOnWord in
            guard let self else { return }
            showDictionary(for: didTapOnWord)
        }
        popup.zPosition = 100
        addChild(popup)
        popup.alpha = .zero
        // Animate
        popup.run(SKAction.fadeIn(withDuration: 0.3))
    }
    
    internal func showPopup(withTitle title: String, message: String, buttonTitle: String, completion: @escaping () -> Void) {
        let popup = CustomPopupNode(
            title: title,
            message: message,
            buttonTitle: buttonTitle,
            buttonAction: { completion() }
        )
        popup.zPosition = 100
        addChild(popup)
        popup.alpha = .zero
        // Animate
        popup.run(SKAction.fadeIn(withDuration: 0.3))
    }
    
    internal func showPaywallScene() {
        let overlay = PaywallOverlay(size: self.size)
        overlay.zPosition = 10 // Ensure it appears on top of other nodes
        overlay.name = "paywallOverlay"
        addChild(overlay)
        overlay.alpha = .zero
        overlay.run(SKAction.fadeIn(withDuration: 0.3))
    }
    
    internal func showHint() {
        guard diamonds >= minRequiredDiamonds else {
            showShortMessage(text: "you don't have enough diamonds, maybe you'll consider buying some.")
            return
        }
        guard let firstEmptySlot = wordSlots.filter({ $0.text == "" }).first,
              let slotName = firstEmptySlot.name
        else {
            print("No empty slot for hint.")
            return
        }
        
        // Validate slotName format using regex
        let regex = try! NSRegularExpression(pattern: "^slotSquare_\\d+_\\d+$")
        let range = NSRange(location: 0, length: slotName.utf16.count)
        guard regex.firstMatch(in: slotName, options: [], range: range) != nil else {
            print("Invalid slotName format: \(slotName)")
            return
        }

        // Parse wordIndex and charIndex from the validated slotName
        let cleanText = slotName.replacingOccurrences(of: "slotSquare_", with: "")
        let components = cleanText.split(separator: "_")
        guard components.count == 2,
              let wordIndex = Int(components[0]),
              let charIndex = Int(components[1]),
              wordIndex < targetWords.count
        else {
            print("Failed to parse indices from slotName: \(slotName)")
            return
        }

        let word = targetWords[wordIndex]
        guard charIndex < word.count else {
            print("Character index out of bounds for word: \(word)")
            return
        }
        
        let char = Array(word)[charIndex]
        hintedLettersList.append(String(char))

        if let label = childNode(withName: slotName) as? CustomLabelNode {
            label.text = String(char) // Set the letter
            label.labelNode.alpha = 0 // Start with alpha 0
            // Animate diamond move
            animateDiamondMove(fromNode: hintButton, toNode: label, duration: 2.0) {
                label.labelNode.run(SKAction.fadeIn(withDuration: 0.1)) // Animate fade-in
            }
        }
        
        // Update diamonds and label
        diamonds -= 1
        diamondLabel.text = "\(diamonds)"
        let growAction = SKAction.scale(to: 1.2, duration: 0.3)
        let shrinkAction = SKAction.scale(to: 1.0, duration: 0.3)
        let actionSequence = SKAction.sequence([growAction, shrinkAction])
        actionSequence.timingMode = .easeInEaseOut
        diamondLabel.run(actionSequence)
        
        // Add created word to guessed word list then check if level finished
        let formedWord = hintedLettersList.joined()
        if targetWords.contains(formedWord), !guessedWords.contains(formedWord) {
            guessedWords.insert(formedWord)
            hintedLettersList = []
            runNextLevelIfNeeded()
        }
    }
    
    internal func showBannerRibbon(withText text: String = "GOOD!", completion: (() -> Void)? = nil) {
        let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        let growAction = SKAction.scale(to: 1.0, duration: 0.3)
        let growGroup = SKAction.group([fadeInAction, growAction])
        
        let waitAction = SKAction.wait(forDuration: 1.0)
        
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.3)
        let shrinkAction = SKAction.scale(to: .zero, duration: 0.3)
        let shrinkGroup = SKAction.group([fadeOutAction, shrinkAction])
        
        let actionSequece = SKAction.sequence([growGroup, waitAction, shrinkGroup])
        actionSequece.timingMode = .easeInEaseOut
        bannerRibbon.title = text
        bannerRibbon.run(actionSequece) {
            completion?()
        }
    }
    
    // MARK: - Animations
    
    internal func animateStarShine(onNode node: SKNode, forDuration duration: TimeInterval) {
        // Load the particle emitter
        if let starEmitter = SKEmitterNode(fileNamed: "ShineParticle.sks") {
            starEmitter.position = node.position
            addChild(starEmitter)
            
            let task = DispatchWorkItem { starEmitter.removeFromParent() }
            DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: task)
        }
    }
    
    internal func animateDiamondMove(fromNode: SKNode, toNode: SKNode, duration: TimeInterval, completion: (() -> Void)? = nil) {
        // Load the particle emitter
        if let diamondEmitter = SKEmitterNode(fileNamed: "DiamondParticle.sks") {
            diamondEmitter.position = fromNode.position
            addChild(diamondEmitter)
            // move emitter from node position to toNode position
            let moveAction = SKAction.move(to: toNode.position, duration: duration)
            moveAction.timingMode = .easeIn
            diamondEmitter.run(moveAction)
            
            let task = DispatchWorkItem {
                diamondEmitter.removeFromParent()
                completion?()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: task)
        }
    }
}
