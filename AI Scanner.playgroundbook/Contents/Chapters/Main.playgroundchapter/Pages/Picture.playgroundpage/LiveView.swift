//#-hidden-code

//
//  AI Scanner
//
//  LiveView.swift
//  Created by Ayush Singh on 18/03/2019.
//  Copyright © 2019 Ayush Singh. All rights reserved.
//

//#-end-hidden-code

//: ### Ai Scanner

/*:
 ###
 !(Dragon-War-logo.png "Sample IMAGE")
 
 Hi! I'm **Ayush Singh**, a student of Macro Vision Academy(Apple Distinguished School), Burhanpur, M.P, India. I've devoted to iOS development since 2017 and this year, I made some digging into the latest `ARKit` and `Machine Learnign`, which is awesome and easy to use! So I created a Ai Scanner project for WWDC 2019 scholarship submission. Hope you like it! 😊
 
 ### Welcome
 
 In order to let you get familiar with the project quickly, please use project in landscape left orientation. After tapping the `Run My Code` button, you have to take photo of object. Once clicked photo, the go to next page, then project gave you details about an object.
 
 #### Notice
 
 * When the project starts, keep your iPad in landscape left orientation.
 * It is recommended to run the game in a **landscape+left** orientation.

 */

import UIKit
import PlaygroundSupport

class PlaygroundView: UIView, PlaygroundLiveViewSafeAreaContainer {}

// In this class user has to select orientation of iPad like: portrait, landscape, etc
class OrientationViewController: UIViewController {

    var landscapeLeft = UIButton()
    let txtlabel = UILabel()
    let AIScanner = UIImage(named: "AI Scanner")!.cgImage!
    let AI_Scanner = UIImage(named: "AI-Scanner")!.cgImage!
    
    //in this function our first view is loading
    override func loadView() {
        view = PlaygroundView()
        view.backgroundColor = .black
        

        

        untint()
        
        // click listeners

        landscapeLeft.addTarget(nil, action: #selector(self.landscapeLeftF), for: .touchUpInside)

        
        // implementing click listeners

        view.addSubview(landscapeLeft)
        view.addSubview(txtlabel)

    }
    
    // Constraints of first view are contained in this function
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        landscapeLeft.frame = CGRect(x: 0, y: (view.frame.height / 4.5), width: view.frame.width, height: view.frame.height / 3)

        NSLayoutConstraint.activate([

            landscapeLeft.widthAnchor.constraint(equalTo: (view as! PlaygroundView).liveViewSafeAreaGuide.widthAnchor),
            landscapeLeft.leadingAnchor.constraint(equalTo: (view as! PlaygroundView).liveViewSafeAreaGuide.leadingAnchor)

            ])
    }
    
    // Images of portrait, landscape mode
    func untint() {

        landscapeLeft.setImage(UIImage(cgImage: AIScanner, scale: 0.5, orientation: .up), for: .normal)
        txtlabel.text = "Welcome to AI Scanner!!!"
        txtlabel.frame = CGRect(x: 60 ,y: 500 ,width: 500, height: 80)
        txtlabel.font = txtlabel.font.withSize(36)
        txtlabel.textColor = UIColor.white
    }

    
    // landscape left mode image:-
    @objc func landscapeLeftF() {
        PlaygroundKeyValueStore.current["orientation"] = .integer(3)
        untint()
        landscapeLeft.setImage(UIImage(cgImage: AI_Scanner, scale: 0.5, orientation: .up), for: .normal)
    }
    }

// first view's orientation controller
var vc = OrientationViewController()
PlaygroundPage.current.liveView = vc
