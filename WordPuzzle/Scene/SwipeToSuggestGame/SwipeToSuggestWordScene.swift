//
//  SwipeToSuggestWordScene.swift
//  UIKitAnimations
//
//  Created by Coder ACJHP on 19.11.2024.
//

import UIKit
import SpriteKit

class SwipeToSuggestWordScene: SKScene {
    // UI Elements
    internal var wordSlots: [CustomLabelNode] = [] // Slots for the target words
    internal var letterNodes: [CustomLabelNode] = [] // Letters at the bottom
    internal var currentLetterPath: [CustomLabelNode] = [] // Tracks the user's current swipe path
    internal var swipingTextDisplayLabel: CustomLabelNode!
    internal var bannerRibbon: BannerRibbonNode!
    internal var closeButton: SKSpriteNode!
    internal var titleLabel: SKLabelNode!
    internal var diamondButton: SKSpriteNode!
    internal var diamondLabel: SKLabelNode!
    internal var dictionaryButton: SKSpriteNode!
    internal var extraWordsButton: SKSpriteNode!
    internal var shuffleButton: SKSpriteNode!
    internal var hintButton: SKSpriteNode!
    
    internal var lastTouchLocation: CGPoint?
    internal var currentLinePath: CGMutablePath!
    internal var swipeLine = SKShapeNode()
    internal var swipeLineColor = UIColor.white
    
    // Game State vars
    internal var targetWords: [String] = [] // Words for the current level
    internal var guessedWords: Set<String> = [] // Words guessed by the player
    internal var extraWords: Set<String> = [] // Words guessed by the player but level doesnt contains it
    internal var guessedExtraWords: Set<String> = [] // Words guessed by the player but level doesnt contains it
    internal var letterPool: String = "" // Pool of letters to display
    internal var isWordFound: Bool = false // Used for animation
    internal var hintedLettersList: Array<String> = []
    internal var longestWordInCurrentLevel: String = ""
    // Level Data
    internal var currentLevel: Int = 1 {
        didSet { minRequiredDiamonds = currentLevel }
    }
    // Diamond count for each hint changes based on levels
    internal var minRequiredDiamonds: Int = .zero
    internal var diamonds: Int = .zero
    internal let rowCount = 6
    internal let columnCount = 7
    internal let levelsManger = SwipeGameLevelManager.shared
    // Game state update variables
    internal let notificationCenter = NotificationCenter.default
        
    // MARK: - Lifecycle
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        loadLastGameData()
        
        // Observe Notifications for saving game data
        notificationCenter.addObserver(
            self,
            selector: #selector(updateGameStateInDatabase),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(updateGameStateInDatabase),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        // Cleanup Observers
        notificationCenter.removeObserver(self)
        // Remove all child nodes
        self.removeAllChildren()
        // Remove all actions
        self.removeAllActions()
        // Remove it self
        self.removeFromParent()
    }
    
    // MARK: - Configure ui components
    
    private func configureBackground() {
        let gradientTexture = SKTexture(
            vectorNoiseWithSmoothness: 1.0,
            size: CGSize(
                width: frame.width / 2,
                height: frame.height / 2
            )
        )
        let background = SKSpriteNode(texture: gradientTexture)
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.size = frame.size
        background.zPosition = -1
        background.name = "backgroundNode"
        addChild(background)
    }
    
    private func configureSwipeLine() {
        swipeLine.strokeColor = .white
        swipeLine.lineWidth = 8
        swipeLine.lineCap = .round
        swipeLine.lineJoin = .round
        swipeLine.name = "swipeLine"
        
        currentLinePath = CGMutablePath()
        swipeLine.path = currentLinePath
        
        addChild(swipeLine)
    }
    
