import UIKit

class ExpenseCreationViewController: UIViewController {

    @IBOutlet private weak var cameraContainerView: UIView!
    @IBOutlet private weak var textField: UITextField!
    //@IBOutlet private weak var collectionView: UICollectionView!
    
    private let nearbyPlaces: [NearbyPlace]
    private let viewModel: ExpenseCreationViewModel

    private lazy var cameraViewController = CameraViewController(captureDelegate: self)
    
    init(viewModel: ExpenseCreationViewModel) {
        self.nearbyPlaces = viewModel.nearbyPlaces
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.text = viewModel.formattedValue
        cameraContainerView.layer.masksToBounds = true
        cameraContainerView.layer.cornerRadius = 6
        //configureCollectionView()
        addCameraController()
    }
    
    private func addCameraController() {
        addChild(cameraViewController)
        cameraContainerView.addSubview(cameraViewController.view)
        cameraViewController.view.translatesAutoresizingMaskIntoConstraints = false
        cameraViewController.view.fill(in: cameraContainerView)
        cameraViewController.didMove(toParent: nil)
    }
    
    private func addRecognitionController(cgImage: CGImage,
                                          orientation: CGImagePropertyOrientation,
                                          tapLocation: CGPoint) {
        
        let recognitionOccured: (Double) -> Void = { [weak self] value in
            self?.textField.text = "\(value)"
        }
        let recognitionController = TextPickViewController(cgImage: cgImage,
                                                           orientation: orientation,
                                                           tapLocation: tapLocation,
                                                           recognitionOccured: recognitionOccured)
        addChild(recognitionController)
        cameraContainerView.addSubview(recognitionController.view)
        recognitionController.view.translatesAutoresizingMaskIntoConstraints = false
        recognitionController.view.fill(in: cameraContainerView)
        recognitionController.didMove(toParent: nil)

    }
    
//    private func configureCollectionView() {
//        let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
//        flowLayout?.scrollDirection = .horizontal
//        flowLayout?.estimatedItemSize = CGSize(width: 150, height: 80)
//        collectionView.backgroundColor = .clear
//        collectionView.dataSource = self
//        collectionView.allowsSelection = true
//        let venueCellNib = UINib(nibName: VenueCollectionViewCell.nibName, bundle: nil)
//        collectionView.register(venueCellNib,
//                                forCellWithReuseIdentifier: VenueCollectionViewCell.nibName)
//        collectionView.alwaysBounceHorizontal = true
//    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func addExpenseTapped(_ sender: Any) {
       // var selectedPlace: NearbyPlace? = nil
//        if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
//            selectedPlace = nearbyPlaces[selectedIndexPath.row]
//        }
     
        //viewModel.performModelCreation(selectedPlace: selectedPlace)
    }
}

extension ExpenseCreationViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nearbyPlaces.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: VenueCollectionViewCell.nibName,
            for: indexPath
        )
        guard let venueCell = cell as? VenueCollectionViewCell else {
            return cell
        }
        venueCell.update(venue: nearbyPlaces[indexPath.row])
        return venueCell
    }
    
}

extension ExpenseCreationViewController: CameraCaptureDelegate {
    
    func captured(image: CGImage, orientation: CGImagePropertyOrientation, tapLocation: CGPoint) {
        addRecognitionController(cgImage: image, orientation: orientation, tapLocation: tapLocation)
    }
    
}
