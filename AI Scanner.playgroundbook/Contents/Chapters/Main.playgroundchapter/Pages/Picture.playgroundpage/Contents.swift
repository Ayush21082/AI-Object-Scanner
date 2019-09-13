//#-hidden-code

//
//  AI Scanner
//
//  Contents.swift
//  Created by Ayush Singh on 18/03/2019.
//  Copyright © 2019 Ayush Singh. All rights reserved.
//

//#-end-hidden-code

//: ### Ai Scanner

/*:
 ###
 
 Hi! I'm **Ayush Singh**, a student of Macro Vision Academy(Apple Distinguished School), Burhanpur, M.P, India. I've devoted to iOS development since 2017 and this year, I made some digging into the latest `ARKit` and `Machine Learning`, which is awesome and easy to use! So I created a Ai Scanner project for WWDC 2019 scholarship submission. Hope you like it! 😊
 
 ### Welcome
 
 In order to let you get familiar with the project quickly, please use project in landscape left orientation. After tapping the `Run My Code` button, you have to take photo of object. Once clicked photo, the go to next page, then project gave you details about an object.
 
 #### Notice
 
 * When the project starts, keep your iPad in landscape left orientation.
 * It is recommended to run the game in a **landscape left** orientation.
 
 */

//#-hidden-code
import UIKit
import AVFoundation
import PlaygroundSupport

// Video orientation function
func videoOrientation(from orientation: Int) -> AVCaptureVideoOrientation {
    switch orientation {
    case 3:
        return .landscapeRight
    case 4:
        return .landscapeLeft
    case 2:
        return .portraitUpsideDown
    case 1:
        return .portrait
    default:
        return .portrait
    }
}

// Playground view class
class PlaygroundView: UIView, PlaygroundLiveViewSafeAreaContainer {}

// Frame of first view
var frame: CGRect {
    return PlaygroundView().liveViewSafeAreaGuide.layoutFrame
}

var orientation = 0


class Draw: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        //let h = rect.height
        //let w = rect.width
        let color: UIColor = .white
        
        let drect = rect
        let bpath: UIBezierPath = UIBezierPath(rect: drect)
        
        color.set()
        bpath.stroke()
        
        //print("it ran")
        
        //NSLog("drawRect has updated the view")
        
    }
    
}

// Captur View Controller class. This class contains function of capturing photo
class CaptureViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    var cameraView: UIView!
    var session: AVCaptureSession?
    var stillImageOutput: AVCapturePhotoOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var captureButton: UIButton!
    var capturing = false
    var circle1 : UIButton!
    var circle2 : UIButton!
    
    override func loadView() {
        let newView = PlaygroundView()
        newView.backgroundColor = .black
        cameraView = UIView()
        
        captureButton = UIButton(frame: CGRect(x: 229.5 , y: 611.5 , width: 60, height: 60))
        captureButton.layer.cornerRadius = 30
        captureButton.clipsToBounds = true
        captureButton.backgroundColor = .white
        captureButton.layer.zPosition = 10
        captureButton.isUserInteractionEnabled = true
        captureButton.addTarget(nil, action: #selector(self.takePic), for: .touchUpInside)
        
        
        circle1 = UIButton(frame: CGRect(x: 224.3 , y: 606.5 , width: 70, height: 70))
        circle1.layer.cornerRadius = 35
        circle1.clipsToBounds = true
        circle1.backgroundColor = .black
        circle1.layer.zPosition = 8
        circle1.isUserInteractionEnabled = true
        
        
        circle2 = UIButton(frame: CGRect(x: 222 , y: 604 , width: 75, height: 75))
        circle2.layer.cornerRadius = 37.5
        circle2.clipsToBounds = true
        circle2.backgroundColor = .white
        circle2.layer.zPosition = 6
        circle2.isUserInteractionEnabled = true


 
        newView.addSubview(circle1)
        newView.addSubview(circle2)
               newView.addSubview(captureButton)
        newView.addSubview(cameraView)
        view = newView
        cameraView.clipsToBounds = true
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cameraView.leadingAnchor.constraint(equalTo: (view as! PlaygroundView).liveViewSafeAreaGuide.leadingAnchor),
            cameraView.trailingAnchor.constraint(equalTo: (view as! PlaygroundView).liveViewSafeAreaGuide.trailingAnchor),
            cameraView.heightAnchor.constraint(equalTo: cameraView.widthAnchor),
            cameraView.centerYAnchor.constraint(equalTo: (view as! PlaygroundView).liveViewSafeAreaGuide.centerYAnchor)
            ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        session = AVCaptureSession()
        session!.sessionPreset = .photo
        let backCamera = AVCaptureDevice.default(for: .video)
        
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera!)
        } catch let error1 as NSError {
            error = error1
            input = nil
            print(error!.localizedDescription)
            return
        }
        
        if error == nil && session!.canAddInput(input) {
            session!.addInput(input)
            stillImageOutput = AVCapturePhotoOutput()
            if session!.canAddOutput(stillImageOutput!) {
                session!.addOutput(stillImageOutput!)
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session!)
                videoPreviewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
                videoPreviewLayer!.connection?.videoOrientation = videoOrientation(from: orientation)
                cameraView.layer.addSublayer(videoPreviewLayer!)
                session!.startRunning()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        videoPreviewLayer!.frame = cameraView.bounds    }
    
    @objc func takePic() {
        if !capturing {
            capturing = true
            stillImageOutput!.capturePhoto(with: AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg]), delegate: self)
        }
    }
    
    // Change Orientation function, this function contains working of change orientation button.
    @objc func changeOrientation() {
        let newvc = OrientationViewController()
        PlaygroundPage.current.liveView = newvc
    }
    
    // function of photo out put
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        PlaygroundKeyValueStore.current["photoval"] = .data(photo.fileDataRepresentation()!)
        PlaygroundPage.current.assessmentStatus = .pass(message: "Now that there is an image to scan, we can move on to the next page to tell the iPad to figure out what it is.  \n\n[**Next Page**](@next)")
        self.capturing = false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}

