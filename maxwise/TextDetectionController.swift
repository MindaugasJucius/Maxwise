import UIKit
import Vision

protocol TextDetectionDelegate: class {
    func detected(boundingBoxes: [CGRect])
}

class TextDetectionController {
    
    weak var delegate: TextDetectionDelegate?
    
    func handle(ciImage: CIImage, orientation: CGImagePropertyOrientation) {
        
        let handler = VNImageRequestHandler(
            ciImage: ciImage,
            orientation: orientation,
            options: [VNImageOption: Any]()
        )
        
        let request = VNDetectTextRectanglesRequest(completionHandler: { [weak self] request, error in
            DispatchQueue.main.async {
                guard let textObservations = request.results as? [VNTextObservation] else {
                    return
                }
                self?.delegate?.detected(boundingBoxes: textObservations.map { $0.boundingBox })
            }
        })
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch let error as NSError {
                print("Failed to perform image request: \(error)")
                return
            }
        }
    }
    
}

