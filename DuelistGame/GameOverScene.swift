//
//  GameOverScene.swift
//  DuelistGame
//
//  Created by Cole Myers on 3/2/17.
//  Copyright © 2017 Cole Myers. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene{
    let won:Bool
    
    init(size: CGSize, won: Bool) {
        self.won = won
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has npt been implemented")
    }
    
    override func didMove(to view: SKView) {
        var background: SKSpriteNode
        if (won) {
            background = SKSpriteNode(imageNamed: "YouWin")
             background.setScale(2.125)
            //run(SKAction.playSoundFileNamed("win.wav", waitForCompletion: false))
        } else {
            background = SKSpriteNode(imageNamed: "YouLose")
            background.setScale(2.125)
            //run(SKAction.playSoundFileNamed("lose.wav", waitForCompletion: false))
        }
        
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        self.addChild(background)
        
        let wait = SKAction.wait(forDuration: 3.0)
        let block = SKAction.run {
            let myScene = GameScene(size: self.size)
            myScene.scaleMode = self.scaleMode
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            self.view?.presentScene(myScene, transition: reveal)
            
        }
        self.run(SKAction.sequence([wait, block]))
    }
    
}
