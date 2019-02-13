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
    
    let minimumZoom: CGFloat = 1.0
    let maximumZoom: CGFloat = 3.0
    var lastZoomFactor: CGFloat = 1.0
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCameraLayer()
        view.backgroundColor = .black
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinch(_:)))
        view.addGestureRecognizer(pinch)
    }
    
    func addCameraLayer() {
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
        let testImage = UIImage(named: "testImage")
        guard let cgImage = testImage?.cgImage else {
            return
        }
        captured(image: cgImage, orientation: .up)
        #else
        cameraController.takePhoto()
        #endif
    }

    @IBAction func statsTapped(_ sender: Any) {
        let expensesViewController = ExpensesViewController()
        present(expensesViewController, animated: true, completion: nil)
    }
    
    @IBAction func presentImagePicker(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
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

extension ViewController: PictureRetrievalDelegate {
    
    func captured(image: CGImage, orientation: CGImagePropertyOrientation) {
        let textDetectionController = TextPickViewController.init(cgImage: image,
                                                                  orientation: orientation)
        present(textDetectionController, animated: true, completion: nil)
    }
}

extension ViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage,
            let cgImage = image.cgImage else {
            return
        }

        let orientation = CGImagePropertyOrientation.init(image.imageOrientation)
        let textDetectionController = TextPickViewController.init(cgImage: cgImage,
                                                                  orientation: orientation)
        dismiss(animated: true) { [weak self] in
            self?.present(textDetectionController,
                          animated: true,
                          completion: nil)
        }

    }
    
}
