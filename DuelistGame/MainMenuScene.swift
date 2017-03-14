//
//  MainMenu.swift
//  DuelistGame
//
//  Created by Cole Myers on 3/3/17.
//  Copyright © 2017 Cole Myers. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenuScene: SKScene {
    override func didMove(to view: SKView) {
        let mainMenuScene = SKSpriteNode(imageNamed: "MainMenu")
        mainMenuScene.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(mainMenuScene)
    }
    func sceneTapped() {
        let myScene = GameScene(size: size)
        myScene.scaleMode = scaleMode
        let reveal = SKTransition.doorway(withDuration: 1.5)
        self.view?.presentScene(myScene, transition: reveal)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?) {
        sceneTapped()
    }
}
