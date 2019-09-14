import UIKit
import ExpenseKit

enum ModalTransitionType {
    case presentation
    case dismissal
}

class ExpenseCreationViewController: UIViewController {

    @IBOutlet private weak var dismissalView: UIView!
    @IBOutlet private weak var cameraContainerView: UIView!
    @IBOutlet private weak var safeAreaBottomConstraint: NSLayoutConstraint!
    
    private lazy var collapseCameraButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.down.circle.fill"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0.5,
                                              left: 0.5,
                                              bottom: 0,
                                              right: 0)
        return button
    }()
    @IBOutlet private weak var collapseButtonContainer: VibrantContentView!
    
    private lazy var resetToCameraButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0.5,
                                              left: 0.5,
                                              bottom: 0,
                                              right: 0)
        return button
    }()
    @IBOutlet private weak var resetToCameraButtonContainer: VibrantContentView!
    
    lazy var creationInputView: ExpenseCreationInputView? = {
        let inputView = ExpenseCreationInputView.create(
            closeButton: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            },
            createButton: { [weak self] in
                self?.tryToCreateExpense()
            }
        )
        return inputView
    }()
    
    private lazy var cameraContainerBlurView: UIView! = {
        let blurView = BlurView()
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 6
        blurView.layer.cornerCurve = .continuous
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
    
    @IBOutlet private weak var createInputViewContainer: UIView!
    
    private lazy var cameraPresentTapRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(toggleCameraPresentation)
    )
    
    @IBOutlet private var initialCameraHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var expandedCameraHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var amountTextFieldContainerView: UIView!
    @IBOutlet private weak var currencyPlaceholderLabel: UILabel!
    @IBOutlet private weak var expenseInfoContainerView: UIView!
    @IBOutlet private weak var amountTextField: UITextField!
    @IBOutlet private weak var expenseTitle: UITextField!
    private weak var lastResponder: UIResponder?
    
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
        
        expenseTitle.placeholder = "Enter a description"
        expenseTitle.backgroundColor = .systemBackground
        expenseTitle.textColor = .label
        expenseTitle.delegate = self
        
        expenseInfoContainerView.layer.applyShadow(color: .tertiaryLabel)
        expenseInfoContainerView.layer.cornerRadius = 6
        expenseInfoContainerView.layer.cornerCurve = .continuous
        expenseInfoContainerView.backgroundColor = .systemBackground
        expenseInfoContainerView.isUserInteractionEnabled = true
        
        createInputViewContainer.addSubview(creationInputView!)
        creationInputView?.translatesAutoresizingMaskIntoConstraints = false
        creationInputView?.fillInSuperview()

        configureAmountTextField()
        configureCameraContainerLayer()
        configureSegmentedControl()
        configureDismissalView()
        addCategorySelectionController()

        observeResponderChanges()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }

    @objc private func applicationDidBecomeActive(notification: NSNotification) {
        lastResponder?.becomeFirstResponder()
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
        guard let color = category.color?.uiColor else {
            return
        }
        creationInputView?.update(for: color)
    }

    private func tryToCreateExpense() {
        let selectedShare = viewModel.percentages[segmentedControl.selectedSegmentIndex]

        viewModel.performModelCreation(title: expenseTitle.text,
                                       amount: amountTextField?.text,
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
                amountTextFieldContainerView.layer.borderColor = UIColor.red.cgColor
            case .noCategory:
                print("no category")
            case .alert(let message):
                showAlert(for: message)
            }
        }
    }
    
    @objc private func resetErrorStates() {
        amountTextFieldContainerView.layer.borderColor = UIColor.clear.cgColor
    }
    
    private func observeResponderChanges() {
        amountTextField.addTarget(self, action: #selector(handleObserverChange(responder:)), for: .editingDidBegin)
        expenseTitle.addTarget(self, action: #selector(handleObserverChange(responder:)), for: .editingDidBegin)
    }
    
    @objc private func handleObserverChange(responder: UIResponder) {
        self.lastResponder = responder
        // Tapped on text field while camera is shown
        if expandedCameraHeightConstraint.isActive {
            collapseCamera()
        }
    }
    
    private func configureDismissalView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
        dismissalView.addGestureRecognizer(tap)
    }
    
    @objc private func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
    
    private func configureAmountTextField() {
        amountTextField.delegate = self
        amountTextField.keyboardType = .decimalPad
        amountTextField.placeholder = viewModel.amountPlaceholder
        amountTextField.backgroundColor = .systemBackground
        amountTextField.textColor = .label
        amountTextField.becomeFirstResponder()
        amountTextField.borderStyle = .none
        amountTextField.addTarget(self, action: #selector(resetErrorStates), for: .editingChanged)
        amountTextFieldContainerView.layer.applyBorder()
        amountTextFieldContainerView.layer.borderColor = UIColor.clear.cgColor
        currencyPlaceholderLabel.text = viewModel.currencySymbol
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
        cameraContainerView.addGestureRecognizer(cameraPresentTapRecognizer)
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
    
    @objc private func toggleCameraPresentation() {
        lastResponder?.resignFirstResponder()
        
        let isCameraContainerHidden = initialCameraHeightConstraint.isActive
        cameraPresentTapRecognizer.isEnabled = !isCameraContainerHidden
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
        toggleCameraPresentation()
        removeRecognitionController()
        lastResponder?.becomeFirstResponder()
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

extension ExpenseCreationViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if textField == amountTextField {
            return checkAmountLength(additionString: string)
        }
        
        if textField == expenseTitle {
            return checkTitleLength(additionString: string)
        }
        
        return true
    }

    private func checkAmountLength(additionString: String) -> Bool {
        check(textField: amountTextField, maxLength: 8, additionString: additionString)
    }
    
    private func checkTitleLength(additionString: String) -> Bool {
        return check(textField: expenseTitle, maxLength: 25, additionString: additionString)
    }
    
    private func check(textField: UITextField, maxLength: Int, additionString: String) -> Bool {
        guard let text = textField.text else {
            return true
        }
        let textToBe = text + additionString
        if textToBe.count > maxLength {
            return false
        }
        
        return true
    }
    
}
