import Foundation
import AVKit
import Vision

protocol TextDetectionDelegate: class {
    func detected(boundingBoxes: [CGRect])
}

class CameraController: NSObject {
    
    private let queue = DispatchQueue(label: "MyQueue")
    weak var delegate: TextDetectionDelegate?
    
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
        let photoOutput = AVCapturePhotoOutput()
        //photoOutput.capturePhoto(with: <#T##AVCapturePhotoSettings#>, delegate: <#T##AVCapturePhotoCaptureDelegate#>)
        //photoOutput.capturePhoto(with: <#T##AVCapturePhotoSettings#>, delegate: <#T##AVCapturePhotoCaptureDelegate#>)
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: queue)
        captureSession.addOutput(videoOutput)
    }
    
    private func handle(buffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) else {
            return
        }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        guard let image = ciImage.toUIImage() else {
            return
        }
        
        let inferedOrientation = CGImagePropertyOrientation(image.imageOrientation)

        let handler = VNImageRequestHandler(
            ciImage: ciImage,
            orientation: inferedOrientation,
            options: [VNImageOption: Any]()
        )
        
        let request = VNDetectTextRectanglesRequest(completionHandler: { [weak self] request, error in
            DispatchQueue.main.async {
                
                guard let textObservations = request.results as? [VNTextObservation] else {
                    return
                }
                self?.delegate?.detected(boundingBoxes: textObservations.map { $0.boundingBox })
                //self?.handle(image: image, request: request, error: error)
            }
        })

        request.reportCharacterBoxes = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch let error as NSError {
                print("Failed to perform image request: \(error)")
                //self.presentAlert("Image Request Failed", error: error)
                return
            }
        }
    }
    
}

extension CameraController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        handle(buffer: sampleBuffer)
    }
    
}

extension CIImage {
    func toUIImage() -> UIImage? {
        let context: CIContext = CIContext.init(options: nil)
        
        if let cgImage: CGImage = context.createCGImage(self, from: self.extent) {
            return UIImage(cgImage: cgImage)
        } else {
            return nil
        }
    }
}

extension CGImagePropertyOrientation {
    init(_ uiImageOrientation: UIImage.Orientation) {
        switch uiImageOrientation {
        case .up: self = .up
        case .down: self = .down
        case .left: self = .left
        case .right: self = .right
        case .upMirrored: self = .upMirrored
        case .downMirrored: self = .downMirrored
        case .leftMirrored: self = .leftMirrored
        case .rightMirrored: self = .rightMirrored
        }
    }
}
