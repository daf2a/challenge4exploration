import SwiftUI
import SpriteKit

// Main SwiftUI View for the Game
struct SpriteKitView: View {
    var scene: GameScene {
        let scene = GameScene()
        scene.scaleMode = .fill
        return scene
    }

    var body: some View {
        SpriteView(scene: scene)
            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
            .padding()
    }
}

// The Game Scene
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Nodes
    var bird: SKShapeNode!
    var scoreLabel: SKLabelNode!
    
    // Game state
    var score = 0
    var isGameOver = false
    
    // Physics Categories
    let birdCategory: UInt32 = 0x1 << 0
    let pipeCategory: UInt32 = 0x1 << 1
    let groundCategory: UInt32 = 0x1 << 2
    let scoreCategory: UInt32 = 0x1 << 3

    override func didMove(to view: SKView) {
        // Scene setup
        self.size = view.bounds.size
        scene?.backgroundColor = SKColor(red: 0.31, green: 0.75, blue: 0.80, alpha: 1.0) // Light blue
        physicsWorld.gravity = CGVector(dx: 0, dy: -5)
        physicsWorld.contactDelegate = self
        
        addGround()
        addBird()
        addScoreLabel()
        
        // Start spawning pipes
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(spawnPipes),
                SKAction.wait(forDuration: 2.0)
            ])
        ))
    }
    
    func addGround() {
        let groundHeight: CGFloat = 100
        let ground = SKShapeNode(rectOf: CGSize(width: self.size.width, height: groundHeight))
        ground.fillColor = .brown
        ground.strokeColor = .black
        ground.position = CGPoint(x: self.size.width / 2, y: groundHeight / 2)
        
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.frame.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = groundCategory
        addChild(ground)
    }
    
    func addBird() {
        bird = SKShapeNode(circleOfRadius: 20)
        bird.fillColor = .yellow
        bird.strokeColor = .black
        bird.lineWidth = 2
        bird.position = CGPoint(x: self.size.width / 4, y: self.size.height / 2)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        bird.physicsBody?.isDynamic = true
        bird.physicsBody?.allowsRotation = false
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.contactTestBitMask = pipeCategory | groundCategory
        bird.physicsBody?.collisionBitMask = groundCategory
        
        addChild(bird)
    }
    
    func addScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        scoreLabel.fontSize = 60
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height - 100)
        scoreLabel.text = "0"
        scoreLabel.zPosition = 5
        addChild(scoreLabel)
    }

    func spawnPipes() {
        if isGameOver { return }
        
        let pipeWidth: CGFloat = 80
        let pipeGap: CGFloat = 200.0
        
        let pipePair = SKNode()
        pipePair.position = CGPoint(x: self.size.width + pipeWidth, y: 0)
        pipePair.zPosition = -1

        let height = self.size.height
        let randomY = CGFloat.random(in: (pipeGap / 2 + 100)...(height - pipeGap / 2 - 100))

        // Top pipe
        let topPipe = SKShapeNode(rectOf: CGSize(width: pipeWidth, height: height))
        topPipe.fillColor = .green
        topPipe.strokeColor = .black
        topPipe.lineWidth = 3
        topPipe.position = CGPoint(x: 0, y: randomY + (height / 2) + (pipeGap / 2))
        
        topPipe.physicsBody = SKPhysicsBody(rectangleOf: topPipe.frame.size)
        topPipe.physicsBody?.isDynamic = false
        topPipe.physicsBody?.categoryBitMask = pipeCategory
        pipePair.addChild(topPipe)

        // Bottom pipe
        let bottomPipe = SKShapeNode(rectOf: CGSize(width: pipeWidth, height: height))
        bottomPipe.fillColor = .green
        bottomPipe.strokeColor = .black
        bottomPipe.lineWidth = 3
        bottomPipe.position = CGPoint(x: 0, y: randomY - (height / 2) - (pipeGap / 2))
        
        bottomPipe.physicsBody = SKPhysicsBody(rectangleOf: bottomPipe.frame.size)
        bottomPipe.physicsBody?.isDynamic = false
        bottomPipe.physicsBody?.categoryBitMask = pipeCategory
        pipePair.addChild(bottomPipe)
        
        // Score node for detecting pass
        let scoreNode = SKNode()
        scoreNode.position = CGPoint(x: pipeWidth / 2, y: self.frame.midY)
        let scoreNodeSize = CGSize(width: 1, height: self.frame.height)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNodeSize)
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = scoreCategory
        scoreNode.physicsBody?.contactTestBitMask = birdCategory
        pipePair.addChild(scoreNode)

        let moveAction = SKAction.moveBy(x: -self.size.width - pipeWidth * 2, y: 0, duration: 5.0)
        let removeAction = SKAction.removeFromParent()
        pipePair.run(SKAction.sequence([moveAction, removeAction]))

        addChild(pipePair)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver {
            restartGame()
        } else {
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if isGameOver { return }

        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody

        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        if (firstBody.categoryBitMask == birdCategory && secondBody.categoryBitMask == pipeCategory) ||
           (firstBody.categoryBitMask == birdCategory && secondBody.categoryBitMask == groundCategory) {
            gameOver()
        } else if (firstBody.categoryBitMask == birdCategory && secondBody.categoryBitMask == scoreCategory) {
            if secondBody.node?.parent != nil {
                score += 1
                scoreLabel.text = "\(score)"
                secondBody.node?.removeFromParent()
            }
        }
    }
    
    func gameOver() {
        isGameOver = true
        self.speed = 0 // Stop all actions
        
        let gameOverLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        gameOverLabel.fontSize = 50
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 + 50)
        gameOverLabel.text = "Game Over"
        gameOverLabel.zPosition = 10
        addChild(gameOverLabel)
        
        let restartLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        restartLabel.fontSize = 30
        restartLabel.fontColor = .white
        restartLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        restartLabel.text = "Tap to Restart"
        restartLabel.zPosition = 10
        addChild(restartLabel)
    }

    func restartGame() {
        if let view = self.view {
            // Create a new scene instance to restart the game
            let newScene = GameScene(size: view.bounds.size)
            newScene.scaleMode = self.scaleMode
            view.presentScene(newScene, transition: .fade(withDuration: 0.5))
        }
    }
}

// SwiftUI Preview Provider
struct SpriteKitView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SpriteKitView()
                .navigationTitle("Flappy Bird")
                .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.light)
    }
}
