/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller: handles camera, preview and cutout UI.
*/

import UIKit
import AVFoundation
import Vision

class RootVisionViewController: UIViewController {
	// MARK: - UI objects
	@IBOutlet weak var previewView: PreviewView!
	@IBOutlet weak var cutoutView: UIView!
    
    private var infoLabelContainerViewYConstraint: NSLayoutConstraint?
    private lazy var infoLabelContainerView = VibrantContentView()
    
    private lazy var infoLabel: UILabel = {
        let label = InsetLabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.text = "Fill amount by pointing to digits".uppercased()
        label.textAlignment = .center
        label.textColor = .label
        label.backgroundColor = .systemBackground
        label.textInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        return label
    }()
    
    private var retryButtonContainerViewYConstraint: NSLayoutConstraint?
    private lazy var retryButtonContainerView = VibrantContentView()
    
    private lazy var retryButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.2.circlepath"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0.5,
                                              left: 0.5,
                                              bottom: 0,
                                              right: 0)
        button.addTarget(self, action: #selector(resumeCameraSession), for: .touchUpInside)
        return button
    }()
    
    var didReceiveStableString: ((String) -> ())?
    
	var maskLayer = CAShapeLayer()
	// Device orientation. Updated whenever the orientation changes to a
	// different supported orientation.
	var currentOrientation = UIDeviceOrientation.portrait
	
	// MARK: - Capture related objects
	private let captureSession = AVCaptureSession()

    let captureSessionQueue = DispatchQueue(label: "com.maxwise.CaptureSessionQueue", qos: .userInitiated)
    
	var captureDevice: AVCaptureDevice?
    
	var videoDataOutput = AVCaptureVideoDataOutput()
    let videoDataOutputQueue = DispatchQueue(label: "com.maxwise.VideoDataOutputQueue")
    
	// MARK: - Region of interest (ROI) and text orientation
	// Region of video data output buffer that recognition should be run on.
	// Gets recalculated once the bounds of the preview layer are known.
	var regionOfInterest = CGRect(x: 0, y: 0, width: 1, height: 1)
	// Orientation of text to search for in the region of interest.
	var textOrientation = CGImagePropertyOrientation.up
	
	// MARK: - Coordinate transforms
	var bufferAspectRatio: Double!
	// Transform from UI orientation to buffer orientation.
	var uiRotationTransform = CGAffineTransform.identity
	// Transform bottom-left coordinates to top-left.
	var bottomToTopTransform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)
	// Transform coordinates in ROI to global coordinates (still normalized).
	var roiToGlobalTransform = CGAffineTransform.identity
	
	// Vision -> AVF coordinate transform.
	var visionToAVFTransform = CGAffineTransform.identity
	
	// MARK: - View controller methods
	
	override func viewDidLoad() {
		super.viewDidLoad()

		// Set up preview view.
		previewView.session = captureSession
        previewView.videoPreviewLayer.videoGravity = .resizeAspectFill
		
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(resumeCameraSession))
        view.addGestureRecognizer(tapGesture)
        
		// Set up cutout view.
		cutoutView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
		maskLayer.backgroundColor = UIColor.clear.cgColor
		maskLayer.fillRule = .evenOdd
		cutoutView.layer.mask = maskLayer
        
        configureInfoContainerView()
        retryButtonContainerView.isHidden = true
        configureRetryButton()
        
        // Starting the capture session is a blocking call. Perform setup using
        // a dedicated serial dispatch queue to prevent blocking the main thread.
        captureSessionQueue.async {
            self.setupCamera()
            
            // Calculate region of interest now that the camera is setup.
            DispatchQueue.main.async {
                // Figure out initial ROI.
                self.calculateRegionOfInterest()
            }
        }
	}
    
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		updateCutoutToRegionOfInterest()
	}
    
    // MARK: - Setup
	
    private func configureRetryButton() {
        cutoutView.addSubview(retryButtonContainerView)
        retryButtonContainerView.configuration = VibrantContentView.Configuration(
            cornerStyle: .circular,
            blurEffectStyle: .prominent
        )
        
        retryButtonContainerView.contentView?.addSubview(retryButton)
        retryButton.fillInSuperview()
        
        let retryContainerYConstraint = retryButtonContainerView.centerYAnchor.constraint(equalTo: cutoutView.centerYAnchor)
        let containerConstraints = [
            retryButtonContainerView.centerXAnchor.constraint(equalTo: cutoutView.centerXAnchor),
            retryButtonContainerView.widthAnchor.constraint(equalToConstant: 40),
            retryButtonContainerView.heightAnchor.constraint(equalTo: retryButtonContainerView.widthAnchor,
                                                             multiplier: 1),
            retryContainerYConstraint
        ]

        self.retryButtonContainerViewYConstraint = retryContainerYConstraint
        
        NSLayoutConstraint.activate(containerConstraints)
    }
    
    private func configureInfoContainerView() {
        cutoutView.addSubview(infoLabelContainerView)

        infoLabelContainerView.configuration = VibrantContentView.Configuration(
            cornerStyle: .rounded,
            blurEffectStyle: .prominent
        )
        
        infoLabelContainerView.contentView?.addSubview(infoLabel)
        infoLabel.fillInSuperview()
        
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let infoContainerYConstraint = infoLabelContainerView.centerYAnchor.constraint(equalTo: cutoutView.centerYAnchor)
        let containerConstraints = [
            infoLabelContainerView.centerXAnchor.constraint(equalTo: cutoutView.centerXAnchor),
            infoContainerYConstraint
        ]

        self.infoLabelContainerViewYConstraint = infoContainerYConstraint
        
        NSLayoutConstraint.activate(containerConstraints)
    }
	
	func calculateRegionOfInterest() {
		// In landscape orientation the desired ROI is specified as the ratio of
		// buffer width to height. When the UI is rotated to portrait, keep the
		// vertical size the same (in buffer pixels). Also try to keep the
		// horizontal size the same up to a maximum ratio.
		let desiredHeightRatio = 0.15
		let desiredWidthRatio = 0.6
		let maxPortraitWidth = 0.8
		
		// Figure out size of ROI.
		let size: CGSize
		if currentOrientation.isPortrait || currentOrientation == .unknown {
			size = CGSize(width: min(desiredWidthRatio * bufferAspectRatio, maxPortraitWidth), height: desiredHeightRatio / bufferAspectRatio)
		} else {
			size = CGSize(width: desiredWidthRatio, height: desiredHeightRatio)
		}
		// Make it centered.
		regionOfInterest.origin = CGPoint(x: (1 - size.width) / 2, y: (1 - size.height) / 2)
		regionOfInterest.size = size
		
		// ROI changed, update transform.
		setupOrientationAndTransform()
		
		// Update the cutout to match the new ROI.
		DispatchQueue.main.async {
			// Wait for the next run cycle before updating the cutout. This
			// ensures that the preview layer already has its new orientation.
			self.updateCutoutToRegionOfInterest()
		}
	}
	
	private func updateCutoutToRegionOfInterest() {
		// Figure out where the cutout ends up in layer coordinates.
		let roiRectTransform = bottomToTopTransform.concatenating(uiRotationTransform)
		let cutout = previewView.videoPreviewLayer.layerRectConverted(fromMetadataOutputRect: regionOfInterest.applying(roiRectTransform))
		
        updateCutout(to: cutout)
	}
    
    private func updateCutout(to frame: CGRect) {
        // Create the mask.
        let path = UIBezierPath(rect: cutoutView.frame)
        path.append(UIBezierPath.init(roundedRect: frame, cornerRadius: 6))
        maskLayer.path = path.cgPath
        
        infoLabelContainerViewYConstraint?.constant = -frame.size.height
        retryButtonContainerViewYConstraint?.constant = frame.size.height
    }
	
	func setupOrientationAndTransform() {
		// Recalculate the affine transform between Vision coordinates and AVF coordinates.
		
		// Compensate for region of interest.
		let roi = regionOfInterest
		roiToGlobalTransform = CGAffineTransform(translationX: roi.origin.x, y: roi.origin.y).scaledBy(x: roi.width, y: roi.height)
		
		// Compensate for orientation (buffers always come in the same orientation).
		switch currentOrientation {
		case .landscapeLeft:
			textOrientation = CGImagePropertyOrientation.up
			uiRotationTransform = CGAffineTransform.identity
		case .landscapeRight:
			textOrientation = CGImagePropertyOrientation.down
			uiRotationTransform = CGAffineTransform(translationX: 1, y: 1).rotated(by: CGFloat.pi)
		case .portraitUpsideDown:
			textOrientation = CGImagePropertyOrientation.left
			uiRotationTransform = CGAffineTransform(translationX: 1, y: 0).rotated(by: CGFloat.pi / 2)
		default: // We default everything else to .portraitUp
			textOrientation = CGImagePropertyOrientation.right
			uiRotationTransform = CGAffineTransform(translationX: 0, y: 1).rotated(by: -CGFloat.pi / 2)
		}
		
		// Full Vision ROI to AVF transform.
		visionToAVFTransform = roiToGlobalTransform.concatenating(bottomToTopTransform).concatenating(uiRotationTransform)
	}
	
	func setupCamera() {
		guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) else {
			print("Could not create capture device.")
			return
		}
		self.captureDevice = captureDevice
		
		// NOTE:
		// Requesting 4k buffers allows recognition of smaller text but will
		// consume more power. Use the smallest buffer size necessary to keep
		// down battery usage.
		if captureDevice.supportsSessionPreset(.hd4K3840x2160) {
			captureSession.sessionPreset = AVCaptureSession.Preset.hd4K3840x2160
			bufferAspectRatio = 3840.0 / 2160.0
		} else {
			captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
			bufferAspectRatio = 1920.0 / 1080.0
		}
		
		guard let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) else {
			print("Could not create device input.")
			return
		}
		if captureSession.canAddInput(deviceInput) {
			captureSession.addInput(deviceInput)
		}
		
		// Configure video data output.
		videoDataOutput.alwaysDiscardsLateVideoFrames = true
		videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
		videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
		if captureSession.canAddOutput(videoDataOutput) {
			captureSession.addOutput(videoDataOutput)
			// NOTE:
			// There is a trade-off to be made here. Enabling stabilization will
			// give temporally more stable results and should help the recognizer
			// converge. But if it's enabled the VideoDataOutput buffers don't
			// match what's displayed on screen, which makes drawing bounding
			// boxes very hard. Disable it in this app to allow drawing detected
			// bounding boxes on screen.
			videoDataOutput.connection(with: AVMediaType.video)?.preferredVideoStabilizationMode = .off
		} else {
			print("Could not add VDO output")
			return
		}
		
		// Set zoom and autofocus to help focus on very small text.
		do {
			try captureDevice.lockForConfiguration()
			captureDevice.videoZoomFactor = 2
			captureDevice.autoFocusRangeRestriction = .near
			captureDevice.unlockForConfiguration()
		} catch {
			print("Could not set zoom level due to error: \(error)")
			return
		}
		
		captureSession.startRunning()
	}
	
	// MARK: - UI drawing and interaction
	
    func showString(string: String) {
		// Found a definite number.
		// Stop the camera synchronously to ensure that no further buffers are
		// received. Then update the number view asynchronously.
		captureSessionQueue.sync {
			self.captureSession.stopRunning()
            DispatchQueue.main.async {
                self.retryButtonContainerView.isHidden = false
                self.didReceiveStableString?(string)
            }
		}
	}
	
	@objc func resumeCameraSession() {
        captureSessionQueue.async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
            DispatchQueue.main.async {
                self.retryButtonContainerView.isHidden = true
            }
        }
	}
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension RootVisionViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
	
	func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
		// This is implemented in VisionViewController.
	}
}

// MARK: - Utility extensions

extension AVCaptureVideoOrientation {
	init?(deviceOrientation: UIDeviceOrientation) {
		switch deviceOrientation {
		case .portrait: self = .portrait
		case .portraitUpsideDown: self = .portraitUpsideDown
		case .landscapeLeft: self = .landscapeRight
		case .landscapeRight: self = .landscapeLeft
		default: return nil
		}
	}
}
