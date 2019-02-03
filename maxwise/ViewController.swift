//
//  ViewController.swift
//  maxwise
//
//  Created by Mindaugas Jucius on 2/3/19.
//  Copyright © 2019 Mindaugas Jucius. All rights reserved.
//

import UIKit
import TesseractOCR

class ViewController: UIViewController {

    let operationQueue = OperationQueue()
    
//    lazy var tesseract: G8Tesseract? = {
//        let tesseract = G8Tesseract(language: "eng")
//        tesseract?.engineMode = .tesseractCubeCombined
//        tesseract?.pageSegmentationMode = .auto
//        return tesseract
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage.init(named: "ReceiptSwiss")
        recognize(image: image)
    }

    private func recognize(image: UIImage?) {
        guard let image = image else {
            fatalError("No image")
        }
        guard let operation = G8RecognitionOperation(language: "eng",
                                                configDictionary: nil,
                                                configFileNames: nil,
                                                absoluteDataPath: Bundle.main.bundlePath,
                                                engineMode: .tesseractCubeCombined) else {
            return
        }
        operation.tesseract.image = image
        operation.tesseract.pageSegmentationMode = .auto
        operation.recognitionCompleteBlock = { tesseract in
            print(tesseract?.recognizedText)
            
        }
        operationQueue.addOperation(operation)
//        operation?.tesseract.re
//        tesseract?.image = image//.g8_blackAndWhite()
//        tesseract?.recognize()
//        print(tesseract?.recognizedText)
    }

}

