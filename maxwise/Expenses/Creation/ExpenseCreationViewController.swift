import UIKit
import AMTagListView

enum ModalTransitionType {
    case presentation
    case dismissal
}

class ExpenseCreationViewController: UIViewController {

    @IBOutlet private weak var cameraContainerView: UIView!
    
    private lazy var collapseCameraButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "collapse"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 8,
                                              left: 8,
                                              bottom: 8,
                                              right: 8)
        return button
    }()
    @IBOutlet weak var collapseButtonContainer: VibrantContentView!
    
    private lazy var cameraContainerBlurView: UIView! = {
        let blurView = BlurView()
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 6
        blurView.layer.masksToBounds = true
        
        let vibrantView = VibrantContentView()
        let imageView = UIImageView(image: #imageLiteral(resourceName: "camera"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        vibrantView.contentView.addSubview(imageView)
        blurView.contentView.addSubview(vibrantView)
        
        let vibrantViewSideLength: CGFloat = 35
        let imageViewSideLength: CGFloat = 20
        
        let imageViewConstraints = [
            imageView.heightAnchor.constraint(equalToConstant: imageViewSideLength),
            imageView.widthAnchor.constraint(equalToConstant: imageViewSideLength),
            imageView.centerXAnchor.constraint(equalTo: vibrantView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: vibrantView.centerYAnchor)
        ]
        NSLayoutConstraint.activate(imageViewConstraints)
        
        let vibrantViewConstraints = [
            vibrantView.heightAnchor.constraint(equalToConstant: vibrantViewSideLength),
            vibrantView.widthAnchor.constraint(equalToConstant: vibrantViewSideLength),
            vibrantView.centerXAnchor.constraint(equalTo: blurView.centerXAnchor),
            vibrantView.centerYAnchor.constraint(equalTo: blurView.centerYAnchor)
        ]
        NSLayoutConstraint.activate(vibrantViewConstraints)
        
        return blurView
    }()
    private lazy var tapRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(showCamera)
    )
    
    @IBOutlet private var initialCameraHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var expandedCameraHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var expenseInfoContainerView: UIView!
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let ratio: CGFloat = 4/3
        let expandedCameraHeight = ratio * cameraContainerView.bounds.width
        expandedCameraHeightConstraint.constant = expandedCameraHeight
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
        cameraContainerView.addGestureRecognizer(tapRecognizer)
        cameraContainerView.clipsToBounds = true
        cameraContainerView.layer.cornerRadius = 6
        cameraContainerView.insertSubview(
            cameraContainerBlurView,
            belowSubview: collapseButtonContainer
        )
        cameraContainerBlurView.fill(in: cameraContainerView)

        collapseButtonContainer.contentView.addSubview(collapseCameraButton)
        collapseCameraButton.fill(in: collapseButtonContainer.contentView)
        
        collapseButtonContainer.alpha = 0
        
        collapseCameraButton.addTarget(
            self,
            action: #selector(showCamera),
            for: .touchUpInside
        )
    }
    
    @objc private func showCamera() {
        let isCameraContainerHidden = initialCameraHeightConstraint.isActive
        tapRecognizer.isEnabled = !isCameraContainerHidden
        expandedCameraHeightConstraint.isActive = isCameraContainerHidden
        initialCameraHeightConstraint.isActive = !isCameraContainerHidden
        let animator = UIViewPropertyAnimator(duration: 0.3, dampingRatio: 0.82) {
            self.view.layoutIfNeeded()
            if isCameraContainerHidden {
                self.cameraContainerBlurView.alpha = 0
                self.collapseButtonContainer.alpha = 1
            } else {
                self.cameraContainerBlurView.alpha = 1
                self.collapseButtonContainer.alpha = 0
            }
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
    
    private func addCameraController() {
        addChild(cameraViewController)
        cameraContainerView.insertSubview(cameraViewController.view,
                                          belowSubview: cameraContainerBlurView)
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
        cameraContainerView.insertSubview(recognitionController.view,
                                          belowSubview: cameraContainerBlurView)
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

extension ExpenseCreationViewController: CameraCaptureDelegate {
    
    func captured(image: CGImage, orientation: CGImagePropertyOrientation, tapLocation: CGPoint) {
        addRecognitionController(cgImage: image, orientation: orientation, tapLocation: tapLocation)
    }
    
}
