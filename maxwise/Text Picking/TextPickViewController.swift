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
    private let viewModel = TextPickViewModel()
    
    private let nearbyPlacesProvider = NearbyPlacesProvider()
    private var nearbyPlaces: [NearbyPlace] = []
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var cropImageView: UIImageView!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var createEntryButton: UIButton!
    
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

        cropImageView.contentMode = .scaleAspectFit
        cropImageView.image = uiImage
        cropImageView.isHidden = true
        
        trackingImageRect = AVMakeRect(aspectRatio: uiImage.size, insideRect: screenBounds)
        
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.image = uiImage
        addTapRecognizer()
        
        scrollView.maximumZoomScale = 3
        scrollView.delegate = self
        
        let ciImage = CIImage(cgImage: cgImage)
        textDetectionController.handle(ciImage: ciImage, orientation: orientation)
        
        nearbyPlacesProvider.performFoursquareNearbyPlaceSearch { [weak self] venues in
            let nearbyPlaces = venues.map(NearbyPlace.init)
            self?.nearbyPlaces = nearbyPlaces
        }
    }
    
    private func addTapRecognizer() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapOccured(gesture:)))
        imageView.addGestureRecognizer(recognizer)
    }
    
    @objc private func tapOccured(gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: imageView)

        let containingFrame = imageView.subviews
            .map { $0.frame }
            .filter { $0.contains(tapLocation) }
            .first

        guard let frame = containingFrame else {
            return
        }

        handleRecognition(in: frame)
    }
    
    private func handleRecognition(in frame: CGRect) {
        guard let image = cropImageView.image else {
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

        viewModel.performRecognition(in: tmpImg) { [weak self] result in
            switch result {
            case .success(let value):
                self?.addResultView(recognizedDouble: value)
            case .error:
                print("Failed to recognize 😬")
            }
            

        }

    }
    
    private func addResultView(recognizedDouble: Double) {
//        let icon = Icon.init(iconPrefix: "d", suffix: "d")
//        let category = Category.init(id: "sd",
//                                     name: "weu",
//                                     pluralName: "weus",
//                                     shortName: "w",
//                                     icon: icon,
//                                     primary: true)
//        let venue1 = Venue(id: "1", name: "Donky donk", categories: [category], verified: true, referralID: "d", hasPerk: false)
//        let venue2 = Venue(id: "2", name: "Donky donkdonk", categories: [category], verified: true, referralID: "d", hasPerk: false)
//        let venue3 = Venue(id: "2", name: "Donky donkdonkdonkdonk", categories: [category], verified: true, referralID: "d", hasPerk: false)
//        let testVenues: [Venue] = [venue1, venue2, venue3]

        let place = NearbyPlace.init()
        place.title = "WEEEEU"
        place.categoryTitle = "dddd"
        
        let viewModel = ExpenseCreationViewModel(recognizedDouble: recognizedDouble,
                                                 image: imageView.image,
                                                 nearbyPlaces: [place])

        let expenseCreationViewController = ExpenseCreationViewController(viewModel: viewModel)

        let expenseCreationView: UIView! = expenseCreationViewController.view
        addChild(expenseCreationViewController)
        view.addSubview(expenseCreationView)
        expenseCreationViewController.didMove(toParent: self)
        expenseCreationView.translatesAutoresizingMaskIntoConstraints = false

        let constraints = [
            expenseCreationView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: expenseCreationView.trailingAnchor, multiplier: 1),
            view.bottomAnchor.constraint(equalToSystemSpacingBelow: expenseCreationView.bottomAnchor, multiplier: 3),
        ]
        NSLayoutConstraint.activate(constraints)
    }


    @IBAction private func closeTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension TextPickViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}

extension TextPickViewController: TextDetectionDelegate {
    
    func detected(boundingBoxes: [CGRect]) {
        let imageRect = trackingImageRect

        let layers: [UIView] = boundingBoxes.compactMap { boundingBox in
            let size = CGSize(width: boundingBox.width * imageRect.width,
                              height: boundingBox.height * imageRect.height)
            let origin = CGPoint(x: boundingBox.minX * imageRect.width,
                                 y: (1 - boundingBox.maxY) * imageRect.height + imageRect.origin.y)
            
            let trackingView = UIView(frame: .zero)
            trackingView.frame = CGRect(origin: origin, size: size)
            trackingView.layer.borderWidth = 1.5
            trackingView.layer.borderColor = UIColor.green.cgColor
            trackingView.layer.cornerRadius = 2
            return trackingView
        }
        
        layers.forEach {
            imageView.addSubview($0)
        }
    }
    
}

