
//
//  AI Scanner
//
//  MobileNet.swift
//  Created by Ayush Singh on 18/03/2019.
//  Copyright © 2019 Ayush Singh. All rights reserved.
//

import CoreML


/// Model Prediction Input Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public class MobileNetInput : MLFeatureProvider {

    /// Input image to be classified as color (kCVPixelFormatType_32BGRA) image buffer, 224 pixels wide by 224 pixels high
    public var data: CVPixelBuffer
    
    public var featureNames: Set<String> {
        get {
            return ["data"]
        }
    }
    
    public func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "data") {
            return MLFeatureValue(pixelBuffer: data)
        }
        return nil
    }
    
    public init(data: CVPixelBuffer) {
        self.data = data
    }
}


/// Model Prediction Output Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public class MobileNetOutput : MLFeatureProvider {

    /// Probability of each category as dictionary of strings to doubles
    public let prob: [String : Double]

    /// Most likely image category as string value
    public let classLabel: String
    
    public var featureNames: Set<String> {
        get {
            return ["prob", "classLabel"]
        }
    }
    
    public func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "prob") {
            return try! MLFeatureValue(dictionary: prob as [NSObject : NSNumber])
        }
        if (featureName == "classLabel") {
            return MLFeatureValue(string: classLabel)
        }
        return nil
    }
    
    public init(prob: [String : Double], classLabel: String) {
        self.prob = prob
        self.classLabel = classLabel
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public class MobileNet {
    var model: MLModel


    public init(contentsOf url: URL) throws {
        self.model = try MLModel(contentsOf: url)
    }

    public convenience init() {
        let bundle = Bundle(for: MobileNet.self)
        let assetPath = bundle.url(forResource: "MobileNet", withExtension:"mlmodelc")
        try! self.init(contentsOf: assetPath!)
    }


    public func prediction(input: MobileNetInput) throws -> MobileNetOutput {
        let outFeatures = try model.prediction(from: input)
        let result = MobileNetOutput(prob: outFeatures.featureValue(for: "prob")!.dictionaryValue as! [String : Double], classLabel: outFeatures.featureValue(for: "classLabel")!.stringValue)
        return result
    }


    public func prediction(data: CVPixelBuffer) throws -> MobileNetOutput {
        let input_ = MobileNetInput(data: data)
        return try self.prediction(input: input_)
    }
}
