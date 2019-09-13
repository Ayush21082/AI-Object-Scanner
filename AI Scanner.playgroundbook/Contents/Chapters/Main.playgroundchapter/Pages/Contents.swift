
//
//  AI Scanner
//
//  Contents.swift
//  Created by Ayush Singh on 18/03/2019.
//  Copyright © 2019 Ayush Singh. All rights reserved.
//

//#-hidden-code
import UIKit
import CoreML
import PlaygroundSupport

class PlaygroundView: UIView, PlaygroundLiveViewSafeAreaContainer {}

// Frame of playground view
var frame: CGRect {
    return PlaygroundView().liveViewSafeAreaGuide.layoutFrame
}

var orientation = 0

// Image orientation function
func imageOrientation(from orientation: Int) -> UIImageOrientation {
    switch orientation {
    case 3:
        return .up
    case 4:
        return .down
    case 2:
        return .left
    case 1:
        return .right
    default:
        return .up
    }
}

// Extension of Image
extension UIImage {
    func resize(targetSize: CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        var nImg: UIImage
        if (widthRatio > heightRatio) {
            newSize = CGSize(width: size.height * heightRatio, height: size.height * heightRatio)
            print("newSize w=\(newSize.width) h=\(newSize.height)")
            nImg = self.crop(rect: CGRect(x: (size.height - size.width) / 2, y: 0, width: size.width, height: size.width))
            print("nImg w=\(nImg.size.width) h=\(nImg.size.height)")
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.width * widthRatio)
            print("newSize w=\(newSize.width) h=\(newSize.height)")
            nImg = self.crop(rect: CGRect(x: 0, y: (size.width - size.height) / 2, width: size.height, height: size.height))
            print("nImg w=\(nImg.size.width) h=\(nImg.size.height)")
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        print("rect w=\(rect.width) h=\(rect.height)")
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(CGSize(width: rect.width - 1, height: rect.height - 1), false, 1.0)
        print("context w=\(String(describing: UIGraphicsGetCurrentContext()?.width)) h=\(String(describing: UIGraphicsGetCurrentContext()?.height))")
        nImg.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        print("newImage w=\(newImage!.size.width) h=\(newImage!.size.height)")
        
        return newImage!
    }
    
    // Auto crop function
    func crop(rect: CGRect) -> UIImage {
        var rect = rect
        rect.origin.x*=self.scale
        rect.origin.y*=self.scale
        rect.size.width*=self.scale
        rect.size.height*=self.scale
        
        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return image
    }
    
    // Pixel setter function(Hidden working)
    func pixelBuffer() -> CVPixelBuffer? {
        let image = self.cgImage!
        let frameSize = CGSize(width: image.width, height: image.height)
        
        var pixelBuffer:CVPixelBuffer? = nil
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(frameSize.width), Int(frameSize.height), kCVPixelFormatType_32BGRA , nil, &pixelBuffer)
        
