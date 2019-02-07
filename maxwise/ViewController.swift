//
//  ViewController.swift
//  maxwise
//
//  Created by Mindaugas Jucius on 2/3/19.
//  Copyright © 2019 Mindaugas Jucius. All rights reserved.
//

import UIKit
import AVKit

class ViewController: UIViewController {
    
    @IBOutlet private weak var captureButton: UIButton!
    
    private let digitRecognizer = DigitRecognizer()
    private let cameraController = CameraController()
    private var cameraLayer: AVCaptureVideoPreviewLayer?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        addCameraLayer()
    }
    
    func addCameraLayer() {
        let cameraLayer = AVCaptureVideoPreviewLayer(session: cameraController.captureSession)
        cameraLayer.frame = view.bounds
        cameraLayer.videoGravity = .resizeAspectFill
        self.cameraLayer = cameraLayer
        view.layer.insertSublayer(cameraLayer, at: 0)
        
        cameraController.captureSession.startRunning()
        cameraController.delegate = self
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        cameraController.takePhoto()
    }
    
}

extension ViewController: PictureRetrievalDelegate {
    
    func captured(image: CGImage, orientation: CGImagePropertyOrientation) {
        let textDetectionController = TextPickViewController.init(cgImage: image,
                                                                  orientation: orientation)
        present(textDetectionController, animated: true, completion: nil)
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

