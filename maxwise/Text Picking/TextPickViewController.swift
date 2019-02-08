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
    private let digitRecognizer = DigitRecognizer()
    
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

        let screenBounds = UIScreen.main.bounds
        let adjustedWidth = uiImage.size.height * (screenBounds.width / screenBounds.height)
        let screenFitSize = CGSize(width: adjustedWidth, height: uiImage.size.height)

        UIGraphicsBeginImageContextWithOptions(screenFitSize, false, 0)
        let xCoord = (uiImage.size.width - adjustedWidth) / 2
        uiImage.draw(at: CGPoint.init(x: -xCoord, y: 0))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.image = scaledImage
        addTapRecognizer()

        textDetectionController.handle(cgImage: cgImage, orientation: orientation)
    }
    
    private func addTapRecognizer() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapOccured(gesture:)))
        imageView.addGestureRecognizer(recognizer)
    }
    
    @objc private func tapOccured(gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: imageView)
        let containingLayer = trackingLayers.filter { layer in
            layer.frame.contains(tapLocation)
        }.first
        
        guard let frame = containingLayer?.frame else {
            return
        }
        
        let insetFactor = CGFloat(0.1)
        let insetCroppingFrame = frame.insetBy(dx: -frame.width * insetFactor,
                                               dy: -frame.height * insetFactor)
        
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, 0);
        imageView.drawHierarchy(in: imageView.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

    
        UIGraphicsBeginImageContext(insetCroppingFrame.size)
        let origin = CGPoint(x: -insetCroppingFrame.origin.x, y: -insetCroppingFrame.origin.y)
        image?.draw(at: origin)
        let tmpImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        imageView.image = tmpImg
        digitRecognizer.recognize(image: tmpImg) { [weak self] result in
            let userVisibleString = result ?? "Failed to recognize 😬"
            self?.addResultView(text: userVisibleString)
        }
    }
    
    private func addResultView(text: String) {
        let blurView = BlurLabelView(text: text)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurView)
        let constraints = [
            blurView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: blurView.trailingAnchor, multiplier: 1),
            closeButton.topAnchor.constraint(equalTo: blurView.bottomAnchor, constant: 120),
            blurView.heightAnchor.constraint(equalToConstant: 50),
        ]
        NSLayoutConstraint.activate(constraints)
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

