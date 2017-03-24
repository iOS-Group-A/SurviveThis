//
//  GameScene.swift
//  iOSGame
//
//  Created by Kevin Tieu on 2017-02-09.
//  Copyright © 2017 Kevin Tieu. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation
import AudioToolbox

var score: Int = 0
var myLabel: SKLabelNode!

class GameScene: SKScene, SKPhysicsContactDelegate
{
    
    
    struct PhysicsCategory {
        static let None      : UInt32 = 0
        static let All       : UInt32 = UInt32.max
        static let Monster   : UInt32 = 0b1       // 1
        static let Bullet    : UInt32 = 0b10      // 2
    }

    
    //============= Texture Declarations =============
    // define the purple monster's frames
    var skullFlyingFrames : [SKTexture]!
    var skullDeathFrames : [SKTexture]!
    
    var chicken = SKSpriteNode(imageNamed: "chicken")
    var chickenPosition = ""
    let Circle1 = SKSpriteNode(imageNamed: "barn")
    let Circle2 = SKSpriteNode(imageNamed: "barn")
    let Circle3 = SKSpriteNode(imageNamed: "barn")
    let background = SKSpriteNode(imageNamed: "grass-background.jpg") // background image on the gameplay
    var arrayChickens:[SKSpriteNode] = []
    var arrayPositions:[String] = []
    let numberOfChickens = 5
    var player: AVAudioPlayer?
    var levelTimerLabel = SKLabelNode(fontNamed: "Helvetica")
    var score:Int = 0
    var levelTimerValue: Int = 30 {
        didSet {
            levelTimerLabel.text = "Time left: \(levelTimerValue)"
        }
    }

    override func didMove(to view: SKView) {
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        background.zPosition = 1
        addChild(background)
        initChicken()
        addButtons()
        initScore()
        playSound()
        initTimer()
        
        
        // make purple monster fkying frames
        var flyFrames:[SKTexture] = []
        let skullAtlas = SKTextureAtlas(named: "Skull")
        
        for index in 1...6 {
            let textureName = "skull\(index)"
            flyFrames.append(skullAtlas.textureNamed(textureName))
        }
        
        skullFlyingFrames = flyFrames
        
        // make purple death frames
        var deathFrames:[SKTexture] = []
        let skullDeathAtlas = SKTextureAtlas(named: "SkullDeath")
        
        for index in 1...6 {
            let textureName = "skullDeath\(index)"
            deathFrames.append(skullDeathAtlas.textureNamed(textureName))
        }
        
        skullDeathFrames = deathFrames
        
        
    }
    
    // init timer
    func initTimer() {
        levelTimerLabel.fontColor = SKColor.black
        levelTimerLabel.fontSize = 19
        levelTimerLabel.position = CGPoint(x: size.width * 0.8, y: size.height * 0.945)
        levelTimerLabel.text = "Time left: '\(levelTimerValue)"
        levelTimerLabel.zPosition = 2
        addChild(levelTimerLabel)
        print("test")
        
        let wait = SKAction.wait(forDuration: 1) // change countdown speed here
        let countdown = SKAction.run({
            [unowned self] in
            
            self.levelTimerValue -= 1
            
            if (self.levelTimerValue > -1) {   
                self.levelTimerValue -= 1
            } else {
                self.removeAction(forKey: "countdown")
                self.reset()
                let skView = self.view
                let reveal = SKTransition.fade(with: UIColor.white, duration: 3)
                let gameOverScene = GameOverScene(size: self.size)
                skView?.presentScene(gameOverScene, transition: reveal)
            }
        })
        let sequence = SKAction.sequence([wait, countdown])
        run(SKAction.repeatForever(sequence), withKey: "countdown")
    }

