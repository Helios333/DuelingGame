//
//  GameScene.swift
//  DuelistGame
//
//  Created by Cole Myers on 2/27/17.
//  Copyright © 2017 Cole Myers. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    var invincible: Bool = false
    var player = SKSpriteNode(imageNamed: "PlayerSpriteBase")
    let playableRect: CGRect
    let playerAnimation: SKAction
    let cameraMovePointsPerSec: CGFloat = 200.0
    let cameraNode = SKCameraNode()
    var lives = 5
    var gameOver = false
    var velocity = CGPoint.zero

    
    override init (size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height-playableHeight)/2.0
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        var textures:[SKTexture] = []
        
        for i in 1...3 {
            textures.append(SKTexture(imageNamed: "PlayerSpriteBase\(i)"))
        }
        
        textures.append(textures[2])
        textures.append(textures[1])
        
        playerAnimation = SKAction.animate(with: textures, timePerFrame: 0.3)
        
        super.init(size: size)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
}
    
    override func update(_ currentTime: TimeInterval) {
        
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        }
        else {
            dt = 0
        }
        velocity.x = cameraMovePointsPerSec
        move(sprite: player, velocity: velocity)

        player.texture?.filteringMode = SKTextureFilteringMode.nearest
        player.setScale(10)
        
        lastUpdateTime = currentTime
        moveCamera()
        if lives <= 0 && !gameOver {
            gameOver = true
            print("You Lose")
            //backgroundMusicPlayer.stop()
            let gameOverScene = GameOverScene(size: size, won: false)
            gameOverScene.scaleMode = scaleMode
            //2
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            //3
            view?.presentScene(gameOverScene, transition: reveal)
        }
        
    }


    
    
    func move(sprite: SKSpriteNode, velocity: CGPoint) {
        player.position = CGPoint(x: 500, y: 500)
        let playerVelocity = CGPoint(x: cameraMovePointsPerSec, y: 0)
        let amountToMove = playerVelocity * CGFloat(dt)
        player.position += amountToMove
        player.zPosition = 100
        player.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
    }
    
    func playerHit(enemy: SKSpriteNode) {
        invincible = true
        let blinkTimes = 10.0
        let duration = 3.0
        let BlinkAction = SKAction.customAction(withDuration: duration) { node, elapsedTime in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime).truncatingRemainder(dividingBy: slice)
            node.isHidden = remainder > slice / 2
        }
        let setHidden = SKAction.run() { [weak self] in
            self?.player.isHidden = false
            self?.invincible = false
        }
        player.run(SKAction.sequence([BlinkAction, setHidden]))
        
        //run(enemyCollisionSound)
        lives -= 1
    }
    
    override func didMove(to view: SKView) {
        //1:00:04
        
        backgroundColor = SKColor.black
        for i in 0...2{
            let background = backgroundNode()
            background.anchorPoint = CGPoint(x: -1, y: -1)
            //background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: CGFloat(i)*background.size.width, y: 0)
            background.zPosition = -1
            background.name = "background"
            addChild(background)
        }
        addChild(player)
        
        
        
        
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)
    }
    
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = "enemy"
        enemy.position = CGPoint(x: cameraRect.minX + size.width + enemy.size.width/2, y: CGFloat.random(min: cameraRect.minY + enemy.size.height/2, max: cameraRect.maxY - enemy.size.height/2))
        enemy.zPosition = 50
        addChild(enemy)
       /* let actionMove = SKAction.moveBy(x: -2000, y: 0, duration: 1.0)
        let actionRemove = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([actionMove, actionRemove]))
        */
    }

    func moveCamera() {
        let backgroundVelocity = CGPoint(x: cameraMovePointsPerSec, y: 0)
        let amountToMove = backgroundVelocity * CGFloat(dt)
        cameraNode.position += amountToMove
        self.player.zPosition = 100
        self.player.anchorPoint = CGPoint(x: 5.0, y: 5.0) //changed this
        self.player.position = CGPoint(x: 400, y: 400)

        
        enumerateChildNodes(withName: "background") { node, _ in
            let background = node as! SKSpriteNode
            if background.position.x + background.size.width < self.cameraRect.origin.x {
                background.position = CGPoint(x: background.position.x, y: background.position.y)
                            }
        }
    }

    var cameraRect : CGRect {
        let x = cameraNode.position.x - size.width/2 + (size.width - playableRect.width)
        let y = cameraNode.position.y - size.height/2 + (size.height - playableRect.height)
        return CGRect(
            x: x,
            y: y,
            width: playableRect.width,
            height: playableRect.height)
    }
    
    func backgroundNode() -> SKSpriteNode {
        //1
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPoint.zero
        backgroundNode.name = "background"
        
        //2
        let background1 = SKSpriteNode(imageNamed: "background1")
        background1.anchorPoint = CGPoint.zero
        background1.setScale(2.5)
        background1.position = CGPoint(x: 0, y: 100)
        backgroundNode.addChild(background1)
        
        //3
        let background2 = SKSpriteNode(imageNamed: "background2")
        background2.anchorPoint = CGPoint.zero
        background2.setScale(2.5)
        background2.position = CGPoint(x: background1.size.width, y: 100)
        backgroundNode.addChild(background2)
        
        //4
        backgroundNode.size = CGSize(
            width: background1.size.width + background2.size.width,
            height: background1.size.height)
        return backgroundNode
    }


    
}
