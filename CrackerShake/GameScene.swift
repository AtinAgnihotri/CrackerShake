//
//  GameScene.swift
//  CrackerShake
//
//  Created by Atin Agnihotri on 09/08/21.
//

import SpriteKit

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
    
    
    override func didMove(to view: SKView) {
        setupBackground()
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
    
    @objc func launchFireWorks() {

        switch Int.random(in: 0...3) {
        case 0:
            // five rockets straight up
            createLinearBarrage(from: bottomEdge)
        case 1:
            // five fireworks in a fan
            createFanBarrage(from: bottomEdge)
        case 2:
            // five rockets from bottom left in diagonal
            createDiagonalBarrage(fromX: leftEdge, y: bottomEdge)
        case 3:
            // five rockets from bottom right in diagonal
            createDiagonalBarrage(fromX: rightEdge, y: bottomEdge)
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
    }
    
    func createDiagonalBarrage(fromX xEdge: Int, y yEdge: Int) {
        let xMovement: CGFloat = 1800
        createFireWork(withLateralSpeed: xMovement, at: CGPoint(x: xEdge, y: yEdge + 400))
        createFireWork(withLateralSpeed: xMovement, at: CGPoint(x: xEdge, y: yEdge + 300))
        createFireWork(withLateralSpeed: xMovement, at: CGPoint(x: xEdge, y: yEdge + 200))
        createFireWork(withLateralSpeed: xMovement, at: CGPoint(x: xEdge, y: yEdge + 100))
        createFireWork(withLateralSpeed: xMovement, at: CGPoint(x: xEdge, y: yEdge))
    }
    
    func createFanBarrage(from edge: Int) {
        createFireWork(withLateralSpeed: 0, at: CGPoint(x: 512, y: edge))
        createFireWork(withLateralSpeed: -200, at: CGPoint(x: 512 - 200, y: edge))
        createFireWork(withLateralSpeed: -100, at: CGPoint(x: 512 - 100, y: edge))
        createFireWork(withLateralSpeed: 100, at: CGPoint(x: 512 + 100, y: edge))
        createFireWork(withLateralSpeed: 200, at: CGPoint(x: 512 + 200, y: edge))
    }
    
    func createFireWork(withLateralSpeed xMovement: CGFloat, at position: CGPoint) {
        guard let fuse = SKEmitterNode(fileNamed: "fuse") else { return }
        
        let node = SKNode()
        node.position = position
        
        fuse.position = CGPoint(x: 0, y: -22)
        node.addChild(fuse)
        
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
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.y > 800 {
                node.removeFromParent()
            }
        }
    }
}
