//
//  ViewController.swift
//  maxwise
//
//  Created by Mindaugas Jucius on 2/3/19.
//  Copyright © 2019 Mindaugas Jucius. All rights reserved.
//

import UIKit
import AVKit

class CameraViewController: UIViewController {
    
    private let cameraController = CameraController()
    private var cameraLayer: AVCaptureVideoPreviewLayer?
    
    private let presentationDelegate: PresentationViewControllerDelegate
    
    let minimumZoom: CGFloat = 1.0
    let maximumZoom: CGFloat = 3.0
    var lastZoomFactor: CGFloat = 1.0
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    init(presentationDelegate: PresentationViewControllerDelegate) {
        self.presentationDelegate = presentationDelegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCameraLayer()
        view.backgroundColor = .black
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinch(_:)))
        view.addGestureRecognizer(pinch)
    }
    
    private func addCameraLayer() {
        let cameraLayer = AVCaptureVideoPreviewLayer(session: cameraController.captureSession)
        cameraLayer.frame = view.bounds
        cameraLayer.videoGravity = .resizeAspect
        self.cameraLayer = cameraLayer
        view.layer.insertSublayer(cameraLayer, at: 0)
        
        cameraController.captureSession.startRunning()
        cameraController.delegate = self
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        #if targetEnvironment(simulator)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            let testImage = UIImage(named: "testImage")
            guard let cgImage = testImage?.cgImage else {
                return
            }
            self.captured(image: cgImage, orientation: .up)
        }
        #else
        cameraController.takePhoto()
        #endif
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
        presentationDelegate.show(screen: .expenseCreation(image, orientation))
    }
}
