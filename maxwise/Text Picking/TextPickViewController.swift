//
//  TextPickViewController.swift
//  maxwise
//
//  Created by Mindaugas Jucius on 2/7/19.
//  Copyright © 2019 Mindaugas Jucius. All rights reserved.
//

import UIKit
import AVKit

class TextPickViewController: UIViewController {

    private let textDetectionController = TextDetectionController()
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var closeButton: UIButton!
    private var trackingLayers = [CALayer]()
    
    private let cgImage: CGImage
    private let orientation: CGImagePropertyOrientation
    
    init(cgImage: CGImage, orientation: CGImagePropertyOrientation) {
        self.cgImage = cgImage
        self.orientation = orientation
        super.init(nibName: nil, bundle: nil)
        textDetectionController.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let uiImage = UIImage(cgImage: cgImage,
                              scale: 1,
                              orientation: UIImage.Orientation(orientation))
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.image = uiImage
        addTapRecognizer()
        
        let ciImage = CIImage(cgImage: cgImage)
        textDetectionController.handle(ciImage: ciImage, orientation: orientation)
    }
    
    private func addTapRecognizer() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapOccured(gesture:)))
        imageView.addGestureRecognizer(recognizer)
    }
    
    @objc private func tapOccured(gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: imageView)
        let containingLayers = trackingLayers.filter { layer in
            layer.frame.contains(tapLocation)
        }
        
        guard let partToCrop = containingLayers.first?.frame else {
            return
        }
        
        print(partToCrop)
    }

    @IBAction private func closeTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension TextPickViewController: TextDetectionDelegate {
    
    func detected(boundingBoxes: [CGRect]) {
        guard let image = imageView.image else {
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

