//
//  DigitRecognizer.swift
//  maxwise
//
//  Created by Mindaugas Jucius on 2/3/19.
//  Copyright © 2019 Mindaugas Jucius. All rights reserved.
//

import Foundation
import TesseractOCR

class DigitRecognizer {

    let operationQueue = OperationQueue()
    
    func recognize(image: UIImage?, completion: @escaping (String?) -> ()) {
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
        operation.tesseract.pageSegmentationMode = .singleBlock
        operation.tesseract.charWhitelist = "01234567890.,"
        operation.recognitionCompleteBlock = { tesseract in
            completion(tesseract?.recognizedText)
        }
        operationQueue.addOperation(operation)
    }

}