    private func configureDiamondLabel() {
        let texture = SKTexture(image: UIImage(resource: .suitDiamond))
        diamondButton = SKSpriteNode(texture: texture)
        diamondButton.name = "diamondButton"
        diamondButton.position = CGPoint(x: 30, y: size.height - 55)
        diamondButton.setScale(0.7)
        // Add the diamond button to the scene
        addChild(diamondButton)
        
        diamondLabel = SKLabelNode(text: "\(diamonds)")
        diamondLabel.fontName = "AvenirNext-Bold"
        diamondLabel.fontSize = 20
        diamondLabel.fontColor = .white
        diamondLabel.verticalAlignmentMode = .center
        diamondLabel.position = CGPoint(x: diamondButton.position.x + 30, y: diamondButton.position.y)
        diamondLabel.isUserInteractionEnabled = false
        // Add the label as child
        addChild(diamondLabel)
    }
    
    private func setupCloseButton() {
        // Create "X" button
        let texture = SKTexture(image: UIImage(resource: .xCircle))
        closeButton = SKSpriteNode(texture: texture)
        closeButton.setScale(0.7)
        closeButton.position = CGPoint(x: size.width - 30, y: size.height - 55)
        closeButton.name = "closeButton"
        
        // Add the close button to the scene
        addChild(closeButton)
    }
    
