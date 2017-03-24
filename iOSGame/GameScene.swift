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

class GameScene: SKScene {
    
    // put variable here
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
    var levelTimerValue: Int = 30 {
        didSet {
            levelTimerLabel.text = "Time left: \(levelTimerValue)"
        }
    }

    // call functions here
    override func didMove(to view: SKView) {
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        background.zPosition = 1
        addChild(background)
        addButtons()
        initTimer()
    }
    
    // timer - lydia
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

    // spawning clouds - rebecca
    
    // moving clouds - arnold
    
    // background music - ryan
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
    
    // change to showing score - ryan
    func initScore() {
    }

    // change to spawning enemies - shane
    func addChicken() {

    }
    
    // change to enemy getting hit (delete) - wayne
    func moveDown() {
    }
    
    
    func addButtons() {
        //left
        Circle1.position = CGPoint(x: size.width * 0.15, y: size.height * 0.13)
        Circle1.zPosition = 2
        addChild(Circle1)
        
        //mid
        Circle2.position = CGPoint(x: size.width * 0.5, y: size.height * 0.13)
        Circle2.zPosition = 2
        addChild(Circle2)
        
        //right
        Circle3.position = CGPoint(x: size.width * 0.85, y: size.height * 0.13)
        Circle3.zPosition = 2
        addChild(Circle3)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            
            // detect touch in the scene
            let location = touch.location(in: self)
            let leftPosition = CGPoint(x: size.width * 0.33, y: size.width * 0.2)
            let midPosition = CGPoint(x: size.width * 0.66, y: size.width * 0.2)
            var touchPosition = ""
            
            if(location.x <= leftPosition.x) {
                touchPosition = "left"
            } else if (location.x <= midPosition.x) {
                touchPosition = "mid"
            } else {
                touchPosition = "right"
            }
            
            // check if circle node has been touched
            if (self.Circle1.contains(location) && touchPosition == arrayPositions[0]
                || (self.Circle2.contains(location) && touchPosition == arrayPositions[0])
                || (self.Circle3.contains(location) && touchPosition == arrayPositions[0]))  {
                moveDown()
            } else {
                let jumpUpAction = SKAction.moveBy(x: 0, y:20, duration:0.2)
                let jumpDownAction = SKAction.moveBy(x: 0, y:-20, duration:0.2)
                let jumpSequence = SKAction.sequence([jumpUpAction, jumpDownAction])
                
                arrayChickens[0].run(jumpSequence)
                
                let enable1 = SKAction.run({[unowned self] in self.Circle1.isUserInteractionEnabled = false})
                Circle1.isUserInteractionEnabled = true
                Circle1.run(SKAction.sequence([SKAction.wait(forDuration:0.4),enable1]))
                let enable2 = SKAction.run({[unowned self] in self.Circle2.isUserInteractionEnabled = false})
                Circle2.isUserInteractionEnabled = true
                Circle2.run(SKAction.sequence([SKAction.wait(forDuration:0.4),enable2]))
                let enable3 = SKAction.run({[unowned self] in self.Circle3.isUserInteractionEnabled = false})
                Circle3.isUserInteractionEnabled = true
                Circle3.run(SKAction.sequence([SKAction.wait(forDuration:0.4),enable3]))
                
            }
        }
        
    }
    
    func reset() {
        score = 0
        levelTimerValue = 30
    }

}
