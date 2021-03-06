//
//  GameScene.swift
//  CrackerShake
//
//  Created by Atin Agnihotri on 09/08/21.
//

import SpriteKit

// Note : use cmd + ctrl + z to do Shake Gesture on Simulator

class GameScene: SKScene {
    
    let leftEdge = -22
    let rightEdge = 1024 + 22
    let bottomEdge = -22
    
    var gameTimer: Timer?
    var fireworks = [SKNode]()
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var barragesLeft = 30 {
        didSet {
            print("Barrages Left: \(barragesLeft)")
            if barragesLeft <= 0 {
                areBarragesLeft = false
            }
        }
    }
    var areBarragesLeft = true
    
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupScoreLabel()
        setupGameTimer()
    }
    
    func setupBackground() {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -2
        addChild(background)
    }
    
    func setupGameTimer() {
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireWorks), userInfo: nil, repeats: true)
    }
    
    func setupScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.zPosition = 2
        scoreLabel.position = CGPoint(x: 1000, y: 700)
        score = 0
        addChild(scoreLabel)
    }
    
    @objc func launchFireWorks() {
        guard barragesLeft > 0 else  { return }
        
        let xMovement: CGFloat = 1800
        
        switch Int.random(in: 0...3) {
        case 0:
            // five rockets straight up
            createLinearBarrage(from: bottomEdge)
        case 1:
            // five fireworks in a fan
            createFanBarrage(from: bottomEdge)
        case 2:
            // five rockets from bottom left in diagonal
         createDiagonalBarrage(withLateralSpeed: xMovement, fromX: leftEdge, y: bottomEdge)
        case 3:
            // five rockets from bottom right in diagonal
         createDiagonalBarrage(withLateralSpeed: -1 * xMovement, fromX: rightEdge, y: bottomEdge)
        default:
            break
        }
        
    }
    
    func createLinearBarrage(from edge: Int) {
        createFireWork(withLateralSpeed: 0, at: CGPoint(x: 512, y: edge))
        createFireWork(withLateralSpeed: 0, at: CGPoint(x: 512 - 100, y: edge))
        createFireWork(withLateralSpeed: 0, at: CGPoint(x: 512 - 200, y: edge))
        createFireWork(withLateralSpeed: 0, at: CGPoint(x: 512 + 100, y: edge))
        createFireWork(withLateralSpeed: 0, at: CGPoint(x: 512 + 200, y: edge))
        print("Linear Barrages Fired")
        barragesLeft -= 1
    }
    
    func createDiagonalBarrage(withLateralSpeed xMovement: CGFloat, fromX xEdge: Int, y yEdge: Int) {
        createFireWork(withLateralSpeed: xMovement, at: CGPoint(x: xEdge, y: yEdge + 400))
        createFireWork(withLateralSpeed: xMovement, at: CGPoint(x: xEdge, y: yEdge + 300))
        createFireWork(withLateralSpeed: xMovement, at: CGPoint(x: xEdge, y: yEdge + 200))
        createFireWork(withLateralSpeed: xMovement, at: CGPoint(x: xEdge, y: yEdge + 100))
        createFireWork(withLateralSpeed: xMovement, at: CGPoint(x: xEdge, y: yEdge))
        print("Diagonal Barrages Fired from \(xEdge)")
        barragesLeft -= 1
    }
    
    func createFanBarrage(from edge: Int) {
        createFireWork(withLateralSpeed: 0, at: CGPoint(x: 512, y: edge))
        createFireWork(withLateralSpeed: -200, at: CGPoint(x: 512 - 200, y: edge))
        createFireWork(withLateralSpeed: -100, at: CGPoint(x: 512 - 100, y: edge))
        createFireWork(withLateralSpeed: 100, at: CGPoint(x: 512 + 100, y: edge))
        createFireWork(withLateralSpeed: 200, at: CGPoint(x: 512 + 200, y: edge))
        print("Fan Barrages Fired")
        barragesLeft -= 1
    }
    
    func createFireWork(withLateralSpeed xMovement: CGFloat, at position: CGPoint) {
        guard let fuse = SKEmitterNode(fileNamed: "fuse") else { return }
        
        let node = SKNode()
        node.position = position
        
        
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.colorBlendFactor = 1
        firework.name = "firework"
        switch Int.random(in: 0...2) {
            case 0:
                firework.color = .cyan
            case 1:
                firework.color = .green
            default:
                firework.color = .red
        }
        node.addChild(firework)
        
        fuse.position = CGPoint(x: 0, y: -22)
        node.addChild(fuse)
        
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1000))
        
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        
        node.run(move)
        
        
        fireworks.append(node)
        addChild(node)
    }
    
    func gameOver() {
        gameTimer?.invalidate()
        scoreLabel.removeFromParent()
        setupGameOverHUD()
    }
    
    func setupGameOverHUD() {
        addGameOverLabel(at: CGPoint(x: 512, y: 384), withText: "GAME OVER", ofSize: 50)
        addGameOverLabel(at: CGPoint(x: 512, y: 250), withText: "Final Score: \(score)", ofSize: 36)
    }
    
    func addGameOverLabel(at location: CGPoint, withText text: String, ofSize fontSize: CGFloat) {
        let gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabel.fontSize = fontSize
        gameOverLabel.text = text
        gameOverLabel.horizontalAlignmentMode = .center
        gameOverLabel.zPosition = 2
        gameOverLabel.position = location
        addChild(gameOverLabel)
    }
    
    override func update(_ currentTime: TimeInterval) {
        for (index, firework) in fireworks.enumerated().reversed() {
            if firework.position.y > 900 {
                fireworks.remove(at: index)
                firework.removeFromParent()
            }
        }
        
        if fireworks.isEmpty && !areBarragesLeft {
            gameOver()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        checkTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        checkTouches(touches)
    }
    
    func checkTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let nodesAtLocation = nodes(at: location)
        
        for case let node as SKSpriteNode in nodesAtLocation {
            guard node.name == "firework" else { continue }
            
            for parent in fireworks {
                guard let firework = parent.children.first as? SKSpriteNode else { continue }
                if firework.name == "selected" && firework.color != node.color {
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                }
            }
            
            node.name = "selected"
            node.colorBlendFactor = 0
        }
    }
    
    func explode(_ firework: SKNode) {
        guard let explosion = SKEmitterNode(fileNamed: "explode") else { return }
        explosion.position = firework.position
        addChild(explosion)
        firework.removeFromParent()
        
        let wait = SKAction.wait(forDuration: 1)
        let removeFromParent = SKAction.removeFromParent()
        let sequence = SKAction.sequence([wait, removeFromParent])
        explosion.run(sequence)
    }
    
    func explodeSelectedFireworks() {
        var numExploded = 0
        for (index, fireworkContainer) in fireworks.enumerated().reversed() {
            guard let firework = fireworkContainer.children.first as? SKSpriteNode else { continue }
            if firework.name == "selected" {
                numExploded += 1
                explode(fireworkContainer)
                fireworks.remove(at: index)
            }
        }
        
        switch numExploded {
        case 0:
            break
        case 1:
            score += 100
        case 2:
            score += 250
        case 3:
            score += 500
        case 4:
            score += 1000
        default:
            score += 2000
        }
    }
}