    private func configureTitleLabel() {
        titleLabel = SKLabelNode(text: "Level \(currentLevel)")
        titleLabel.fontName = "AvenirNext-Bold"
        titleLabel.fontSize = 20
        titleLabel.fontColor = .white
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height - 55)
        // Add the close button to the scene
        addChild(titleLabel)
    }
    
    private func setupShuffleButton() {
        let texture = SKTexture(image: UIImage(resource: .shuffle))
        shuffleButton = SKSpriteNode(texture: texture)
        shuffleButton.position = CGPoint(x: size.width - 40, y: 40)
        shuffleButton.name = "shuffleButton"
        shuffleButton.setScale(0.7)
        
        // Add the shuffle button to the scene
        addChild(shuffleButton)
    }
    
    private func setupDictionaryButton() {
        
        let topMargin: CGFloat = size.height - 110 // Position the word slots near the top
        let spacing: CGFloat = 10 // Spacing between squares
        let availableWidth = self.size.width - (spacing * 9)
        let squareSize: CGFloat = availableWidth / CGFloat(columnCount) // Size of each rounded square
        let wordSpacing = squareSize + spacing // Spacing between words
        let posiX = spacing * 4
        let posiY = (topMargin - CGFloat(rowCount) * wordSpacing) - 10
            
            
        let texture = SKTexture(image: UIImage(resource: .dictionary))
        dictionaryButton = SKSpriteNode(texture: texture)
        dictionaryButton.position = CGPoint(x: posiX, y: posiY)
        dictionaryButton.name = "dictionaryButton"
        
        // Add the shuffle button to the scene
        addChild(dictionaryButton)
    }    
    
    private func setupExtraWordsButton() {
        let posiX = size.width - 30
        let posiY = dictionaryButton.position.y
            
        let texture = SKTexture(image: UIImage(resource: .list))
        extraWordsButton = SKSpriteNode(texture: texture)
        extraWordsButton.position = CGPoint(x: posiX, y: posiY)
        extraWordsButton.name = "notIncludedButton"
        extraWordsButton.setScale(0.9)
        
        // Add the shuffle button to the scene
        addChild(extraWordsButton)
    }
    
    private func setupHintButton() {
        let texture = SKTexture(image: UIImage(resource: .hint))
        hintButton = SKSpriteNode(texture: texture)
        hintButton.position = CGPoint(x: 40, y: 40)
        hintButton.name = "hintButton"
        hintButton.setScale(0.7)
        
        // Add the shuffle button to the scene
        addChild(hintButton)
        
        shakeHintButtonForever()
    }
    
    private func configureSwipingTextDisplayLabel() {
        swipingTextDisplayLabel = CustomLabelNode(
            text: "",
            fontSize: 35,
            fontColor: .white,
            backgroundColor: .appDarkerBlue,
            borderColor: .white,
            cornerRadius: 10
        )
        swipingTextDisplayLabel.autoUpdateBackground = true
        swipingTextDisplayLabel.name = "displaySwipingLettersLabel"
        swipingTextDisplayLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        swipingTextDisplayLabel.alpha = .zero
        // Add the close button to the scene
        addChild(swipingTextDisplayLabel)
    }
    
    private func configureBannerRibbon() {
        bannerRibbon = BannerRibbonNode(title: "GREAT")
        bannerRibbon.position = CGPoint(x: size.width / 2, y: size.height / 2 - 15)
        bannerRibbon.name = "bannerRibbon"
        // Add the shuffle button to the scene
        addChild(bannerRibbon)
        // Hide with scale by default
        bannerRibbon.setScale(.zero)
    }
    
    private func setupWordSlots() {
        let topMargin: CGFloat = size.height - 110 // Position the word slots near the top
        let spacing: CGFloat = 10 // Spacing between squares
        let availableWidth = self.size.width - (spacing * 9)
        let squareSize: CGFloat = availableWidth / CGFloat(columnCount) // Size of each rounded square
        let wordSpacing = squareSize + spacing // Spacing between words
        
        // Slot pathes
        for index in 0 ..< rowCount {
            // Calculate the starting position to center the word
            let startX = spacing * 4
            let yPosition = topMargin - CGFloat(index) * wordSpacing
            
            for charIndex in 0 ..< columnCount {
                
                let label = CustomLabelNode(
                    text: "",
                    fontSize: 35,
                    fontColor: .white,
                    backgroundColor: #colorLiteral(red: 0, green: 0.3285208941, blue: 0.5748849511, alpha: 0.08979201159),
                    borderColor: #colorLiteral(red: 0, green: 0.3285208941, blue: 0.5748849511, alpha: 0.08979201159),
                    cornerRadius: 8
                )
                label.position = CGPoint(x: startX + CGFloat(charIndex) * (squareSize + spacing), y: yPosition)
                // Add the square to the scene
                addChild(label)
            }
        }
        
        // Real slots
        
        for (wordIndex, word) in targetWords.enumerated() {
            // Calculate the starting position to center the word
            let startX = spacing * 4
            let yPosition = topMargin - CGFloat(wordIndex) * wordSpacing
            
            for (charIndex, _) in word.enumerated() {
                
                let label = CustomLabelNode(
                    text: "",
                    fontSize: 32,
                    fontColor: .white,
                    fontName: "AvenirNext-DemiBold",
                    backgroundColor: .appBlue,
                    borderColor: .appBlue,
                    cornerRadius: 8
                )
                label.position = CGPoint(x: startX + CGFloat(charIndex) * (squareSize + spacing), y: yPosition)
                label.name = "slotSquare_\(wordIndex)_\(charIndex)" // Unique name for the square
                // Add the square to the scene
                addChild(label)
                wordSlots.append(label)
            }
        }
    }
    
    private func setupLetterNodes() {
        let availableWidth = size.width * 0.7 // Subtract left (20px) and right (20px) padding
        let radius: CGFloat = availableWidth / 3 // Maximum radius based on available width
        let angleStep = CGFloat.pi * 2 / CGFloat(letterPool.count) // Angle between letters for full circle
        let startAngle = -CGFloat.pi / 2 // Start at the top of the circle (upside down)
        let squareSize: CGFloat = 50 // Size of each rounded square
        let shuffledLetters = letterPool.shuffled()
        
        // Calculate the center point
        let bottomCenter = CGPoint(x: size.width / 2, y: size.height * 0.25) // Center of the circle
        
        for (index, char) in shuffledLetters.enumerated() {
            let angle = startAngle + CGFloat(index) * angleStep
            let x = bottomCenter.x + radius * cos(angle)
            let y = bottomCenter.y + radius * sin(angle)
            let position = CGPoint(x: x, y: y)
            
            let letterNode = CustomLabelNode(
                size: CGSize(width: squareSize, height: squareSize),
                text: String(char),
                fontSize: 35,
                fontColor: .white,
                fontName: "AvenirNext-DemiBold",
                backgroundColor: .appBlue,
                borderColor: .white,
                cornerRadius: 8
            )
            letterNode.position = position
            letterNode.name = "letter_\(String(char))"

            // Add the square to the scene
            addChild(letterNode)
            letterNodes.append(letterNode)
        }
    }
    
    // MARK: - Game functionalities
    
    
    
    private func dismissGameScene() {
        NavigationManager.shared.returnToMenuScene()
    }
    
    internal func shuffleLetters() {
        // Step 1: Rotate all nodes around the circular path 2 times (fast and smooth, clockwise)
        let bottomCenter = CGPoint(x: size.width / 2, y: size.height * 0.25) // Circle center
        let availableWidth = size.width * 0.7 // Account for padding
        let radius: CGFloat = availableWidth / 3 // Circle radius
        let angleStep = CGFloat.pi * 2 / CGFloat(letterNodes.count) // Angle between nodes
        let startAngle = -CGFloat.pi / 2 // Top of the circle
        
        // Set initial positions of the nodes around the circle
        for (index, node) in letterNodes.enumerated() {
            let initialAngle = startAngle + CGFloat(index) * angleStep
            node.position = CGPoint(
                x: bottomCenter.x + radius * cos(initialAngle),
                y: bottomCenter.y + radius * sin(initialAngle)
            )
        }
        
        // Animate clockwise rotation for all nodes
        let rotateAction = SKAction.customAction(withDuration: 1.0) { _, elapsedTime in
            let progress = elapsedTime / 1.0 // Duration is 1 second
            let rotationAngle = progress * CGFloat.pi * 2 // full revolutions (clockwise)
            for (index, node) in self.letterNodes.enumerated() {
                let baseAngle = startAngle + CGFloat(index) * angleStep
                let currentAngle = baseAngle - rotationAngle // Subtract to rotate clockwise
                node.position = CGPoint(
                    x: bottomCenter.x + radius * cos(currentAngle),
                    y: bottomCenter.y + radius * sin(currentAngle)
                )
            }
        }
        
        // Run rotation animation for all nodes
        let waitAction = SKAction.wait(forDuration: 1.0) // Delay to start the next step
        let rotationSequence = SKAction.sequence([rotateAction, waitAction])
        for node in letterNodes {
            node.run(rotationSequence)
        }
        
        // Proceed to next steps after rotation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Step 2: Move all nodes to the center smoothly
            let moveToCenterAction = SKAction.move(to: bottomCenter, duration: 0.5)
            moveToCenterAction.timingMode = .easeInEaseOut
            
            for node in self.letterNodes {
                node.run(moveToCenterAction)
            }
            
            // Wait for move-to-center to finish
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Step 3: Shuffle the nodes
                let shuffledNodes = self.letterNodes.shuffled()
                
                // Step 4: Relocate nodes to circular path in shuffled order
                for (index, node) in shuffledNodes.enumerated() {
                    let newAngle = startAngle + CGFloat(index) * angleStep
                    let newPosition = CGPoint(
                        x: bottomCenter.x + radius * cos(newAngle),
                        y: bottomCenter.y + radius * sin(newAngle)
                    )
                    
                    // Animate movement to new position
                    let moveToNewPositionAction = SKAction.move(to: newPosition, duration: 0.5)
                    moveToNewPositionAction.timingMode = .easeInEaseOut
                    node.run(moveToNewPositionAction)
                }
                
                // Update the letterNodes array to reflect the new order
                self.letterNodes = shuffledNodes
            }
        }
    }
    
    // MARK: - Save & Load game state

    private func saveGameData() {
        let state = SwipeGameState(
            level: currentLevel,
            diamonds: diamonds,
            guessedWords: Array(guessedWords),
            extraWords: Array(extraWords),
            guessedExtraWords: Array(guessedExtraWords),
            hintsUsed: hintedLettersList, // Save the actual list of hinted letters
            targetWords: targetWords
        )
        let encoder = JSONEncoder()
        do {
            let encodedState = try encoder.encode(state)
            let defaults = UserDefaults.standard
            defaults.set(encodedState, forKey: "gameState")
            defaults.synchronize()
        } catch {
            print("Failed to save game state: \(error)")
        }
    }
    
    private func loadLastGameData() {
        let defaults = UserDefaults.standard

        // Check if game state exists in UserDefaults
        if let savedGameState = defaults.data(forKey: "gameState") {
            let decoder = JSONDecoder()
            do {
                let state = try decoder.decode(SwipeGameState.self, from: savedGameState)
                currentLevel = state.level
                diamonds = state.diamonds
                guessedWords = Set(state.guessedWords)
                extraWords = Set(state.extraWords)
                guessedExtraWords = Set(state.guessedExtraWords)
                hintedLettersList = state.hintsUsed // Load the actual list of hinted letters
                targetWords = state.targetWords

                // Load the level layout
                loadLevel(currentLevel, fromDB: true)

                // Populate guessed words into slots
                for guessedWord in guessedWords {
                    fillWordSlot(guessedWord)
                }

                // Handle hinted letters
                for char in hintedLettersList {
                    if let firstEmptySlot = wordSlots.filter({ $0.text == "" }).first {
                        firstEmptySlot.text = char
                    }
                }

            } catch {
                print("Failed to decode game state: \(error)")
                resetGameStateToDefault()
            }
        } else {
            resetGameStateToDefault()
        }
    }
    
    private func resetGameStateToDefault() {
        currentLevel = 1
        // Load the level layout
        guessedWords = []
        guessedExtraWords = []
        hintedLettersList = []
        wordSlots = []
        letterNodes = []
        currentLetterPath = []
        // Clear previous level state
        removeAllChildren()
        loadLevel(currentLevel)
    }
    
    @objc func updateGameStateInDatabase() {
        saveGameData()
    }
    
    // MARK: - Swiping line codes
    
    private func connectSwipeLinesIfNeeded(currentLocation location: CGPoint) {
        // Update the line path
        let points = currentLetterPath.map { $0.center } // Get the center of each letter node
        // Ensure the points array has at least one point
        if points.count > 0 {
            // Reset the current line path
            currentLinePath = CGMutablePath()
            // Start the line from the first letter node position (center of the first node)
            let firstLetterPosition = points.first!
            currentLinePath.move(to: firstLetterPosition)
            // Draw the line between each letter node
            for (index, point) in points.enumerated() {
                // Connect points with a straight line
                if index > 0 { currentLinePath.addLine(to: point) }
            }
            // Add a straight line to the current touch location
            currentLinePath.addLine(to: location)
            // Update the swipeLine's path
            swipeLine.path = currentLinePath
        }
    }
    
    private func resetSwipeLinePath() {
        let changeColor = SKAction.customAction(withDuration: 0.3) { [weak self] _, _ in
            guard let self else { return }
            swipeLine.strokeColor = swipeLineColor
        }
        let resetColor = SKAction.customAction(withDuration: 0.3) { [weak self] _, _ in
            guard let self else { return }
            swipeLine.strokeColor = .white
            swipeLine.path = nil // Optionally clear the line when touch ends
        }
        let animation = SKAction.sequence([changeColor, resetColor])
        swipeLine.run(animation)
        currentLinePath = CGMutablePath() // Reset for the next line
        lastTouchLocation = nil // Reset the last touch location
    }
    
    // MARK: - Letter slots code
    
    // Fill top part of slots by given word
    private func fillWordSlot(_ word: String) {
        guard let wordIndex = targetWords.firstIndex(of: word) else { return }
        
        for (charIndex, char) in word.enumerated() {
            // Find the corresponding label inside the square
            let squareName = "slotSquare_\(wordIndex)_\(charIndex)"
            if let label = childNode(withName: squareName) as? CustomLabelNode {
                label.text = String(char) // Set the letter
                
                // Set initial scale to zero for the scaling effect
                label.labelNode.setScale(0)
                
                // Create a scale-up animation
                let scaleUpAction = SKAction.scale(to: 1.0, duration: 0.3) // Scale to normal size over 0.3 seconds
                scaleUpAction.timingMode = .easeInEaseOut // Smooth the animation
                
                // Add a delay based on the character index for ordered animation
                let delay = SKAction.wait(forDuration: Double(charIndex) * 0.1)
                
                // Sequence the delay and scale-up actions
                let sequence = SKAction.sequence([delay, scaleUpAction])
                
                // Run the animation
                label.labelNode.run(sequence)
            }
        }
    }
    
    // Remove bottom letters from the scene (animated)
    private func removeLetterNodes(completion: (() -> Void)? = nil) {
        for (index, node) in letterNodes.enumerated() {
            let fadeOutAction = SKAction.fadeOut(withDuration: 0.3)
            let shrinkAction = SKAction.scale(to: .zero, duration: 0.3)
            let shrinkGroup = SKAction.group([fadeOutAction, shrinkAction])
            
            // Add a delay based on the character index for ordered animation
            let delay = SKAction.wait(forDuration: Double(index) * 0.1)
            // Sequence the delay and scale-up actions
            let sequence = SKAction.sequence([delay, shrinkGroup])
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) { [weak self] in
                guard let self else { return }
                animateStarShine(onNode: node, forDuration: 0.4)
            }
            node.run(sequence) {
                completion?()
            }
        }
    }
    // Reset bottom letters with animation
    private func resetInteractedLetters() {
        currentLetterPath.forEach {
            $0.run(SKAction.scale(to: 1.0, duration: 0.3))
        }
        currentLetterPath = []
    }
    
    // MARK: - Game State Checkers
    
    // Collect all swiped letters and create a word if it's possible
    private func checkFormedWordState() {
        // Create a word from letter path
        let formedWord = currentLetterPath.map { $0.text! }.joined()
        var labelColor: UIColor = .black
        // If the word has already been guessed, show the message
        if guessedWords.contains(formedWord) {
            showShortMessage(text: "You've already guessed that word.")
            labelColor = .yellow
        // If targetWords contains the guessed word and isn't guessed before
        } else if targetWords.contains(formedWord), !guessedWords.contains(formedWord) {
            guessedWords.insert(formedWord)
            fillWordSlot(formedWord)
            isWordFound = true
            labelColor = .green
        // If extraWords contains the guessed word and isn't guessed before as extra
        } else if extraWords.contains(formedWord), !guessedExtraWords.contains(formedWord) {
            guessedExtraWords.insert(formedWord)
            showShortMessage(text: "Well done, you got 1 diamond.")
            // Animate diamond move
            animateDiamondMove(fromNode: swipingTextDisplayLabel, toNode: diamondButton, duration: 2.0) { [weak self] in
                guard let self else { return }
                diamonds += 1
                diamondLabel.text = "\(diamonds)"
                let growAction = SKAction.scale(to: 1.3, duration: 0.3)
                let shrinkAction = SKAction.scale(to: 1.0, duration: 0.3)
                let actionSequence = SKAction.sequence([growAction, shrinkAction])
                actionSequence.timingMode = .easeInEaseOut
                diamondLabel.run(actionSequence)
            }
            
            labelColor = .yellow
        } else {
            labelColor = .red
        }
        
        // Remove label
        swipingTextDisplayLabel.backgroundColor = labelColor
        swipingTextDisplayLabel.run(SKAction.fadeOut(withDuration: 0.3)) { [weak self] in
            guard let self else { return }
            swipingTextDisplayLabel.text = ""
            swipingTextDisplayLabel.backgroundColor = .appBlue
        }
        
        // Show banner ribbon for longest word
        if isWordFound, formedWord == longestWordInCurrentLevel {
            showBannerRibbon()
        }
        
        // Change swipeLine color to animate
        swipeLineColor = labelColor
    }
    
    // MARK: - Load and unload level code
    
    internal func loadLevel(_ level: Int, fromDB: Bool = false) {
        guard levelsManger.isValidLevel(index: level - 1) else {
            showPopup(
                withTitle: "Error",
                message: "Invalid level. Please restart the game.",
                buttonTitle: "Dismiss",
                completion: { [weak self] in self?.dismissGameScene() }
            )
            return
        }
        
        let levelData = levelsManger.getLevel(forIndex: level - 1)
        // If loading from the scratch release all old data
        if !fromDB {
            extraWords = []
            guessedExtraWords = []
            guessedWords = []
            hintedLettersList = []
            targetWords = []
            letterPool = ""
            longestWordInCurrentLevel = ""
            wordSlots.removeAll()
            letterNodes.removeAll()
            currentLetterPath.removeAll()
        }
        
        targetWords = levelData.targetWords
        extraWords = Set(levelData.extraWords)
        letterPool = levelData.letters
        longestWordInCurrentLevel = targetWords.max(by: { $0.count < $1.count }) ?? targetWords.first ?? ""
        
        configureBackground()
        configureDiamondLabel()
        configureTitleLabel()
        setupCloseButton()
        setupWordSlots()
        setupLetterNodes()
        configureSwipeLine()
        setupHintButton()
        setupShuffleButton()
        setupDictionaryButton()
        setupExtraWordsButton()
        configureSwipingTextDisplayLabel()
        configureBannerRibbon()
    }
    
    internal func runNextLevelIfNeeded() {
        // Chek all word found
        if guessedWords.count == targetWords.count {
            // Show ribbon and then popup
            showBannerRibbon(withText: "GREAT!") { [weak self] in
                guard let self else { return }
                // Remove letters
                removeLetterNodes() {[weak self] in
                    guard let self else { return }
                    // Show popup
                    showPopup(
                        withTitle: "Level Complete!",
                        message: "Great job! Get ready for the next level.",
                        buttonTitle: "Continue",
                        completion: { [weak self] in
                            guard let self else { return }
                            // Remove all child nodes
                            self.removeAllChildren()
                            currentLevel += 1
                            loadLevel(currentLevel)
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Touch Events
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        // Reset the flag
        isWordFound = false
        switch touchLocation {
        case let point where closeButton.frame.contains(point):
            saveGameData()
            dismissGameScene()
        case let point where shuffleButton.frame.contains(point):
            shuffleLetters()
        case let point where hintButton.frame.contains(point):
            showHint()
        case let point where diamondButton.frame.contains(point):
            showPaywallScene()
        case let point where dictionaryButton.frame.contains(point):
            showDictionaryPopup()
        case let point where extraWordsButton.frame.contains(point):
            showExtraWordsListPopup()
        default:
            if let touchedNode = atPoint(touchLocation) as? CustomLabelNode,
                letterNodes.contains(touchedNode) {
                currentLinePath = CGMutablePath() // Start a new path
                currentLinePath.move(to: touchedNode.center) // Start the path at the touch location
                lastTouchLocation = touchedNode.center // Set the first touch location
                swipingTextDisplayLabel.text = touchedNode.text
                swipingTextDisplayLabel.run(SKAction.fadeIn(withDuration: 0.3))
            }
            break
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Check if the touch location is over any letterNode and it's not already part of the currentLetterPath
        for letterNode in letterNodes {
            if letterNode.contains(location), !currentLetterPath.contains(letterNode) {
                // Append the new letter node to the path
                currentLetterPath.append(letterNode)
                // Apply a scale and highlight effect on the selected letter
                letterNode.run(SKAction.scale(to: 1.2, duration: 0.1))
                // Show letters in label
                swipingTextDisplayLabel.alpha = 1.0
                swipingTextDisplayLabel.text = currentLetterPath.map { $0.text! }.joined()
            }
        }
        
        // Draw lines
        connectSwipeLinesIfNeeded(currentLocation: location)
    }

    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // If already founded show message else add it to guesses words
        checkFormedWordState()
        // Remove drawn line
        resetSwipeLinePath()
        // Reset letter nodes to original color and scale
        resetInteractedLetters()
        // Check if level is completed
        runNextLevelIfNeeded()
    }
}


