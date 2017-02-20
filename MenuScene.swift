//
//  MenuScene.swift
//  spaceShuttleGame
//
//  Created by Monisha Elumalai on 1/28/17.
//  Copyright © 2017 Monisha Elumalai. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    
    var starfield:SKEmitterNode!
    var newGameButtonNode:SKSpriteNode!
    
    var diffLevelButtonNode:SKSpriteNode!
    
    var difficultyLabelNode:SKLabelNode!
    
    override func didMove(to view: SKView) {
        
        starfield = self.childNode(withName: "starfield") as! SKEmitterNode
        starfield.advanceSimulationTime(10)
        
        newGameButtonNode = self.childNode(withName: "newGameButton") as! SKSpriteNode
        
        diffLevelButtonNode = self.childNode(withName: "diffLevelButton") as! SKSpriteNode
        
        difficultyLabelNode = self.childNode(withName: "difficultyLabel") as! SKLabelNode
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.bool(forKey: "hard") {
            difficultyLabelNode.text = "Hard"
        }else{
            difficultyLabelNode.text = "Easy"
        }
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        let touch = touches.first
        if let location = touch?.location(in: self) {
            let node = self.nodes(at: location)
            
            if node[0].name == "newGameButton" {
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let gameScene = GameScene(size: self.size)
                self.view!.presentScene(gameScene, transition: transition)
            }else if node[0].name == "diffLevelButton" {
                changeDifficulty()
            }
        }
        
    }
    
    func changeDifficulty(){
        
        let userDefaults = UserDefaults.standard
        
        if difficultyLabelNode.text == "Easy" {
            difficultyLabelNode.text = "Hard"
            userDefaults.set(true, forKey: "hard")
        }else{
            difficultyLabelNode.text = "Easy"
            userDefaults.set(false, forKey: "hard")
        }
        
        userDefaults.synchronize()
    }

    

}
