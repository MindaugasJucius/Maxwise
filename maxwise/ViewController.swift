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
    private let imageView = UIImageView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCameraLayer()
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        imageView.contentMode = .scaleAspectFit
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
        guard let image = self.imageView.image else {
            return
        }
        
        let imageRect = AVMakeRect(aspectRatio: image.size,
                                   insideRect: imageView.bounds)

        
        trackingLayers.forEach { $0.removeFromSuperlayer() }
        let layers: [CALayer] = boundingBoxes.compactMap { boundingBox in
            let size = CGSize(width: boundingBox.width * imageRect.width,
                              height: boundingBox.height * imageRect.height)
            let origin = CGPoint(x: boundingBox.minX * imageRect.width,
                                 y: (1 - boundingBox.maxY) * imageRect.height + imageRect.origin.y)
            
            
            let layer = CALayer()
            layer.frame = CGRect(origin: origin, size: size)
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
        imageView.image = image
    }
    
}