    // background music
    func playSound() {
        let url = Bundle.main.url(forResource: "backgroundmusic", withExtension: "mp3")!
    
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            
            player.prepareToPlay()
            player.play()
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    // shows the score
    func initScore() {
        myLabel = SKLabelNode(fontNamed: "Helvetica")
        myLabel.text = "0"
        myLabel.fontSize = 19
        myLabel.fontColor = SKColor.black
        myLabel.position = CGPoint(x: size.width * 0.065 , y: size.height * 0.945) // score on the top-left corner
        myLabel.zPosition = 2
        addChild(myLabel)
    }
    
    /* Creates 5 instances of a chicken and add them to the chickens array */
    func initChicken() {
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addChicken),
                SKAction.wait(forDuration: 2, withRange: 1.5)
                ])
        ))
        /*for i in 0..<numberOfChickens {
            chicken = SKSpriteNode(imageNamed: "chicken")
            let ratio = chicken.size.width/chicken.size.height
            let chickensize = frame.width/2.75
            chicken.size = CGSize(width: chickensize, height: chickensize/ratio)
            
            let placement = Int(arc4random_uniform(100))

            if(placement <= 33) {
                chicken.position = CGPoint(x: size.width * 0.145, y: (size.height * 0.25 + CGFloat(i) * size.height * 0.15))
                chickenPosition = "left"
            } else if (placement <= 66) {
                chicken.position = CGPoint(x: size.width * 0.5, y: (size.height * 0.25 + CGFloat(i) * size.height * 0.15))
                chickenPosition = "mid"
            } else {
                chicken.position = CGPoint(x: size.width * 0.855, y: (size.height * 0.25 + CGFloat(i) * size.height * 0.15))
                chickenPosition = "right"
            }
            
            arrayChickens.append(chicken)
            arrayPositions.append(chickenPosition)
            chicken.zPosition = 2
            addChild(chicken)

        }*/
    }
    

    func addChicken() {
        // Adds chicken to last index of arrayChicken

        let temp : SKTexture = skullFlyingFrames[0]
        let skull = SKSpriteNode(texture: temp)
        
        skull.size = CGSize(width: 80, height: 80)
        skull.name = "skull"
        
        skull.physicsBody = SKPhysicsBody(rectangleOf: skull.size)
        skull.physicsBody?.isDynamic = false
        skull.physicsBody?.categoryBitMask = PhysicsCategory.Monster
        skull.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet
        skull.physicsBody?.collisionBitMask = PhysicsCategory.None
        skull.physicsBody?.usesPreciseCollisionDetection = true
        
        let ratio = skull.size.width/skull.size.height
        let chickensize = frame.width/2.75
        skull.size = CGSize(width: chickensize, height: chickensize/ratio)
        	
        let placement = Int(arc4random_uniform(100))
        
        // Determine speed of the monster
        //    let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        let actualDuration = CGFloat(10.0)
        
        // Create the actions
        let gameOverLine = frame.minY + Circle1.size.height + Circle1.size.height * 0.25 + skull.size.height/2
        
        if(placement <= 33) {
            skull.position = CGPoint(x: size.width * 0.145, y: (size.height * 0.25 + 5 * size.height * 0.15))
            chickenPosition = "left"
        } else if (placement <= 66) {
            skull.position = CGPoint(x: size.width * 0.5, y: (size.height * 0.25 + 5 * size.height * 0.15))
            chickenPosition = "mid"
        } else {
            skull.position = CGPoint(x: size.width * 0.855, y: (size.height * 0.25 + 5 * size.height * 0.15))
            chickenPosition = "right"
        }
        
        
        let actionMove = SKAction.move(to: CGPoint(x: skull.position.x, y: gameOverLine), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        
        skull.zPosition = 2
        addChild(skull)
        
        skull.run(SKAction.repeatForever(SKAction.animate(with: self.skullFlyingFrames!, timePerFrame: 0.05, resize: false, restore: true)))
        
        let loseAction = SKAction.run() {
            let reveal = SKTransition.flipVertical(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, won: false, score: self.score)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        
        skull.run(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
        
        //can add flapping animation here
    }
    
//    func moveDown() {
//        arrayChickens[0].removeFromParent() // remove the chicken in the first row
//        for i in 0..<numberOfChickens {
//            if (i != 4) {
//                arrayPositions[i] = arrayPositions[i+1]
//                arrayChickens[i] = arrayChickens[i+1]
//            }
//        }
//        addChicken()
//
//        for i in 0..<numberOfChickens {
//            //arrayChickens[i].position = CGPoint(x: arrayChickens[i].position.x, y: arrayChickens[i].position.y - size.height * 0.15)
//            let moveDownAction = SKAction.moveBy(x: 0, y: -size.height * 0.15, duration:0.1)
//            let moveDownSequence = SKAction.sequence([moveDownAction])
//            arrayChickens[i].run(moveDownSequence)
//        }
//        score += 1
//        
//        let defaults = UserDefaults.standard
//        defaults.set(score, forKey: "myKey") // save the score
//        defaults.synchronize()
//        
//        
//        myLabel.text = "\(score)"
//    }
    
    
    func addButtons() {
        //left
        var ratio = Circle1.size.width/Circle1.size.height
        var barnsize = frame.width/4
        Circle1.size = CGSize(width: barnsize, height: barnsize/ratio)
        Circle1.position = CGPoint(x: size.width * 0.15, y: size.height * 0.13)
        Circle1.zPosition = 2
        addChild(Circle1)
        
        //mid
        ratio = Circle2.size.width/Circle2.size.height
        barnsize = frame.width/4
        Circle2.size = CGSize(width: barnsize, height: barnsize/ratio)
        Circle2.position = CGPoint(x: size.width * 0.5, y: size.height * 0.13)
        Circle2.zPosition = 2
        addChild(Circle2)
        
        //right
        ratio = Circle3.size.width/Circle3.size.height
        barnsize = frame.width/4
        Circle3.size = CGSize(width: barnsize, height: barnsize/ratio)
        Circle3.position = CGPoint(x: size.width * 0.85, y: size.height * 0.13)
        Circle3.zPosition = 2
        addChild(Circle3)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            
            // detect touch in the scene
            let location = touch.location(in: self)
//            let leftPosition = CGPoint(x: size.width * 0.33, y: size.width * 0.2)
//            let midPosition = CGPoint(x: size.width * 0.66, y: size.width * 0.2)
//            var touchPosition = ""
//            
//            if(location.x <= leftPosition.x) {
//                touchPosition = "left"
//            } else if (location.x <= midPosition.x) {
//                touchPosition = "mid"
//            } else {
//                touchPosition = "right"
//            }
            
            // check if circle node has been touched
            if (self.Circle1.contains(location))  {
                addBullet(object: Circle1)
            }else if(self.Circle2.contains(location)){
                addBullet(object: Circle2)
            }else if(self.Circle3.contains(location)){
                addBullet(object: Circle3)
            }
        }
        
    }
    
    func addBullet(object : SKSpriteNode) {
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.size = CGSize(width: 35, height: 35)
        bullet.position = object.position
        bullet.zPosition = 2
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width/2)
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.categoryBitMask = PhysicsCategory.Bullet
        bullet.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        bullet.physicsBody?.collisionBitMask = PhysicsCategory.None
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        addChild(bullet)
        let actionMove = SKAction.move(to: CGPoint(x: bullet.position.x, y: size.height + bullet.size.height/2), duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        bullet.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // Laura's change: call projectileDidCollideWithMonster function to process collision detection
        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Bullet != 0)) {
            if let skull = firstBody.node as? SKSpriteNode,
               let bullet = secondBody.node as? SKSpriteNode {
                bulletDidCollideWithMonster(bullet: bullet, skull: skull)
            }
        }
    }
    
//    
//    func didBegin(_ contact: SKPhysicsContact) {
//        //first < second
//        var firstBody: SKPhysicsBody
//        var secondBody: SKPhysicsBody
//        
//        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
//            firstBody = contact.bodyA
//            secondBody = contact.bodyB
//        } else {
//            firstBody = contact.bodyB
//            secondBody = contact.bodyA
//        }
//        
//        //set different collision situations
//        if ((PhysicsCategory.Monster != 0) &&
//            (PhysicsCategory.Bullet != 0) &&
//            (firstBody.categoryBitMask == PhysicsCategory.Monster) &&
//            (secondBody.categoryBitMask == PhysicsCategory.Bullet)){
//            if let enemy = firstBody.node as? ,
//                let bullet = secondBody.node as? SKSpriteNode {
//                    bulletDidCollideWithMonster(bullet: bullet, skull : enemy)
//            }
//        }
//    }
    func bulletDidCollideWithMonster(bullet: SKSpriteNode, skull: SKSpriteNode) {
        print("shootEnemy")
        skull.removeFromParent()
        bullet.removeFromParent()
    }
    func reset() {
        score = 0
        levelTimerValue = 30
    }

}
