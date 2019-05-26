import UIKit
import AMTagListView

enum ModalTransitionType {
    case presentation
    case dismissal
}

class ExpenseCreationViewController: UIViewController {

    @IBOutlet private weak var cameraContainerView: UIView!
    @IBOutlet private weak var initialCameraHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var textField: UITextField!
    
    @IBOutlet private weak var tagListView: AMTagListView!
    private weak var selectedTag: AMTagView?
    
    private let nearbyPlaces: [NearbyPlace]
    private let viewModel: ExpenseCreationViewModel

    private lazy var cameraViewController = CameraViewController(captureDelegate: self)
    
    private var modalTransitionType: ModalTransitionType?
    
    init(viewModel: ExpenseCreationViewModel) {
        self.nearbyPlaces = viewModel.nearbyPlaces
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        transitioningDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.keyboardType = .numberPad

        cameraContainerView.layer.masksToBounds = true
        cameraContainerView.layer.cornerRadius = 6
        
        configureTagListView()
        configureCameraContainerLayer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //addCameraController()
    }
    
    private func configureCameraContainerLayer() {
        cameraContainerView.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(showCamera))
        cameraContainerView.addGestureRecognizer(tapRecognizer)
    }
    
    @objc private func showCamera() {
        initialCameraHeightConstraint.isActive = false
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
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

extension ExpenseCreationViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let result = dismissed == self ? self : nil
        modalTransitionType = .dismissal
        return result
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let result = presented == self ? self : nil
        modalTransitionType = .presentation
        return result
    }
}

extension ExpenseCreationViewController: UIViewControllerAnimatedTransitioning {

    private var transitionDuration: TimeInterval {
        guard let transitionType = modalTransitionType else { fatalError() }
        switch transitionType {
        case .presentation:
            return 0.44
        case .dismissal:
            return 0.32
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let transitionType = modalTransitionType else { fatalError() }
        
        var overlay: UIVisualEffectView?
        
        let viewOffScreenState = {
            let offscreenY = self.view.bounds.height
            self.view.transform = CGAffineTransform.identity.translatedBy(x: 0, y: offscreenY)
        }
        
        let presentedState = {
            self.view.transform = CGAffineTransform.identity
        }
        
        // Create blur animator and animations for modal states
        let blurAnimator = UIViewPropertyAnimator(duration: transitionDuration, curve: .easeInOut)
        
        let presentedBlurState: () -> () = {
            overlay?.effect = UIBlurEffect(style: .light)
        }
        
        let dismissedBlurState: () -> () = {
            overlay?.effect = nil
        }
        
        let animator: UIViewPropertyAnimator
        switch transitionType {
        case .presentation:
            animator = UIViewPropertyAnimator(duration: transitionDuration, dampingRatio: 0.82)
        case .dismissal:
            animator = UIViewPropertyAnimator(duration: transitionDuration, curve: .easeIn)
        }
        
        switch transitionType {
        case .presentation:
            // Create blur overlay and add it to the transition container
            let presentationOverlay = UIVisualEffectView()
            let toView = transitionContext.view(forKey: .to)!
            transitionContext.containerView.addSubview(presentationOverlay)
            presentationOverlay.fill(in: transitionContext.containerView)
            overlay = presentationOverlay
            
            transitionContext.containerView.addSubview(toView)
            toView.fill(in: transitionContext.containerView)
            
            UIView.performWithoutAnimation(viewOffScreenState)
            animator.addAnimations(presentedState)
            blurAnimator.addAnimations(presentedBlurState)
        case .dismissal:
            // Find the blur overlay in the hierarchy
            let existingOverlay = transitionContext.containerView.subviews.compactMap { $0 as? UIVisualEffectView }.first
            overlay = existingOverlay
            animator.addAnimations(viewOffScreenState)
            blurAnimator.addAnimations(dismissedBlurState)
        }
        
        // When the animation finishes,
        // we tell the system that the animation has completed,
        // and clear out our transition type.
        animator.addCompletion { _ in
            transitionContext.completeTransition(true)
            self.modalTransitionType = nil
        }
        
        // ... and here's where we kick off the animation:
        animator.startAnimation()
        blurAnimator.startAnimation()
    }
    
}
