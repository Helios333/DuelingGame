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
    let zombieMovePointsPerSec: CGFloat = 200.0 //tgj - 480.0
    var dt: TimeInterval = 0
    var invincible: Bool = false
    var player = SKSpriteNode(imageNamed: "PlayerAnim1N")
    var player1 = SKSpriteNode(imageNamed: "PlayerAnim2N")
    var player2 = SKSpriteNode(imageNamed: "PlayerAnim3N")
    var player3 = SKSpriteNode(imageNamed: "PlayerAnim4N")
    var sword = SKSpriteNode(imageNamed: "SwordAnim1")
    var sword1 = SKSpriteNode(imageNamed: "SwordAnim2")
    var sword2 = SKSpriteNode(imageNamed: "SwordAnim3")
    var swordPosition = 1
    
    var swordDir = 1
    
    var clickCounter = 0
    let playableRect: CGRect
    let playerAnimation: SKAction
    //let swordAnimation: SKAction
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

        for i in 2...4 {
            textures.append(SKTexture(imageNamed: "PlayerAnim\(i)N"))
            
        }

        //textures.append(textures[2])
        textures.append(textures[1])
        
        playerAnimation = SKAction.animate(with: textures, timePerFrame: 0.3)
        
        //var STextures:[SKTexture] = []
        
        /*for i in 1...3 {
            STextures.append(SKTexture(imageNamed: "SwordAnim\(i)"))
            
        }
        
        //textures.append(textures[2])
        STextures.append(STextures[1])
        
        swordAnimation = SKAction.animate(with: STextures, timePerFrame: 0.5)*/
        
        super.init(size: size)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startPlayerAnimation(){
        if player.action(forKey: "animation") == nil {
            player.run(SKAction.repeatForever(playerAnimation), withKey: "animation")
        }
    }
    
   /* func startSwordAnimation(){
        if sword.action(forKey: "animation") == nil {
            sword.run(SKAction.repeatForever(swordAnimation), withKey: "animation")

        }
    }*/
    
    override func update(_ currentTime: TimeInterval) {
        startPlayerAnimation()
        //startSwordAnimation()
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        }
        else {
            dt = 0
        }
        // tgj
        lastUpdateTime = currentTime
        velocity.x = zombieMovePointsPerSec
        move(sprite: player, velocity: velocity)
        move(sprite: sword, velocity: velocity)
        move(sprite: sword1, velocity: velocity)
        move(sprite: sword2, velocity: velocity)


        moveCamera()
        
        if lives <= 0 && !gameOver {
            
            gameOver = true
            print("You Lose")
            let gameOverScene = GameOverScene(size: size, won: false)
            gameOverScene.scaleMode = scaleMode
            //2
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            //3
            view?.presentScene(gameOverScene, transition: reveal)
        }
        
    }
    
    /*override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
    }*/

    
    override func didEvaluateActions() {
        checkCollisions()
    }
    
    func move(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = CGPoint(x: velocity.x * CGFloat(dt),
                                   y: velocity.y * CGFloat(dt))
        sprite.position += amountToMove
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
            self?.sword.isHidden = false
            self?.sword1.isHidden = false
            self?.sword2.isHidden = false
            self?.invincible = false
        }
        player.run(SKAction.sequence([BlinkAction, setHidden]))
        sword.run(SKAction.sequence([BlinkAction, setHidden]))
        sword1.run(SKAction.sequence([BlinkAction, setHidden]))
        sword2.run(SKAction.sequence([BlinkAction, setHidden]))
        print ("Player hit enemy")
        lives -= 1
    }
    
    func checkCollisions() {
        if (invincible == false){
            var hitEnemies: [SKSpriteNode] = []
            enumerateChildNodes(withName: "enemy") { node, _ in
                let enemy = node as! SKSpriteNode
                if node.frame.insetBy(dx: 20, dy: 20).intersects(self.player.frame) {
                    hitEnemies.append(enemy)
                }
                
            }
            for enemy in hitEnemies {
                playerHit(enemy: enemy)
            }
        }

    }
    
    func checkSwordCollisions() {
        if (invincible == false){
            var hitEnemies: [SKSpriteNode] = []
            enumerateChildNodes(withName: "enemy") { node, _ in
                let enemy = node as! SKSpriteNode
                if node.frame.insetBy(dx: 20, dy: 20).intersects(self.sword.frame) {
                    print ("Enemy hit Sword")
                    enemy.removeFromParent()
                }
                else if node.frame.insetBy(dx: 20, dy: 20).intersects(self.sword1.frame) {
                    print ("Enemy hit Sword")
                    enemy.removeFromParent()
                }
                else if node.frame.insetBy(dx: 20, dy: 20).intersects(self.sword2.frame) {
                    print ("Enemy hit Sword")
                    enemy.removeFromParent()
                }

                
            }
            for enemy in hitEnemies {
                playerHit(enemy: enemy)
            }
        }
        
    }

    func sceneTapped() {
        print ("Sword Movement =\(swordPosition)")

        
        /*if swordPosition == 1 {
            swordPosition = 2
        } else if swordPosition == 2 {
            swordPosition = 3
        } else {
            swordPosition = 2
        }*/
        
        
        
        
            if swordPosition == 1 {
                sword.alpha = 1
                sword1.alpha = 0
                sword2.alpha = 0
                
            }
            else if swordPosition == 2 {
                sword.alpha = 0
                sword1.alpha = 1
                sword2.alpha = 0
            }
            else if swordPosition == 3 {
                sword.alpha = 0
                sword1.alpha = 0
                sword2.alpha = 1
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?) {
        sceneTapped()
        swordPosition += swordDir
        
        if ((swordPosition == 3 && swordDir > 0) ||
            (swordPosition == 1 && swordDir < 0)) {
            swordDir *= -1 // Reverse Dir
        }
        
        //swordUD();
    }
    
    override func didMove(to view: SKView) {
        
        backgroundColor = SKColor.black
        for i in 0...2{
            let background = backgroundNode()
            //tgj - background.anchorPoint = CGPoint(x: -1, y: -1)
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: CGFloat(i)*background.size.width, y: 0)
            background.zPosition = -1
            background.name = "background"
            addChild(background)
        }
        
        sword.texture?.filteringMode = SKTextureFilteringMode.nearest
        sword1.texture?.filteringMode = SKTextureFilteringMode.nearest
        sword2.texture?.filteringMode = SKTextureFilteringMode.nearest
        sword.setScale(10)
        sword1.setScale(10)
        sword2.setScale(10)
        sword.position = CGPoint(x: 515, y: 510)
        sword.zPosition = 110
        sword.anchorPoint = CGPoint(x: 0, y: 0)
        sword1.position = CGPoint(x: 515, y: 510)
        sword1.zPosition = 110
        sword1.anchorPoint = CGPoint(x: 0, y: 0)
        sword2.position = CGPoint(x: 525, y: 530)
        sword2.zPosition = 110
        sword2.anchorPoint = CGPoint(x: 0, y: 1)

        player.texture?.filteringMode = SKTextureFilteringMode.nearest
        player1.texture?.filteringMode = SKTextureFilteringMode.nearest
        player2.texture?.filteringMode = SKTextureFilteringMode.nearest
        player3.texture?.filteringMode = SKTextureFilteringMode.nearest
        player.setScale(10)
        player.position = CGPoint(x: 500, y: 500)
        player.zPosition = 100
        player.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run() { [weak self] in self?.spawnEnemy()
                },
                               SKAction.wait(forDuration: 4.0)])))
        self.addChild(sword)
        self.addChild(sword1)
        self.addChild(sword2)
        self.addChild(player)
        sword.alpha = 0
        sword1.alpha = 1
        sword2.alpha = 0

        
        
        
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)
    }
    
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "GoblinBase1")
        enemy.name = "enemy"
        enemy.texture?.filteringMode = SKTextureFilteringMode.nearest
        enemy.setScale(5)
        enemy.position = CGPoint(x: cameraRect.minX + size.width + enemy.size.width/2, y: 420)
        enemy.anchorPoint = CGPoint(x: 0.25, y: 0.25)
        enemy.zPosition = 50
        addChild(enemy)
        let actionMove = SKAction.moveBy(x: -2000, y: 0, duration: 4.0)
        let actionRemove = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([actionMove, actionRemove]))
        
    }
    
    func moveCamera() {
        let backgroundVelocity = CGPoint(x: cameraMovePointsPerSec, y: 0)
        let amountToMove = backgroundVelocity * CGFloat(dt)
        cameraNode.position += amountToMove
        //tgj
        //self.player.zPosition = 100
        //self.player.anchorPoint = CGPoint(x: 0.0, y: 0.0) //changed this
        //self.player.position = CGPoint(x: 400, y: 400)
        //tgj
        
        
        enumerateChildNodes(withName: "background") { node, _ in
            let background = node as! SKSpriteNode
            if background.position.x + background.size.width < self.cameraRect.origin.x {
                
                background.position = CGPoint(
                    x: background.position.x + background.size.width*2,
                    y: background.position.y)
                
            }
        }
    }
    
    var cameraRect : CGRect {
        let x = cameraNode.position.x - size.width/2 + (size.width - playableRect.width)/2 //tgj
        let y = cameraNode.position.y - size.height/2 + (size.height - playableRect.height)/2 //tgj
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
        background1.position = CGPoint(x: 0, y: 0)
        backgroundNode.addChild(background1)
        
        //3
        let background2 = SKSpriteNode(imageNamed: "background2")
        background2.anchorPoint = CGPoint.zero
        background2.setScale(2.5)
        background2.position = CGPoint(x: background1.size.width, y: 0)
        backgroundNode.addChild(background2)
        
        //4
        backgroundNode.size = CGSize(
            width: background1.size.width + background2.size.width,
            height: background1.size.height)
        return backgroundNode
    }
    
    
    
}
