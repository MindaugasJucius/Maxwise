import UIKit
import AMTagListView

enum ModalTransitionType {
    case presentation
    case dismissal
}

class ExpenseCreationViewController: UIViewController {

    @IBOutlet private weak var cameraContainerView: UIView!
    @IBOutlet private weak var expenseInfoContainerView: UIView!
    @IBOutlet private var initialCameraHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var aspectCameraHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var textField: UITextField!
    
    @IBOutlet private weak var tagListView: AMTagListView!
    private weak var selectedTag: AMTagView?
    
    private let nearbyPlaces: [NearbyPlace]
    private let viewModel: ExpenseCreationViewModel
    private let transitionDelegate = ModalBlurTransitionController()
    
    private lazy var cameraViewController = CameraViewController(captureDelegate: self)

    init(viewModel: ExpenseCreationViewModel) {
        self.nearbyPlaces = viewModel.nearbyPlaces
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        transitioningDelegate = transitionDelegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.keyboardType = .numberPad

        configureTagListView()
        configureCameraContainerLayer()
        expenseInfoContainerView.layer.applyShadow()
        expenseInfoContainerView.layer.cornerRadius = 6
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addCameraController()
    }
    
    private func configureCameraContainerLayer() {
        cameraContainerView.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(showCamera))
        cameraContainerView.addGestureRecognizer(tapRecognizer)
        cameraContainerView.layer.applyShadow()
        cameraContainerView.layer.cornerRadius = 6
    }
    
    @objc private func showCamera() {
        let isCameraSmall = initialCameraHeightConstraint.isActive
        aspectCameraHeightConstraint.isActive = isCameraSmall
        initialCameraHeightConstraint.isActive = !isCameraSmall
        let animator = UIViewPropertyAnimator(duration: 0.3, dampingRatio: 0.82) {
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }
    
    private func configureTagListView() {
        viewModel.categories.forEach { category in
            let tagView = AMTagView(frame: .zero)
            tagView.holeRadius = 3
            tagView.applyDeselectedStyle()
            tagView.categoryID = category.id
            tagView.tagText = category.title as NSString
            tagListView.addTagView(tagView)
        }
        
        tagListView.setTapHandler { [weak self] tagView in
            self?.selectedTag?.applyDeselectedStyle()
            tagView?.applySelectedStyle()
            self?.selectedTag = tagView
        }
        
        tagListView.scrollDirection = .horizontal
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
            guard let self = self else { return }
            let formattedValue = self.viewModel.recognitionOccured(value)
            self.textField.text = formattedValue
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

    @IBAction func addExpenseTapped(_ sender: Any) {
        guard let tagView = selectedTag,
            let categoryID = tagView.categoryID else {
            return
        }

        guard let selectedCategory = viewModel.categories.filter({ $0.id == categoryID }).first else {
            return
        }
        
//        var selectedPlace: NearbyPlace? = nil
//        if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
//            selectedPlace = nearbyPlaces[selectedIndexPath.row]
//        }
//
        viewModel.performModelCreation(selectedPlace: nil,
                                       seletedCategory: selectedCategory)
        
        dismiss(animated: true, completion: nil)
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


extension AMTagView {
    
    var categoryID: String? {
        get {
            return userInfo["id"] as? String
        }
        set {
            userInfo = ["id": newValue as Any]
        }
    }
    
    func applySelectedStyle() {
        tagColor = .gray
        innerTagColor = .gray
    }
    
    func applyDeselectedStyle() {
        tagColor = .lightGray
        innerTagColor = .lightGray
    }
}

extension ExpenseCreationViewController: CameraCaptureDelegate {
    
    func captured(image: CGImage, orientation: CGImagePropertyOrientation, tapLocation: CGPoint) {
        addRecognitionController(cgImage: image, orientation: orientation, tapLocation: tapLocation)
    }
    
}
