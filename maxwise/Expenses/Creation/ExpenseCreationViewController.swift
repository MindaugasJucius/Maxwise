import UIKit
import ExpenseKit

enum ModalTransitionType {
    case presentation
    case dismissal
}

class ExpenseCreationViewController: UIViewController {

    @IBOutlet private weak var cameraContainerView: UIView!
    @IBOutlet private weak var safeAreaBottomConstraint: NSLayoutConstraint!
    
    private lazy var collapseCameraButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "collapse"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 8,
                                              left: 8,
                                              bottom: 8,
                                              right: 8)
        return button
    }()
    @IBOutlet private weak var collapseButtonContainer: VibrantContentView!
    
    private lazy var resetToCameraButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "refresh"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 8,
                                              left: 8,
                                              bottom: 8,
                                              right: 8)
        return button
    }()
    @IBOutlet private weak var resetToCameraButtonContainer: VibrantContentView!
    
    private lazy var cameraContainerBlurView: UIView! = {
        let blurView = BlurView()
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 6
        blurView.layer.masksToBounds = true
        
        let cameraImageContainerView = VibrantContentView()
        cameraImageContainerView.configuration = VibrantContentView.Configuration(cornerStyle: .circular,
                                                                                  blurEffectStyle: .prominent)
        let imageView = UIImageView(image: #imageLiteral(resourceName: "camera"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        cameraImageContainerView.contentView?.addSubview(imageView)
        blurView.contentView.addSubview(cameraImageContainerView)
        
        let vibrantViewSideLength: CGFloat = 35
        let imageViewSideLength: CGFloat = 20
        
        let imageViewConstraints = [
            imageView.heightAnchor.constraint(equalToConstant: imageViewSideLength),
            imageView.widthAnchor.constraint(equalToConstant: imageViewSideLength),
            imageView.centerXAnchor.constraint(equalTo: cameraImageContainerView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: cameraImageContainerView.centerYAnchor)
        ]

        NSLayoutConstraint.activate(imageViewConstraints)
        
        let vibrantViewConstraints = [
            cameraImageContainerView.heightAnchor.constraint(equalToConstant: vibrantViewSideLength),
            cameraImageContainerView.widthAnchor.constraint(equalToConstant: vibrantViewSideLength),
            cameraImageContainerView.centerXAnchor.constraint(equalTo: blurView.centerXAnchor),
            cameraImageContainerView.centerYAnchor.constraint(equalTo: blurView.centerYAnchor)
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
    @IBOutlet private weak var amountTextField: UITextField!
    @IBOutlet private weak var expenseTitle: UITextField!
    
    @IBOutlet weak var categorySelectionContainerView: UIView!
    private var selectedCategory: ExpenseCategory?
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    
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
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        amountTextField.keyboardType = .decimalPad
        amountTextField.placeholder = viewModel.amountPlaceholder
        amountTextField.backgroundColor = .systemBackground
        amountTextField.textColor = .label
        amountTextField.becomeFirstResponder()
        
        expenseTitle.placeholder = "Enter a description"
        expenseTitle.backgroundColor = .systemBackground
        expenseTitle.textColor = .label
        
        expenseInfoContainerView.layer.applyShadow(color: .tertiaryLabel)
        expenseInfoContainerView.layer.cornerRadius = 6
        expenseInfoContainerView.backgroundColor = .systemBackground
    
        let inputView = ExpenseCreationInputView.create(
            closeButton: { [weak self] in
                self?.dismissController()
            },
            createButton: { [weak self] in
                self?.tryToCreateExpense()
            }
        )
        amountTextField.inputAccessoryView = inputView
        expenseTitle.inputAccessoryView = inputView

        configureCameraContainerLayer()
        configureSegmentedControl()
        addCategorySelectionController()
        addDismissalTapHandler()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Creating camera session in viewDidLoad on the main queue lags a bit
        addCameraController()
    }
    
    @objc private func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            safeAreaBottomConstraint.constant = 16
        } else {
            safeAreaBottomConstraint.constant = keyboardViewEndFrame.height
        }
    }
    
    private func addCategorySelectionController() {
        let categorySelectedController = ExpenseSelectedCategoryViewController(categories: viewModel.categories) { [weak self] selectedCategory in
            self?.handleCategorySelection(category: selectedCategory)
        }
        addChild(categorySelectedController)
        categorySelectionContainerView.addSubview(categorySelectedController.view)
        categorySelectedController.view.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            categorySelectedController.view.widthAnchor.constraint(equalTo: categorySelectionContainerView.widthAnchor),
            categorySelectedController.view.heightAnchor.constraint(equalTo: categorySelectedController.view.widthAnchor),
            categorySelectedController.view.centerXAnchor.constraint(equalTo: categorySelectionContainerView.centerXAnchor),
            categorySelectedController.view.centerYAnchor.constraint(equalTo: categorySelectionContainerView.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        categorySelectedController.didMove(toParent: nil)
    }
    
    private func handleCategorySelection(category: ExpenseCategory) {
        expenseTitle.placeholder = category.title.capitalized
        selectedCategory = category
    }
    
    private func addDismissalTapHandler() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissController))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissController() {
        dismiss(animated: true, completion: nil)
    }

    private func tryToCreateExpense() {
        let selectedShare = viewModel.percentages[segmentedControl.selectedSegmentIndex]

        viewModel.performModelCreation(amount: amountTextField?.text,
                                       selectedPlace: nil,
                                       categoryID: selectedCategory?.id,
                                       sharePercentage: selectedShare) { [weak self] result in
            switch result {
            case .success(_):
                self?.dismiss(animated: true, completion: nil)
            case .failure(let issues):
                self?.handle(issues: issues)
            }
        }
    }
    
    private func handle(issues: [CreationIssue]) {
        resetErrorStates()
        issues.forEach { issue in
            switch issue {
            case .noAmount:
                amountTextField.textColor = .red
            case .noCategory:
                print("no category")
            case .alert(let message):
                showAlert(for: message)
            }
        }
    }
    
    private func resetErrorStates() {
        amountTextField.textColor = .label
    }
    
    private func configureSegmentedControl() {
        segmentedControl.removeAllSegments()
        viewModel.percentages.enumerated().forEach { (offset: Int, element: ExpenseDTO.SharePercentage) in
            segmentedControl.insertSegment(withTitle: element.uiRepresentation, at: offset, animated: false)
        }

        segmentedControl.selectedSegmentIndex = 0
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

        //Add collapse button
        collapseButtonContainer.configuration = VibrantContentView.Configuration(cornerStyle: .circular,
                                                                                 blurEffectStyle: .prominent)
        collapseButtonContainer.contentView?.addSubview(collapseCameraButton)
        collapseCameraButton.fillInSuperview()
        
        collapseButtonContainer.alpha = 0
        
        collapseCameraButton.addTarget(
            self,
            action: #selector(collapseCamera),
            for: .touchUpInside
        )
        
        //Add reset to camera button
        resetToCameraButtonContainer.configuration = VibrantContentView.Configuration(cornerStyle: .circular,
                                                                                      blurEffectStyle: .prominent)
        resetToCameraButtonContainer.contentView?.addSubview(resetToCameraButton)
        resetToCameraButton.fillInSuperview()
        
        resetToCameraButtonContainer.alpha = 0
        
        resetToCameraButton.addTarget(
            self,
            action: #selector(removeRecognitionController),
            for: .touchUpInside
        )
    }
    
    @objc private func showCamera() {
        amountTextField.resignFirstResponder()
        
        let isCameraContainerHidden = initialCameraHeightConstraint.isActive
        tapRecognizer.isEnabled = !isCameraContainerHidden
        expandedCameraHeightConstraint.isActive = isCameraContainerHidden
        initialCameraHeightConstraint.isActive = !isCameraContainerHidden
        let animator = UIViewPropertyAnimator(duration: 0.3, dampingRatio: 0.82) {
            self.cameraViewController.view.setNeedsLayout()
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
    
    @objc private func collapseCamera() {
        showCamera()
        removeRecognitionController()
        amountTextField.becomeFirstResponder()
    }
    
    @objc private func removeRecognitionController() {
        guard children.last is TextPickViewController else {
            return
        }
        children.last?.view.removeFromSuperview()
        children.last?.removeFromParent()
        resetToCameraButtonContainer.alpha = 0
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
        let recognitionOccured: (String) -> Void = { [weak self] value in
            if let formattedRecognized = self?.viewModel.formatRecognized(input: value) {
                self?.amountTextField.text = formattedRecognized
            } else {
                self?.handle(issues: [.noAmount])
            }
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

}

extension ExpenseCreationViewController: CameraCaptureDelegate {
    
    func captured(image: CGImage, orientation: CGImagePropertyOrientation, tapLocation: CGPoint) {
        resetToCameraButtonContainer.alpha = 1
        addRecognitionController(cgImage: image, orientation: orientation, tapLocation: tapLocation)
    }
    
}

//extension UIResponder {
//    private weak static var _currentFirstResponder: UIResponder? = nil
//
//    public static var current: UIResponder? {
//        UIResponder._currentFirstResponder = nil
//        UIApplication.shared.sendAction(#selector(findFirstResponder(sender:)), to: nil, from: nil, for: nil)
//        return UIResponder._currentFirstResponder
//    }
//
//    @objc internal func findFirstResponder(sender: AnyObject) {
//        UIResponder._currentFirstResponder = self
//    }
//}
