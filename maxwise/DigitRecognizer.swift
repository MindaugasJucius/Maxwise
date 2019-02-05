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
    
    func recognize(image: UIImage?) {
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
    }

}
