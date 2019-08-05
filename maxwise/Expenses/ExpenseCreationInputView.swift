import UIKit

class ExpenseCreationInputView: UIInputView {

    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var createButton: UIButton!
    
    private var closeButtonAction: (() -> ())?
    private var createButtonAction: (() -> ())?
    
    static func create(closeButton: @escaping () -> (),
                       createButton: @escaping () -> ()) -> ExpenseCreationInputView? {
        let nibName = String(describing: ExpenseCreationInputView.self)
        let nib = Bundle.main.loadNibNamed(nibName, owner: nil, options: nil)
        let inputView = nib?.first as? ExpenseCreationInputView
        inputView?.createButtonAction = createButton
        inputView?.closeButtonAction = closeButton
        return inputView
    }
    
    @IBAction func createButton(_ sender: Any) {
        createButtonAction?()
    }
    
    @IBAction func closeButton(_ sender: UIButton) {
        closeButtonAction?()
    }
    
}
