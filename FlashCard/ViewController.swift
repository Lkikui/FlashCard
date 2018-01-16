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

var isAccelerometerAvailable: Bool = false

class ViewController: UIViewController {
    var motionManager = CMMotionManager()
    let opQueue = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
       func degrees(_ radians: Double) -> Double {
            return 180/Double.pi * radians
       }
        
        // get magnitude of vector via Pythagorean theorem
        func magnitudeFromAttitude(from attitude: CMAttitude) -> Double {
            return sqrt(pow(attitude.roll, 2) + pow(attitude.yaw, 2) + pow(attitude.pitch, 2))
        }

        func startReadingMotionData() {
            // set read speed
            motionManager.deviceMotionUpdateInterval = 1
            // start reading
            motionManager.startDeviceMotionUpdates(to: opQueue) {
                (data: CMDeviceMotion?, error: Error?) in
                
                if let mydata = data {
                    print("mydata", mydata.attitude)
                    print("")
                    print("pitch", degrees(mydata.attitude.pitch))
                    
                    /// TEST ///
                    var showingPrompt = false
                    
                    // trigger values - a gap so there isn't a flicker zone
                    let showPromptTrigger = 1.0
                    let showAnswerTrigger = 0.8
                    // translate the attitude
                    mydata.attitude.multiply(byInverseOf: mydata.attitude)
                    
                    // calculate magnitude of the change from our initial attitude
                    let magnitude = magnitudeFromAttitude(from: mydata.attitude)
                    
                    // show the prompt
                    if !showingPrompt && magnitude > showPromptTrigger,
                        let promptViewController = self.storyboard?.instantiateViewController(withIdentifier: "MainStoryBoard")
                    {
                        showingPrompt = true
                        
                        promptViewController.modalTransitionStyle = .crossDissolve
                        self.present(promptViewController, animated: true)
                    }
                    
                    // hide the prompt
                    if showingPrompt && magnitude < showAnswerTrigger {
                        showingPrompt = false
                        self.dismiss(animated: true)
                    }
        
                }
            }
            
            if motionManager.isDeviceMotionAvailable {
                print("We can detect device motion")
                startReadingMotionData()
            }
            else {
                print("We cannot detect device motion")
            }
        }
    }
}


