import UIKit
import ExpenseKit

class CategoryCreationViewController: UIViewController {

    private let transitionDelegate = ModalBlurTransitionController()
    private let expenseCategory: ExpenseCategory
    
    @IBOutlet private weak var categoryCreationViewContainer: UIView!
    @IBOutlet private weak var safeAreaBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var dismissalView: UIView!
    @IBOutlet private weak var creationButton: BeautifulButton!

    private let expenseCategoryModelController = ExpenseCategoryModelController()
    private let colorModelController = ColorModelController()
    private lazy var initialColor = colorModelController.randomNonTakenColor()
    
    private lazy var creationView: CategoryCreationView = {
        let notTakenColors = colorModelController.notTakenColors().filter { $0 != initialColor }
        return CategoryCreationView(
            expenseCategory: expenseCategory,
            colors: notTakenColors + colorModelController.takenColors(),
            selectedColor: expenseCategory.color ?? initialColor,
            changedColorSelection: { [weak self] color in
                guard let uiColor = color.uiColor else {
                    return
                }
                self?.creationButton.updateAppearances(backgroundColor: uiColor,
                                                       textColor: uiColor)
            }
        )
    }()

    /// Initialize controller
    /// - Parameter category: Category to create or edit
    init(category: ExpenseCategory) {
        self.expenseCategory = category
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        transitioningDelegate = transitionDelegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        creationView.translatesAutoresizingMaskIntoConstraints = false
        
        categoryCreationViewContainer.addSubview(creationView)
        creationView.fillInSuperview()
        
        creationButton.addTarget(self, action: #selector(persistCategory), for: .touchUpInside)
    
        if expenseCategory.isEmpty() {
            creationButton.setTitle("Add category", for: .normal)
        } else {
            creationButton.setTitle("Edit category", for: .normal)
        }

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(applicationDidBecomeActive),
                                       name: UIApplication.willEnterForegroundNotification,
                                       object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
        dismissalView.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        creationView.titleTextField.becomeFirstResponder()
    }
    
    @objc private func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func applicationDidBecomeActive(notification: NSNotification) {
        creationView.titleTextField.becomeFirstResponder()
    }
    
    @objc private func persistCategory() {
        if let categoryDTO = creationView.categoryDataIfValid() {
            if expenseCategory.isEmpty() {
                expenseCategoryModelController.persist(category: categoryDTO)
            } else {
                expenseCategoryModelController.edit(
                    expenseCategory: expenseCategory,
                    newValues: categoryDTO)
            }
            dismiss(animated: true, completion: nil)
        }
    }

    @objc private func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            safeAreaBottomConstraint.constant = 16
        } else {
            safeAreaBottomConstraint.constant = keyboardViewEndFrame.height + 30
        }
    }
}
