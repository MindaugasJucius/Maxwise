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
    
    private let digitRecognizer = DigitRecognizer()
    private let cameraController = CameraController()
    private var cameraLayer: AVCaptureVideoPreviewLayer?
    
    private var trackingLayers = [CALayer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let image = UIImage.init(named: "ReceiptSwiss")
        //digitRecognizer.recognize(image: image)
        addCameraLayer()
    }
    
    func addCameraLayer() {

        let cameraLayer = AVCaptureVideoPreviewLayer(session: cameraController.captureSession)
        cameraLayer.frame = view.bounds
        cameraLayer.videoGravity = .resizeAspectFill
        self.cameraLayer = cameraLayer
        view.layer.addSublayer(cameraLayer)
        cameraController.captureSession.startRunning()
        cameraController.delegate = self

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
