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
    
    private var trackingLayers = [CALayer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCameraLayer()
    }
    
    func addCameraLayer() {
        let cameraLayer = AVCaptureVideoPreviewLayer(session: cameraController.captureSession)
        cameraLayer.frame = view.bounds
        cameraLayer.videoGravity = .resizeAspect
        self.cameraLayer = cameraLayer
        view.layer.insertSublayer(cameraLayer, at: 0)
        cameraController.captureSession.startRunning()
        cameraController.delegate = self
        cameraController.pictureDelegate = self
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        cameraController.takePhoto()
    }
    
}

extension ViewController: TextDetectionDelegate {
    
    func detected(boundingBoxes: [CGRect]) {
        trackingLayers.forEach { $0.removeFromSuperlayer() }
        let layers: [CALayer] = boundingBoxes.compactMap { box in
            guard let converted = cameraLayer?.layerRectConverted(fromMetadataOutputRect: box) else {
                return nil
            }
            
            let layer = CALayer()
            layer.frame = converted
            layer.borderWidth = 2
            layer.borderColor = UIColor.green.cgColor
            return layer
        }
        trackingLayers = layers
        layers.forEach {
            view.layer.addSublayer($0)
        }
    }
    
}

extension ViewController: PictureRetrievalDelegate {
    
    func captured(image: UIImage) {
        let imageView = UIImageView(image: image)
        
        view.insertSubview(imageView, belowSubview: captureButton)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = view.bounds
    }
    
}
