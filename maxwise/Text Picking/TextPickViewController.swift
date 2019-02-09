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
    @IBOutlet private weak var heightConstraint: NSLayoutConstraint!
    
    private let trackingContainer = UIView()
    private var trackingImageRect = CGRect.zero
    
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

        trackingImageRect = AVMakeRect(aspectRatio: uiImage.size, insideRect: screenBounds)

        view.addSubview(trackingContainer)
        trackingContainer.isUserInteractionEnabled = false
        trackingContainer.frame = trackingImageRect
        
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
        let tapLocation = gesture.location(in: trackingContainer)
        
        let containingFrame = trackingContainer.subviews
            .map { $0.frame }
            .filter { $0.contains(tapLocation) }
            .first

        guard let frame = containingFrame,
            let image = imageView.image else {
            return
        }
        
        let imageScaleMatchingContainerRect = CGRect.init(x: frame.minX * (image.size.width / trackingImageRect.width),
                                                          y: frame.minY * (image.size.height / trackingImageRect.height),
                                                          width: (frame.width / trackingImageRect.width) * image.size.width,
                                                          height: (frame.height / trackingImageRect.height) * image.size.height)
        
        UIGraphicsBeginImageContext(imageScaleMatchingContainerRect.size)
        let origin = CGPoint(x: -imageScaleMatchingContainerRect.origin.x,
                             y: -imageScaleMatchingContainerRect.origin.y)
        image.draw(at: origin)
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
        let imageRect = trackingImageRect

        let layers: [UIView] = boundingBoxes.compactMap { boundingBox in
            let size = CGSize(width: boundingBox.width * imageRect.width,
                              height: boundingBox.height * imageRect.height)
            let origin = CGPoint(x: boundingBox.minX * imageRect.width,
                                 y: (1 - boundingBox.maxY) * imageRect.height)
            
            let trackingView = UIView(frame: .zero)
            trackingView.frame = CGRect(origin: origin, size: size)
            trackingView.layer.borderWidth = 2
            trackingView.layer.borderColor = UIColor.green.cgColor
            return trackingView
        }
        
        layers.forEach {
            trackingContainer.addSubview($0)
        }
    }
    
}

