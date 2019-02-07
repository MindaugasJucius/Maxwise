import Foundation
import AVKit
import Vision

protocol TextDetectionDelegate: class {
    func detected(boundingBoxes: [CGRect])
}

protocol PictureRetrievalDelegate: class {
    func captured(image: UIImage)
}

class CameraController: NSObject {
    
    weak var delegate: TextDetectionDelegate?
    weak var pictureDelegate: PictureRetrievalDelegate?
    
    private let photoOutput = AVCapturePhotoOutput()
    
    lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.photo
        
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: backCamera) else {
            return session
        }
        
        session.addInput(input)
        return session
    }()
    
    override init() {
        super.init()
        captureSession.addOutput(photoOutput)
    }
    
    func takePhoto() {

        let settings = AVCapturePhotoSettings.init()
        settings.isAutoStillImageStabilizationEnabled = true
        settings.flashMode = .auto
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!

        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType]

        settings.previewPhotoFormat = previewFormat
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    private func handle(ciImage: CIImage, orientation: CGImagePropertyOrientation) {
        
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

extension CameraController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let cgImage = photo.cgImageRepresentation()?.takeUnretainedValue() else {
            return
        }
        
        let orientation = photo.metadata[kCGImagePropertyOrientation as String] as! NSNumber
        print(orientation)
        
        guard let cgImageEXIFOrientation = CGImagePropertyOrientation(rawValue: orientation.uint32Value) else {
            fatalError("failed to retrieve CGImagePropertyOrientation")
        }
        
        let uiImage = UIImage(cgImage: cgImage,
                              scale: 1,
                              orientation: UIImage.Orientation(cgImageEXIFOrientation))
        pictureDelegate?.captured(image: uiImage)
        
        let ciImage = CIImage(cgImage: cgImage)
        handle(ciImage: ciImage, orientation: cgImageEXIFOrientation)
    }
    
}

extension UIImage.Orientation {
    init(_ cgOrientation: CGImagePropertyOrientation) {
        switch cgOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }
}

//extension CGImagePropertyOrientation {
//    init(_ uiImageOrientation: UIImage.Orientation) {
//        switch uiImageOrientation {
//        case .up: self = .up
//        case .down: self = .down
//        case .left: self = .left
//        case .right: self = .right
//        case .upMirrored: self = .upMirrored
//        case .downMirrored: self = .downMirrored
//        case .leftMirrored: self = .leftMirrored
//        case .rightMirrored: self = .rightMirrored
//        }
//    }
//}

