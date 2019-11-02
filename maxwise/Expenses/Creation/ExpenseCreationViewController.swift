import UIKit
import ExpenseKit

class ExpenseCreationViewController: UIViewController {

    private let notificationFeedback = UINotificationFeedbackGenerator()
    
    @IBOutlet private weak var dismissalView: UIView!
    @IBOutlet private weak var cameraContainerView: UIView!
    @IBOutlet private weak var safeAreaBottomConstraint: NSLayoutConstraint!

    
    @IBOutlet private weak var collapseButtonContainer: VibrantContentView!
    private lazy var collapseCameraButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.down.right.and.arrow.up.left"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0.5,
                                              left: 0.5,
                                              bottom: 0,
                                              right: 0)
        return button
    }()

    private var creationInputView: ExpenseCreationInputView?
    
    private lazy var cameraContainerBlurView: UIView! = {
        let blurView = BlurView()
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 6
        blurView.layer.cornerCurve = .continuous
        blurView.layer.masksToBounds = true
        
        let cameraImageContainerView = VibrantContentView()
        cameraImageContainerView.configuration = VibrantContentView.Configuration(cornerStyle: .circular,
                                                                                  blurEffectStyle: .prominent)
        
        let image = UIImage(systemName: "camera.on.rectangle")
        let imageView = UIImageView(image: image)
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
        action: #selector(presentCamera)
    )
    
    @IBOutlet private var initialCameraHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var expandedCameraHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var amountTextFieldContainerView: UIView!
    @IBOutlet private weak var currencyPlaceholderLabel: UILabel!
    @IBOutlet private weak var expenseInfoContainerView: UIView!
    @IBOutlet private weak var amountTextField: UITextField!
    @IBOutlet private weak var expenseTitleTextField: UITextField!
    private weak var lastResponder: UIResponder?
    
    @IBOutlet weak var categorySelectionContainerView: UIView!
    private var selectedCategory: ExpenseCategory?
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    
    private let viewModel: ExpenseCreationViewModel
    private let transitionDelegate = ModalBlurTransitionController()
        
    private var expenseToEdit: ExpenseEntry?
    private var categorySelectedController: ExpenseSelectedCategoryViewController?
    
    private lazy var visionVC = VisionViewController(nibName: nil, bundle: nil)
    
    private var hasAppeared = false
    
    init(viewModel: ExpenseCreationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        transitioningDelegate = transitionDelegate
        
        guard let preselectedCategoryID = ExpenseCategoryModelController.preselectedCategoryID,
            let category = viewModel.categories.filter ({ $0.id == preselectedCategoryID }).first else {
                print("failed to find preselected category")
                return
        }
        
        categorySelectedController = createCategorySelectionController(preselectedCategory: category)
    }
    
    convenience init(viewModel: ExpenseCreationViewModel, expenseToEdit: ExpenseEntry) {
        self.init(viewModel: viewModel)
        self.expenseToEdit = expenseToEdit
        // Can't save an expense without a category
        categorySelectedController = createCategorySelectionController(
            preselectedCategory: expenseToEdit.category!
        )
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
        
        let creationButtonTitle: String
        
        if let expenseToEdit = expenseToEdit {
            expenseTitleTextField.text = expenseToEdit.title
            amountTextField.text = viewModel.formatExisting(input: expenseToEdit.amount)
            creationButtonTitle = "Edit expense"
        } else {
            creationButtonTitle = "Add expense"
        }
        
        expenseTitleTextField.placeholder = "Enter a description"
        expenseTitleTextField.backgroundColor = .tertiarySystemBackground
        expenseTitleTextField.textColor = .label
        expenseTitleTextField.delegate = self
        
        expenseInfoContainerView.layer.applyShadow(color: .tertiaryLabel)
        expenseInfoContainerView.layer.cornerRadius = 6
        expenseInfoContainerView.layer.cornerCurve = .continuous
        adjustBackgroundColor(for: traitCollection)
        expenseInfoContainerView.isUserInteractionEnabled = true
        
        configureInputView(title: creationButtonTitle)
        configureAmountTextField()
        configureCameraContainerLayer()
        configureSegmentedControl()
        configureDismissalView()
        addCategorySelectionController()
        addVisionController()
        observeResponderChanges()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hasAppeared = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            expenseInfoContainerView.layer.applyShadow(color: .tertiaryLabel)
            adjustBackgroundColor(for: traitCollection)
        }
    }
    
    private func addVisionController() {
        addChild(visionVC)
        cameraContainerView.insertSubview(
            visionVC.view,
            belowSubview: cameraContainerBlurView
        )
        visionVC.view.fillInSuperview()
        visionVC.didMove(toParent: self)
        visionVC.didReceiveStableString = { [weak self] stableString in
            self?.amountTextField.text = stableString
        }
    }

    private func adjustBackgroundColor(for traitCollection: UITraitCollection) {
        if traitCollection.userInterfaceStyle == .dark {
            expenseInfoContainerView.backgroundColor = .secondarySystemBackground
        } else {
            expenseInfoContainerView.backgroundColor = .systemBackground
        }
    }
    
    @objc private func applicationDidBecomeActive(notification: NSNotification) {
        lastResponder?.becomeFirstResponder()
    }
    
    @objc private func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        let defaultYOffset: CGFloat = 24
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            safeAreaBottomConstraint.constant = defaultYOffset
        } else {
            safeAreaBottomConstraint.constant = defaultYOffset + keyboardViewEndFrame.height
        }
    }
    
    private func createCategorySelectionController(preselectedCategory: ExpenseCategory) -> ExpenseSelectedCategoryViewController {
        
        let categorySelectedController = ExpenseSelectedCategoryViewController(
            categories: viewModel.categories,
            categoryToPreselect: preselectedCategory,
            hasChangedSelectedCategory: { [weak self] selectedCategory in
            self?.handleCategorySelection(category: selectedCategory)
        })

        return categorySelectedController
    }
    
    private func addCategorySelectionController() {
        guard let categorySelectedController = categorySelectedController else {
            return
        }
        
        addChild(categorySelectedController)
        categorySelectionContainerView.backgroundColor = .clear
        categorySelectionContainerView.addSubview(categorySelectedController.view)
        categorySelectedController.view.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            categorySelectedController.view.widthAnchor.constraint(equalTo: categorySelectionContainerView.widthAnchor),
            categorySelectedController.view.heightAnchor.constraint(equalTo: categorySelectedController.view.widthAnchor),
            categorySelectedController.view.centerXAnchor.constraint(equalTo: categorySelectionContainerView.centerXAnchor),
            categorySelectedController.view.centerYAnchor.constraint(equalTo: categorySelectionContainerView.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        categorySelectedController.didMove(toParent: self)
    }
    
    private func handleCategorySelection(category: ExpenseCategory) {
        ExpenseCategoryModelController.preselectedCategoryID = category.id
        expenseTitleTextField.placeholder = category.title.capitalized
        selectedCategory = category
        guard let color = category.color?.uiColor else {
            return
        }
        creationInputView?.update(for: color)
        expenseTitleTextField.tintColor = color
        amountTextField.tintColor = color
    }

    private func tryToCreateExpense() {
        viewModel.performModelCreation(editedExpenseID: expenseToEdit?.id,
                                       title: expenseTitleTextField.text,
                                       amount: amountTextField?.text,
                                       selectedPlace: nil,
                                       categoryID: selectedCategory?.id) { [weak self] result in
            switch result {
            case .success(_):
                notificationFeedback.notificationOccurred(.success)
                self?.dismiss(animated: true, completion: nil)
            case .failure(let issues):
                notificationFeedback.notificationOccurred(.error)
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
                categorySelectedController?.categoryRepresentationView.update(for: .red)
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
        expenseTitleTextField.addTarget(self, action: #selector(handleObserverChange(responder:)), for: .editingDidBegin)
    }
    
    @objc private func handleObserverChange(responder: UIResponder) {
        self.lastResponder = responder
        if hasAppeared {
            toggleCameraPresentation(present: false)
        }
    }
    
    private func configureDismissalView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
        dismissalView.addGestureRecognizer(tap)
    }
    
    @objc private func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
    
    private func configureInputView(title: String) {
        let maybeInputView = ExpenseCreationInputView.create(
            title: title,
            closeButton: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            },
            createButton: { [weak self] in
                self?.tryToCreateExpense()
            }
        )
        
        guard let inputView = maybeInputView else {
            return
        }
        
        createInputViewContainer.addSubview(inputView)
        inputView.translatesAutoresizingMaskIntoConstraints = false
        inputView.fillInSuperview()
        creationInputView = inputView
    }
    
    private func configureAmountTextField() {
        amountTextField.delegate = self
        amountTextField.keyboardType = .decimalPad
        amountTextField.placeholder = viewModel.amountPlaceholder
        amountTextField.textColor = .label
        amountTextField.becomeFirstResponder()
        amountTextField.borderStyle = .none

        amountTextField.addTarget(self, action: #selector(resetErrorStates), for: .editingChanged)
        amountTextFieldContainerView.layer.applyBorder()
        amountTextFieldContainerView.layer.borderColor = UIColor.clear.cgColor
        amountTextFieldContainerView.backgroundColor = .tertiarySystemBackground
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
    }
    
    @objc private func presentCamera() {
        lastResponder?.resignFirstResponder()
        toggleCameraPresentation(present: true)
    }

    private func toggleCameraPresentation(present: Bool) {
        if !present {
            visionVC.resumeCameraSession()
        }
        
        cameraPresentTapRecognizer.isEnabled = !present
        expandedCameraHeightConstraint.isActive = present
        initialCameraHeightConstraint.isActive = !present
        let animator = UIViewPropertyAnimator(duration: 0.3, dampingRatio: 0.82) {
            self.view.layoutIfNeeded()
            if present {
                self.cameraContainerBlurView.alpha = 0
                self.collapseButtonContainer.alpha = 1
            } else {
                self.cameraContainerBlurView.alpha = 1
                self.collapseButtonContainer.alpha = 0
            }
        }
        
        animator.addCompletion { [weak self] position in
            guard position == .end else {
                return
            }
            self?.visionVC.shouldPerformRecognitionRequests = present
        }
        
        animator.startAnimation()
    }
    
    @objc private func collapseCamera() {
        toggleCameraPresentation(present: false)
        lastResponder?.becomeFirstResponder()
    }
}

extension ExpenseCreationViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if textField == amountTextField {
            return checkAmountLength(additionString: string)
        }
        
        if textField == expenseTitleTextField {
            return checkTitleLength(additionString: string)
        }
        
        return true
    }

    private func checkAmountLength(additionString: String) -> Bool {
        check(textField: amountTextField, maxLength: 10, additionString: additionString)
    }
    
    private func checkTitleLength(additionString: String) -> Bool {
        return check(textField: expenseTitleTextField, maxLength: 25, additionString: additionString)
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
