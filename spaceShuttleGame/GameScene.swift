//
//  GameScene.swift
//  spaceShuttleGame
//
//  Created by Monisha Elumalai on 1/28/17.
//  Copyright © 2017 Monisha Elumalai. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfield : SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var score:Int = 0{
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var gameTimer:Timer!
    var possibleAliens = ["alien","alien1","alien3"]
    
    let alienCategory:UInt32 = 0x1 << 1
    let photontorpedo:UInt32 = 0x1 << 0
    
    let motionManager = CMMotionManager()
    var xAcceleration:CGFloat = 0
    
    
    override func didMove(to view: SKView) {
        
        starfield = SKEmitterNode(fileNamed: "Starfield")
        starfield.position = CGPoint(x:0,y:1472)//setting tyhe position for the starfield bg..for now hardcoded
        starfield.advanceSimulationTime(10)// the starfield.sks has a delay and we remove it by forwarding the simuation
        self.addChild(starfield)
        
        starfield.zPosition = -1;//to set this as a background and not interupr player
        
        player = SKSpriteNode(imageNamed: "space-shuttle")
        player.position = CGPoint(x:self.frame.size.width/2,y:player.size.height/2+20)
        self.addChild(player)
        
        self.physicsWorld.gravity = CGVector(dx:0,dy:0)
        self.physicsWorld.contactDelegate = self
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        
        scoreLabel.position = CGPoint(x:500,y:self.frame.size.height-60)
        scoreLabel.fontName = "Chalkduster"
        scoreLabel.fontSize = 28
        scoreLabel.fontColor = UIColor.white
        score = 0
        
        self.addChild(scoreLabel)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
        
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data:CMAccelerometerData?, error:Error?) in
           
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.25
            }
            
        }
        
    }
    
    func addAlien(){
        
        possibleAliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleAliens) as! [String]
        
        let alien = SKSpriteNode(imageNamed: possibleAliens[0])
        let randomalienPosition = GKRandomDistribution(lowestValue: 0, highestValue:414)
        let position = CGFloat(randomalienPosition.nextInt())
        
        alien.position = CGPoint(x: position, y: self.frame.height+alien.size.height)
        
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic = true

        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = photontorpedo
        alien.physicsBody?.collisionBitMask = 0
        
        self.addChild(alien)
        
        let animationDuration:TimeInterval = 6
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -alien.size.height), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        alien.run(SKAction.sequence(actionArray))
        
        
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        firingTorpedo()
        
    }
    
    func firingTorpedo(){
        self.run(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
        
        let torpedoNode = SKSpriteNode(imageNamed: "torpedo")
        
        torpedoNode.position = player.position
        
        torpedoNode.position.y += 5
        
        torpedoNode.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode.size.width/2 )
        torpedoNode.physicsBody?.isDynamic = true
        
        torpedoNode.physicsBody?.categoryBitMask = alienCategory
        torpedoNode.physicsBody?.contactTestBitMask = photontorpedo
        torpedoNode.physicsBody?.collisionBitMask = 0
        
        torpedoNode.physicsBody?.usesPreciseCollisionDetection = true
        self.addChild(torpedoNode)
        
        let animationDuration:TimeInterval = 0.3
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: self.frame.size.height + 10), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        torpedoNode.run(SKAction.sequence(actionArray))

        
    }
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody : SKPhysicsBody
        var secondBody : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
            
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        if (firstBody.categoryBitMask & photontorpedo) != 0 && (secondBody.categoryBitMask & alienCategory) != 0 {
            torpedodidCollidewithAlien(torpedoNode: firstBody.node as! SKSpriteNode, alienNode: secondBody.node as! SKSpriteNode)
        }
        
    }
    
    func torpedodidCollidewithAlien(torpedoNode: SKSpriteNode, alienNode: SKSpriteNode){
        
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = alienNode.position
        self.addChild(explosion)
        
        self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        torpedoNode.removeFromParent()
        alienNode.removeFromParent()
        
        self.run(SKAction.wait(forDuration: 2)){
            explosion.removeFromParent()

        }
        score += 5;
        
        
    }
    
    override func didSimulatePhysics() {
        
        player.position.x += xAcceleration * 50
        
        if player.position.x < -20 {
            player.position = CGPoint(x: self.size.width + 20, y: player.position.y)
        }else if player.position.x > self.size.width + 20 {
            player.position = CGPoint(x: -20, y: player.position.y)
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

//Add collission and movement for collectiojn of pointslike in jetpack joyride

//Powerup the and headstart for the shuttle in collision with certain objects a ==> at this timecollsion should minimal
//Sensors

 //Accelerometer manager 

//startGyroUpdates --  smooth gyro transitions nd data
