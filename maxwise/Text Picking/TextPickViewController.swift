//
//  TextPickViewController.swift
//  maxwise
//
//  Created by Mindaugas Jucius on 2/7/19.
//  Copyright © 2019 Mindaugas Jucius. All rights reserved.
//

import UIKit
import AVKit
import Vision

class TextPickViewController: UIViewController {

    private let textDetectionController = TextDetectionController()
    private let viewModel = TextPickViewModel()
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var imageViewForCropping: UIImageView!
    
    private var trackingImageRect = CGRect.zero
    private let cgImage: CGImage
    private let orientation: CGImagePropertyOrientation
    private let tapLocation: CGPoint
    
    private let recognitionOccured: (Double) -> Void
    
    init(cgImage: CGImage, orientation: CGImagePropertyOrientation, tapLocation: CGPoint, recognitionOccured: @escaping (Double) -> Void) {
        self.recognitionOccured = recognitionOccured
        self.cgImage = cgImage
        self.orientation = orientation
        self.tapLocation = tapLocation
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
        
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.image = uiImage
        
        scrollView.maximumZoomScale = 3
        scrollView.delegate = self
        
        let ciImage = CIImage(cgImage: cgImage)
        textDetectionController.handle(ciImage: ciImage, orientation: orientation)
        let tapRectSize = CGSize.init(width: 30, height: 30)
        let tapRectOrigin = CGPoint.init(x: tapLocation.x - tapRectSize.width / 2,
                                         y: tapLocation.y - tapRectSize.height / 2)
        imageView.addSubview(createTrackingView(frame: .init(origin: tapRectOrigin, size: tapRectSize), matching: true))
    }
    
    override func viewDidLayoutSubviews() {
        trackingImageRect = AVMakeRect(aspectRatio: .init(width: cgImage.width, height: cgImage.height),
                                       insideRect: view.frame)
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func handleRecognition(in frame: CGRect) {
        guard let image = imageViewForCropping.image else {
            return
        }
        
        let rectangleOriginInTrackingImageRect = frame.origin.y - trackingImageRect.origin.y
        let imageScaleMatchingContainerRect = CGRect.init(x: frame.origin.x * (image.size.width / trackingImageRect.width),
                                                          y: rectangleOriginInTrackingImageRect * (image.size.height / trackingImageRect.height),
                                                          width: (frame.width / trackingImageRect.width) * image.size.width,
                                                          height: (frame.height / trackingImageRect.height) * image.size.height)
        
        UIGraphicsBeginImageContext(imageScaleMatchingContainerRect.size)
        let origin = CGPoint(x: -imageScaleMatchingContainerRect.origin.x,
                             y: -imageScaleMatchingContainerRect.origin.y)
        image.draw(at: origin)
        let tmpImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let imageView = UIImageView(image: tmpImg)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.fill(in: view)
        viewModel.performRecognition(in: tmpImg) { [weak self] result in
            switch result {
            case .success(let value):
                self?.recognitionOccured(value)
            case .error:
                print("Failed to recognize 😬")
            }
        }

    }
    
    private func createTrackingView(frame: CGRect, matching: Bool) -> UIView {
        let trackingView = UIView(frame: .zero)
        trackingView.frame = frame
        trackingView.layer.borderWidth = 1.5
        trackingView.layer.borderColor = matching ? UIColor.green.cgColor : UIColor.red.cgColor
        trackingView.layer.cornerRadius = 2
        return trackingView
    }
    
    private func convertedTrackingImageRect(fromPrecentageRect percentageRect: CGRect) -> CGRect {
        let size = CGSize(width: percentageRect.width * trackingImageRect.width,
                          height: percentageRect.height * trackingImageRect.height)
        let origin = CGPoint(x: percentageRect.minX * trackingImageRect.width,
                             y: (1 - percentageRect.maxY) * trackingImageRect.height + trackingImageRect.origin.y)
        return CGRect(origin: origin, size: size)
    }
    
}

extension TextPickViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}

extension TextPickViewController: TextDetectionDelegate {
    
    func detected(boundingBoxes: [CGRect]) {
        let scale = imageView.frame.height / trackingImageRect.height
        let transform = CGAffineTransform.init(scaleX: scale, y: scale)
        let trackingRects = boundingBoxes.map { box -> CGRect in
            
            let converted = convertedTrackingImageRect(fromPrecentageRect: .init(origin: box.origin, size: box.size))
            let transformed = converted.applying(transform)
            return transformed
        }
 

        trackingRects.forEach { rect in
            let trackingView = createTrackingView(frame: rect, matching: false)
            imageView.addSubview(trackingView)
        }

        let tapRectSize = CGSize.init(width: 30, height: 30)
        let tapRectOrigin = CGPoint.init(x: tapLocation.x - tapRectSize.width / 2,
                                         y: tapLocation.y - tapRectSize.height / 2)
        
        guard let matchingRecognitionRect = trackingRects.filter({ $0.intersects(CGRect(origin: tapRectOrigin, size: tapRectSize)) }).first else {
            return
        }

        let trackingView = createTrackingView(frame: matchingRecognitionRect, matching: true)
        imageView.addSubview(trackingView)
        
        handleRecognition(in: matchingRecognitionRect)
    }
    
}