// orientation controller class of device
class OrientationViewController: UIViewController {
    var portrait = UIButton()
    var portraitUpsideDown = UIButton()
    var landscapeLeft = UIButton()
    var landscapeRight = UIButton()
    
    override func loadView() {
        view = PlaygroundView()
        view.backgroundColor = .white
        let ipad = UIImage(named: "AI Scanners")!.cgImage!
        portrait.setImage(UIImage(cgImage: ipad), for: .normal)
        portraitUpsideDown.setImage(UIImage(cgImage: ipad, scale: 1.0, orientation: .down), for: .normal)
        landscapeLeft.setImage(UIImage(cgImage: ipad, scale: 1.0, orientation: .left), for: .normal)
        landscapeRight.setImage(UIImage(cgImage: ipad, scale: 1.0, orientation: .right), for: .normal)
        portrait.addTarget(nil, action: #selector(self.portraitF), for: .touchUpInside)
        portraitUpsideDown.addTarget(nil, action: #selector(self.portraitUpsideDownF), for: .touchUpInside)
        landscapeLeft.addTarget(nil, action: #selector(self.landscapeLeftF), for: .touchUpInside)
        landscapeRight.addTarget(nil, action: #selector(self.landscapeRightF), for: .touchUpInside)
        view.addSubview(portrait)
        view.addSubview(portraitUpsideDown)
        view.addSubview(landscapeLeft)
        view.addSubview(landscapeRight)
    }
    
    // constraints of capturing photo
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        portrait.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 4)
        portraitUpsideDown.frame = CGRect(x: 0, y: view.frame.height / 4, width: view.frame.width, height: view.frame.height / 4)
        landscapeLeft.frame = CGRect(x: 0, y: (view.frame.height / 4) * 2, width: view.frame.width, height: view.frame.height / 4)
        landscapeRight.frame = CGRect(x: 0, y: (view.frame.height / 4) * 3, width: view.frame.width, height: view.frame.height / 4)
        NSLayoutConstraint.activate([
            portrait.widthAnchor.constraint(equalTo: (view as! PlaygroundView).liveViewSafeAreaGuide.widthAnchor),
            portraitUpsideDown.widthAnchor.constraint(equalTo: (view as! PlaygroundView).liveViewSafeAreaGuide.widthAnchor),
            landscapeLeft.widthAnchor.constraint(equalTo: (view as! PlaygroundView).liveViewSafeAreaGuide.widthAnchor),
            landscapeRight.widthAnchor.constraint(equalTo: (view as! PlaygroundView).liveViewSafeAreaGuide.widthAnchor),
            portrait.leadingAnchor.constraint(equalTo: (view as! PlaygroundView).liveViewSafeAreaGuide.leadingAnchor),
            portraitUpsideDown.leadingAnchor.constraint(equalTo: (view as! PlaygroundView).liveViewSafeAreaGuide.leadingAnchor),
            landscapeLeft.leadingAnchor.constraint(equalTo: (view as! PlaygroundView).liveViewSafeAreaGuide.leadingAnchor),
            landscapeRight.leadingAnchor.constraint(equalTo: (view as! PlaygroundView).liveViewSafeAreaGuide.leadingAnchor)
            ])
    }
    
    // function of portrait mode
    @objc func portraitF() {
        PlaygroundKeyValueStore.current["orientation"] = .integer(1)
        orientation = 1
        let vc = CaptureViewController()
        PlaygroundPage.current.liveView = vc
    }
    
    // function of portrait upside down
    @objc func portraitUpsideDownF() {
        PlaygroundKeyValueStore.current["orientation"] = .integer(2)
        orientation = 2
        let vc = CaptureViewController()
        PlaygroundPage.current.liveView = vc
    }
    
    // function of landscape left mode
    @objc func landscapeLeftF() {
        PlaygroundKeyValueStore.current["orientation"] = .integer(3)
        orientation = 3
        let vc = CaptureViewController()
        PlaygroundPage.current.liveView = vc
    }
    
    // function of landscape right
    @objc func landscapeRightF() {
        PlaygroundKeyValueStore.current["orientation"] = .integer(4)
        orientation = 4
        let vc = CaptureViewController()
        PlaygroundPage.current.liveView = vc
    }
}

// declairing UIViewController
var vc: UIViewController = OrientationViewController()
if let or = PlaygroundKeyValueStore.current["orientation"] {
    if case let .integer(i) = or {
        orientation = i
        vc = CaptureViewController()
    }
}
PlaygroundPage.current.liveView = vc
//#-end-hidden-code
