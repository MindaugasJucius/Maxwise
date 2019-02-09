import Foundation
import AVKit

protocol PictureRetrievalDelegate: class {
    func captured(image: CGImage, orientation: CGImagePropertyOrientation)
}

class CameraController: NSObject {
    
    weak var delegate: PictureRetrievalDelegate?
    
    private let photoOutput = AVCapturePhotoOutput()
    
    let backCamera = AVCaptureDevice.default(for: .video)
    
    lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.photo
        
        guard let backCamera = backCamera,
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
    

}

extension CameraController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let cgImage = photo.cgImageRepresentation()?.takeUnretainedValue() else {
            return
        }
        
//        guard let orientation = photo.metadata[kCGImagePropertyOrientation as String] as? NSNumber,
//            let cgImageEXIFOrientation = CGImagePropertyOrientation(rawValue: orientation.uint32Value) else {
//            fatalError("failed to retrieve CGImagePropertyOrientation")
//        }

        let deviceOrientation = UIDevice.current.orientation.exifOrientation()
        delegate?.captured(image: cgImage,
                                  orientation: deviceOrientation)
    }
    
}