        if status != kCVReturnSuccess {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags.init(rawValue: 0))
        let data = CVPixelBufferGetBaseAddress(pixelBuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
        let context = CGContext(data: data, width: Int(frameSize.width), height: Int(frameSize.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context?.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
}

// Dictionary extension, so that projects shows proper words and their spellings
extension Dictionary {
    func sortedKeys(isOrderedBefore:(Key,Key) -> Bool) -> [Key] {
        return Array(self.keys).sorted(by: isOrderedBefore)
    }
    
    // Slower because of a lot of lookups, but probably takes less memory (this is equivalent to Pascals answer in an generic extension)
    func sortedKeysByValue(isOrderedBefore:(Value, Value) -> Bool) -> [Key] {
        return sortedKeys {
            isOrderedBefore(self[$0]!, self[$1]!)
        }
    }
    
    // Faster because of no lookups, may take more memory because of duplicating contents
    func keysSortedByValue(isOrderedBefore:(Value, Value) -> Bool) -> [Key] {
        return Array(self)
            .sorted() {
                let (_, lv) = $0
                let (_, rv) = $1
                return isOrderedBefore(lv, rv)
            }
            .map {
                let (k, _) = $0
                return k
        }
    }
}

// Image scanner class, this class contains functioning of scanning image and showing information ablout image scanned.
class IdentifyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var imageView: UIImageView!
    var image: UIImage!
    var tableView: UITableView!
    var alertStatus = false
    var cells = [String]()
    var reg = try! NSRegularExpression(pattern: " \\(.+\\)", options: .caseInsensitive)
    
    func clean(_ str: String) -> String {
        return reg.stringByReplacingMatches(in: str, options: [], range: NSRange(0..<str.utf16.count), withTemplate: "")
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func loadView() {
        let newView = PlaygroundView()
        newView.backgroundColor = .white
        if case let .data(d) = PlaygroundKeyValueStore.current["photoval"]! {
            image = UIImage(data: d)
            image = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: imageOrientation(from: orientation))
        } else {
            let vc = ErrorView()
            view = vc.view
            image = UIImage()
            tableView = UITableView()
            imageView = UIImageView()
            return
        }
        //image = UIImage(cgImage: newCgIm!, scale: photoval!.scale, orientation: photoval!.imageOrientation)
        //assert(image != photoval.pointee)
        //print("w=\(image.size.width), h=\(image.size.height)")
        image = image.resize(targetSize: CGSize(width: 224, height: 224))
        //print("w=\(image.size.width), h=\(image.size.height)")
        imageView = UIImageView(image: image)
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.clipsToBounds = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        newView.addSubview(tableView)
        newView.addSubview(imageView)
        view = newView
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: (view as! PlaygroundView).liveViewSafeAreaGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: (view as! PlaygroundView).liveViewSafeAreaGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: (view as! PlaygroundView).liveViewSafeAreaGuide.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            imageView.topAnchor.constraint(equalTo: (view as! PlaygroundView).liveViewSafeAreaGuide.topAnchor, constant: 20),
            imageView.centerXAnchor.constraint(equalTo: (view as! PlaygroundView).liveViewSafeAreaGuide.centerXAnchor),
            NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: imageView, attribute: .width, multiplier: 1, constant: image.size.width),
            NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: 1, constant: image.size.width),
            ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let model = MobileNet()
        guard let prediction = try? model.prediction(data: image.pixelBuffer()!) else {
            print("An error occurred while trying to find an object.")
            alertStatus = true
            return
        }
        for k in prediction.prob.keysSortedByValue(isOrderedBefore: >) {
            let regex = try! NSRegularExpression(pattern: "\\bn[0-9]+ \\b", options: .caseInsensitive)
            let regex2 = try! NSRegularExpression(pattern: "\\b,.+\\b", options: .caseInsensitive)
            let newk2 = regex.stringByReplacingMatches(in: k, options: [], range: NSRange(0..<k.utf16.count), withTemplate: "")
            let newk = regex2.stringByReplacingMatches(in: newk2, options: [], range: NSRange(0..<newk2.utf16.count), withTemplate: "")
            if prediction.prob[k]! > 0.25 {
                cells.append("\(newk) (\(round(prediction.prob[k]!*100))% probability)")
                print("\(newk) (\(round(prediction.prob[k]!*100))% probability)")
            } else {
                //print("Low probability (\(prediction.prob[k]!*100)%) for \"\(newk)\"")
            }
        }
        //print("Reloading table")
        tableView.reloadData()
        if prediction.prob.count == 0 {
            PlaygroundPage.current.assessmentStatus = .fail(hints: ["The iPad was not able to figure out what you were trying to take a photo of. Go back and try taking the photo again."], solution: nil)
        }
        //print("Done reloading")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //imageView.frame = CGRect(x: (view.frame.width - image.size.width) / 2, y: 84, width: image.size.width, height: image.size.height)
        //tableView.frame = CGRect(x: 0, y: 308, width: view.frame.width, height: view.frame.height - 372)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //print("Did appear")
        super.viewDidAppear(animated)
        if alertStatus {
            let alert = UIAlertController(title: "Prediction Error", message: "An error occurred while trying to find an object.", preferredStyle: .alert)
            alert.show(self, sender: nil)
        }
    }
    
    //delegate methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableView {
            return cells.count
        }
        return Int()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print("tv(_:cfra:)")
        if tableView == self.tableView {
            //let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.prepareForReuse()
            
            let row = indexPath.row
            cell.textLabel?.text = cells[row]
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        PlaygroundKeyValueStore.current["objectName"] = .string(clean((tableView.cellForRow(at: indexPath)?.textLabel?.text!)!))
        PlaygroundPage.current.assessmentStatus = .pass(message: "On the next page, you can place the object you selected around the world.  \n\n[**Next Page**](@next)")
    }
    
}

class ErrorView: UIViewController {
    override func loadView() {
        view = PlaygroundView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .white
        let errorLabel = UILabel(frame: CGRect(x: 0, y: (view.frame.height - 18) / 2, width: 100, height: 18))
        errorLabel.text = "Please take a picture of something before running this page."
        errorLabel.textColor = .white
        errorLabel.textAlignment = .center
        errorLabel.clipsToBounds = true
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorLabel)
        NSLayoutConstraint.activate([
            errorLabel.leadingAnchor.constraint(equalTo: (view as! PlaygroundView).liveViewSafeAreaGuide.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: (view as! PlaygroundView).liveViewSafeAreaGuide.trailingAnchor),
            errorLabel.topAnchor.constraint(equalTo: (view as! PlaygroundView).liveViewSafeAreaGuide.topAnchor),
            errorLabel.bottomAnchor.constraint(equalTo: (view as! PlaygroundView).liveViewSafeAreaGuide.bottomAnchor)
            ])
    }
}

//Declairing UIViewController for this playground chapter
var vc: UIViewController = ErrorView()
if let val = PlaygroundKeyValueStore.current["photoval"] {
    if case let .data(d) = val {
        if let num = PlaygroundKeyValueStore.current["orientation"] {
            if case let .integer(i) = num {
                vc = IdentifyViewController()
                orientation = i
            }
        }
    }
}
PlaygroundPage.current.liveView = vc
//#-end-hidden-code
//#-end-hidden-code

