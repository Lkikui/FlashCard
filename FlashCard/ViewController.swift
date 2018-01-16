//
//  ViewController.swift
//  FlashCard
//
//  Created by Lisa Ryland on 1/15/18.
//  Copyright © 2018 Lisa Ryland. All rights reserved.
//

import UIKit
import CoreMotion

// variables
let wordDict = ["えんぴつ": "pencil", "りんご": "apple", "つくえ": "desk", "かみ": "paper", "くつ": "shoe"]

var motionManager: CMMotionManager?
var isAccelerometerAvailable: Bool = false

class ViewController: UIViewController {
    var motionManager = CMMotionManager()
    let opQueue = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if motionManager.isDeviceMotionAvailable {
            print("We can detect device motion")
            startReadingMotionData()
        }
        else {
            print("We cannot detect device motion")
        }
        
        // get magnitude of vector via Pythagorean theorem
        func magnitudeFromAttitude(from attitude: CMAttitude) -> Double {
            return sqrt(pow(attitude.roll, 2) + pow(attitude.yaw, 2) + pow(attitude.pitch, 2))
        }
        
        // initial configuration
        var attitude = CMAttitude()
        var motion = CMDeviceMotion()
        
        if motionManager.deviceMotion != nil{
            motion = motionManager.deviceMotion!
            attitude = motion.attitude
            
            let YawLabel = NSString (format: "Yaw: %.2f", attitude.yaw) as String
            print(YawLabel)
            let PitchLabel = NSString (format: "Pitch: %.2f", attitude.pitch) as String
            print(PitchLabel)
            let RollLabel = NSString (format: "Roll: %.2f", attitude.roll) as String
            print(RollLabel)
        }
        
        
        let initialAttitude = motionManager.deviceMotion!.attitude
        print(initialAttitude)
        var showingPrompt = false
        
        // trigger values - a gap so there isn't a flicker zone
        let showPromptTrigger = 1.0
        let showAnswerTrigger = 0.8
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates(to: .main) {
                [weak self] (data: CMDeviceMotion?, error: Error?) in
                
                guard let data = data else { return }
                
                // translate the attitude
                data.attitude.multiply(byInverseOf: initialAttitude)
                
                // calculate magnitude of the change from our initial attitude
                let magnitude = magnitudeFromAttitude(from: data.attitude)
                
                
                // show the prompt
                if !showingPrompt && magnitude > showPromptTrigger,
                    let promptViewController = self?.storyboard?.instantiateViewController(withIdentifier: "MainStoryBoard")
                {
                    showingPrompt = true
                    
                    promptViewController.modalTransitionStyle = .crossDissolve
                    self?.present(promptViewController, animated: true)
                }
                
                // hide the prompt
                if showingPrompt && magnitude < showAnswerTrigger {
                    showingPrompt = false
                    self?.dismiss(animated: true)
                }
            }
        }
    }
    
    func startReadingMotionData() {
        // set read speed
        motionManager.deviceMotionUpdateInterval = 1
        // start reading
        motionManager.startDeviceMotionUpdates(to: opQueue) {
            (data: CMDeviceMotion?, error: Error?) in
            
            if let mydata = data {
                print("mydata", mydata.attitude)
                print("pitch", self.degrees(mydata.attitude.pitch))
            }
        }
    }
    
    func degrees(_ radians: Double) -> Double {
        return 180/Double.pi * radians
    }
}


