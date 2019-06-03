import UIKit
import AVKit

protocol CameraCaptureDelegate: class {
    func captured(image: CGImage, orientation: CGImagePropertyOrientation, tapLocation: CGPoint)
}

class CameraViewController: UIViewController {
    
    private let cameraController = CameraController()
    private var cameraLayer: AVCaptureVideoPreviewLayer?
    
    @IBOutlet private weak var explanationContainerView: VibrantContentView!
    private lazy var explanationLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "Tap to recognize numbers"
        return label
    }()
    
    private var tapLocation: CGPoint?
    
    private weak var captureDelegate: CameraCaptureDelegate?
    
    let minimumZoom: CGFloat = 1.0
    let maximumZoom: CGFloat = 3.0
    var lastZoomFactor: CGFloat = 1.0
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    init(captureDelegate: CameraCaptureDelegate) {
        self.captureDelegate = captureDelegate
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCameraLayer()
        view.backgroundColor = .white
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinch(_:)))
        view.addGestureRecognizer(pinch)
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        view.addGestureRecognizer(tap)
        view.layer.cornerRadius = 6
        
        explanationContainerView.configuration = VibrantContentView.Configuration(cornerStyle: .rounded,
                                                                                  blurEffectStyle: .prominent)
        explanationContainerView.contentView?.addSubview(explanationLabel)
        let labelConstraints = [
            explanationLabel.centerXAnchor.constraint(equalTo: explanationContainerView.centerXAnchor),
            explanationLabel.centerYAnchor.constraint(equalTo: explanationContainerView.centerYAnchor)
        ]
        NSLayoutConstraint.activate(labelConstraints)
    }
    
    private func addCameraLayer() {
        let cameraLayer = AVCaptureVideoPreviewLayer(session: cameraController.captureSession)
        cameraLayer.videoGravity = .resizeAspectFill
        self.cameraLayer = cameraLayer
        view.layer.insertSublayer(cameraLayer, at: 0)
        
        cameraController.captureSession.startRunning()
        cameraController.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        cameraLayer?.frame = view.bounds
        CATransaction.commit()
    }
    
    private func takePhoto() {
        #if targetEnvironment(simulator)
            let testImage = UIImage(named: "testImage")
            guard let cgImage = testImage?.cgImage else {
                return
            }
            self.captured(image: cgImage, orientation: .up)
        #else
        cameraController.takePhoto()
        #endif
    }
    
    @objc private func tap(_ tap: UITapGestureRecognizer) {
        tapLocation = tap.location(in: view)
        takePhoto()
    }
    
    @objc private func pinch(_ pinch: UIPinchGestureRecognizer) {
        guard let device = cameraController.backCamera else { return }
        
        // Return zoom value between the minimum and maximum zoom values
        func minMaxZoom(_ factor: CGFloat) -> CGFloat {
            return min(min(max(factor, minimumZoom), maximumZoom), device.activeFormat.videoMaxZoomFactor)
        }
        
        func update(scale factor: CGFloat) {
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                device.videoZoomFactor = factor
            } catch {
                print("\(error.localizedDescription)")
            }
        }
        
        let newScaleFactor = minMaxZoom(pinch.scale * lastZoomFactor)
        
        switch pinch.state {
        case .began: fallthrough
        case .changed: update(scale: newScaleFactor)
        case .ended:
            lastZoomFactor = minMaxZoom(newScaleFactor)
            update(scale: lastZoomFactor)
        default: break
        }
    }
}

extension CameraViewController: PictureRetrievalDelegate {
    
    func captured(image: CGImage, orientation: CGImagePropertyOrientation) {
        guard let tapLocation = tapLocation else {
            fatalError("Shouldn't happen")
        }
        captureDelegate?.captured(image: image,
                                  orientation: orientation,
                                  tapLocation: tapLocation)
    }
}
